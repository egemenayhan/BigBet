//
//  EventsListViewController.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit
import Combine

class EventsListViewController: UIViewController {

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, BetEvent>!
    private var cancellables = Set<AnyCancellable>()
    private var searchBar: UISearchBar!
    private var cartImage = UIImage(systemName: "cart.fill")?
        .applyingSymbolConfiguration(.init(paletteColors: [ThemeManager.current.primaryGreen]))
    private let analyticsUseCase = DependencyContainer.shared.analyticsUsecase

    private let viewModel: EventsListViewModel

    enum Section {
        case main
    }

    init(viewModel: EventsListViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.current.background

        setupNavigationBar()
        setupTableView()
        setupSearchBar()
        configureDataSource()
        bindViewModel()

        viewModel.fetchEvents()
    }

    private func setupNavigationBar() {
        title = "BigBet"
        updateCartButton()
    }

    func updateCartButton() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        let cartButton = UIBarButtonItem(
            image: cartImage,
            title: formatter.string(from: viewModel.totalBetPrice as NSNumber) ?? "",
            target: self,
            action: #selector(cartButtonTapped)
        )

        navigationItem.rightBarButtonItem = cartButton
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.autoresizingMask = [.flexibleHeight]
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.identifier)
        tableView.backgroundColor = ThemeManager.current.background
        view.addSubview(tableView)
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.tintColor = ThemeManager.current.primaryGreen
        searchBar.backgroundColor = ThemeManager.current.cardBackground
        searchBar.barTintColor = ThemeManager.current.primaryGreen
        searchBar.sizeToFit()

        searchBar.searchTextField.backgroundColor = ThemeManager.current.oddUnselected
        searchBar.searchTextField.textColor = ThemeManager.current.textPrimary
        searchBar.searchTextField.leftView?.tintColor = ThemeManager.current.primaryGreen
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search teams",
            attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.current.textSecondary]
        )

        tableView.tableHeaderView = searchBar
    }

    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, BetEvent>(tableView: tableView) { [weak self] tableView, indexPath, event in
            guard let self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier, for: indexPath) as! EventTableViewCell

            var selectedOddIndex: Int?
            if let bet = self.viewModel.getBetForEvent(id: event.id), let index = event.odds.firstIndex(of: bet.odd) {
                selectedOddIndex = index
            }
            cell.configure(with: event, selectedIndex: selectedOddIndex)
            cell.onOddTapped = { tappedIndex in
                guard let index = tappedIndex else {
                    self.viewModel.removeBet(for: event.id)
                    return
                }
                self.viewModel.placeBet(for: event, with: event.odds[index])
            }

            return cell
        }
    }

    // Observing changes on view model
    private func bindViewModel() {
        viewModel.$events
            .receive(on: RunLoop.main)
            .sink { [weak self] events in
                self?.applySnapshot(events: events)
            }
            .store(in: &cancellables)

        viewModel.updatedIndexes
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self, !items.isEmpty else { return }

                var snapshot = self.dataSource.snapshot()
                snapshot.reloadItems(items)
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)

        viewModel.$totalBetPrice
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateCartButton()
            }
            .store(in: &cancellables)

        // Error handling
        viewModel.errorSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] errorMessage in
            let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alertController, animated: true)
        }
        .store(in: &cancellables)
    }

    private func applySnapshot(events: [BetEvent]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetEvent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(events, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // Action when the Cart button is tapped
    @objc func cartButtonTapped() {
        // Present the cart view controller modally
        let cartVC = CartViewController(
            viewModel: CartViewModel(
                betsUseCase: BetsUseCase(
                    storage: DependencyContainer.shared.betDataStorage,
                    analyticsUseCase: DependencyContainer.shared.analyticsUsecase
                )
            )
        )
        cartVC.onEventTap = { [weak self, weak cartVC] event in
            cartVC?.dismiss(animated: true) { [weak self] in
                self?.navigateToEventDetail(event: event)
            }
        }
        let navigationController = UINavigationController(rootViewController: cartVC)
        present(navigationController, animated: true, completion: nil)
    }

    func navigateToEventDetail(event: BetEvent) {
        let detailViewModel = EventDetailViewModel(
            event: event,
            betsUseCase: BetsUseCase(
                storage: DependencyContainer.shared.betDataStorage,
                analyticsUseCase: DependencyContainer.shared.analyticsUsecase
            )
        )
        let eventDetailVC = EventDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(eventDetailVC, animated: true)

        analyticsUseCase.logEvent(.event(.detailTap), parameters: ["id": event.id])
    }
}

extension EventsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell,
              let event = cell.event else { return }
        navigateToEventDetail(event: event)
    }
}

extension EventsListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let results = viewModel.filterEvents(for: searchText)
        applySnapshot(events: results)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        applySnapshot(events: viewModel.events)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard searchBar.text?.isEmpty ?? true else { return }
        searchBar.showsCancelButton = true
    }
}

extension UIBarButtonItem {
    convenience init(image: UIImage?, title: String, target: Any?, action: Selector?) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0)

        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }

        self.init(customView: button)
    }
}
