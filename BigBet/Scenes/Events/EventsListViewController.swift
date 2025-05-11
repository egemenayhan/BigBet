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
        configureDataSource()
        bindViewModel()

        // Fake initial data load
        viewModel.fetchEvents()
        applySnapshot()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.autoresizingMask = [.flexibleHeight]
        tableView.register(OddsTableViewCell.self, forCellReuseIdentifier: OddsTableViewCell.identifier)
        tableView.backgroundColor = ThemeManager.current.background
        view.addSubview(tableView)
    }

    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, BetEvent>(tableView: tableView) { [weak self] tableView, indexPath, event in
            guard let self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: OddsTableViewCell.identifier, for: indexPath) as! OddsTableViewCell
//            let selectedIndex = self.viewModel.selectedIndices[event.id]
            cell.configure(with: event, selectedIndex: 1)

            cell.onOddTapped = { [weak self] tappedIndex in
                let selected: Int? = tappedIndex == -1 ? nil : tappedIndex
//                self?.viewModel.selectOdd.send((event, selected))
            }

            return cell
        }
    }

    private func bindViewModel() {
        viewModel.$events
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)

//        viewModel.$selectedIndices
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                self?.refreshVisibleCells()
//            }
//            .store(in: &cancellables)
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetEvent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.events, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func refreshVisibleCells() {
//        guard let visible = tableView.indexPathsForVisibleRows else { return }
//
//        for indexPath in visible {
//            if let event = dataSource.itemIdentifier(for: indexPath),
//               let cell = tableView.cellForRow(at: indexPath) as? OddsTableViewCell {
//                let selected = viewModel.selectedIndices[event.id]
//                cell.applySelection(at: selected)
//            }
//        }
    }
}
