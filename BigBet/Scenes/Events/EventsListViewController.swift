//
//  EventsListViewController.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit
import Combine

class EventsListViewController: UIViewController, UITableViewDelegate {

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, BetEvent>!
    private var cancellables = Set<AnyCancellable>()
    private var searchBar: UISearchBar!
    private var isSearching = false

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
        title = "BigBet"
        view.backgroundColor = ThemeManager.current.background

        setupTableView()
        setupSearchBar()
        configureDataSource()
        bindViewModel()

        viewModel.fetchEvents()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.autoresizingMask = [.flexibleHeight]
        tableView.register(OddsTableViewCell.self, forCellReuseIdentifier: OddsTableViewCell.identifier)
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

            let cell = tableView.dequeueReusableCell(withIdentifier: OddsTableViewCell.identifier, for: indexPath) as! OddsTableViewCell
            // TODO: Handle selected state
            cell.configure(with: event, selectedIndex: 1)

            cell.onOddTapped = { tappedIndex in
                // TODO: Handle selection
            }

            return cell
        }
    }

    private func bindViewModel() {
        viewModel.$events
            .receive(on: RunLoop.main)
            .sink { [weak self] events in
                self?.applySnapshot(events: events)
            }
            .store(in: &cancellables)
    }

    private func applySnapshot(events: [BetEvent]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetEvent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(events, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
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

