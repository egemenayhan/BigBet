//
//  EventsListViewController.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit
import RxSwift
import RxCocoa

class EventsListViewController: UIViewController {

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, BetEvent>!
    private var searchBar: UISearchBar!
    private var cartImage = UIImage(systemName: "cart.fill")?
        .applyingSymbolConfiguration(.init(paletteColors: [ThemeManager.current.primaryGreen]))

    private let analyticsUseCase = DependencyContainer.shared.analyticsUsecase

    private let disposeBag = DisposeBag()
    private let viewModel: EventsListViewModel
    private var didBindViewModel = false

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

        viewModel.fetchEvents()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Binding on appear because if we do it on did load binding triggers tableview load before it is in view hierarchy which gives warning. If we skip first onNext then cells` first load has weird animation so this is quick fix to the problem. This problem ocurred after switching from combine.
        bindViewModel()
    }

    // MARK: - UI setup

    private func setupNavigationBar() {
        title = "BigBet"
        updateCartButton()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.identifier)
        tableView.backgroundColor = ThemeManager.current.background
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        configureDataSource()
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = ThemeManager.current.primaryGreen
        searchBar.backgroundColor = ThemeManager.current.cardBackground
        searchBar.barTintColor = ThemeManager.current.primaryGreen
        searchBar.sizeToFit()

        searchBar.searchTextField.backgroundColor = ThemeManager.current.oddUnselected
        searchBar.searchTextField.textColor = ThemeManager.current.textPrimary
        searchBar.searchTextField.leftView?.tintColor = ThemeManager.current.primaryGreen
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: AppConstants.Search.placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.current.textSecondary]
        )

        tableView.tableHeaderView = searchBar
        setupSearchBinding()
    }

    private func setupSearchBinding() {
        // Reactive search with debouncing
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(AppConstants.Search.debounceTimeMilliseconds), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { [weak self] searchText in
                self?.viewModel.filterEvents(for: searchText) ?? []
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] filteredEvents in
                self?.applySnapshot(events: filteredEvents)
            })
            .disposed(by: disposeBag)

        // Handle cancel button
        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.searchBar.text = ""
                self.searchBar.resignFirstResponder()
                self.searchBar.showsCancelButton = false
                self.applySnapshot(events: self.viewModel.events.value)
            })
            .disposed(by: disposeBag)

        // Handle search button
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        // Handle text begin editing
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self, self.searchBar.text?.isEmpty ?? true else { return }
                self.searchBar.showsCancelButton = true
            })
            .disposed(by: disposeBag)
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

    // MARK: - View Model Observers

    // Observing changes on view model
    private func bindViewModel() {
        guard !didBindViewModel else { return }

        didBindViewModel = true

        viewModel.events
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] events in
                self?.applySnapshot(events: events)
            })
            .disposed(by: disposeBag)

        viewModel.totalBetPrice
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateCartButton()
            })
            .disposed(by: disposeBag)

        // Observe bet changes directly and refresh table view
        viewModel.updatedEvents
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                // Reconfigure all visible items to update cell selection states
                var snapshot = self.dataSource.snapshot()
                snapshot.reconfigureItems(snapshot.itemIdentifiers)
                self.dataSource.apply(snapshot, animatingDifferences: false)
            })
            .disposed(by: disposeBag)

        // Error handling
        viewModel.errorSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - UI updates

    func updateCartButton() {
        let price = String(
            format: "%.\(AppConstants.Formatting.priceDecimalPlaces)f", viewModel.totalBetPrice.value
        )

        let cartButton = UIBarButtonItem(
            image: cartImage,
            title: price,
            target: self,
            action: #selector(cartButtonTapped)
        )

        navigationItem.rightBarButtonItem = cartButton
    }

    private func applySnapshot(events: [BetEvent]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetEvent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(events, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Navigation actions

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

    // Navigates to detail on cell tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell,
              let event = cell.event else { return }
        navigateToEventDetail(event: event)
    }
}


