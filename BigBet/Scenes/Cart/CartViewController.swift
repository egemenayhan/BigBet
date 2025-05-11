//
//  CartViewController.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import UIKit
import Combine

class CartViewController: UIViewController {

    // Diffable data source
    private var dataSource: CartDataSource!
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: CartViewModel
    private var tableView: UITableView = UITableView()

    // Enum to define section type
    enum Section {
        case main
    }

    init(viewModel: CartViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the cell
        tableView.register(BetTableViewCell.self, forCellReuseIdentifier: BetTableViewCell.identifier)

        // Configure the diffable data source
        configureDataSource()
        setupTableView()
        bindViewModel()

        applySnapshot()
    }

    private func bindViewModel() {
        viewModel.$bets
            .receive(on: RunLoop.main)
            .sink { [weak self] events in
                self?.applySnapshot()
            }
            .store(in: &cancellables)

        viewModel.$totalBetPrice
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self else { return }

                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2

                self.title = "\(self.viewModel.bets.count) Event(s) - Total: \(formatter.string(from: NSNumber(value: $0)) ?? "0.00")"
            }
            .store(in: &cancellables)
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Register the cell
        tableView.register(BetTableViewCell.self, forCellReuseIdentifier: BetTableViewCell.identifier)

        // Set the table view's delegate and data source
        tableView.delegate = self
        tableView.dataSource = dataSource

        // Add the table view to the main view
        view.addSubview(tableView)

        // Set up constraints
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Configure diffable data source
    private func configureDataSource() {
        dataSource = CartDataSource(viewModel: viewModel, tableView: tableView) { (tableView, indexPath, bet) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: BetTableViewCell.identifier, for: indexPath) as! BetTableViewCell

            cell.configure(with: bet)
            cell.onDelete = { [weak self] in
                guard let self = self else { return }
                self.viewModel.removeBet(id: bet.event.id)
            }

            return cell
        }
    }

    // Apply snapshot to update data
    private func applySnapshot() {
        let snapshot = dataSource.generateSnapshot()
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension CartViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            if let self = self {
                self.viewModel.removeBet(at: indexPath.row)
            }
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
