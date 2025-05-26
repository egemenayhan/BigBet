//
//  CartViewController.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import UIKit
import RxSwift
import RxCocoa

class CartViewController: UIViewController {
    // Diffable data source
    private var dataSource: CartDataSource!
    private let disposeBag = DisposeBag()
    private var viewModel: CartViewModel
    private var tableView: UITableView = UITableView()

    var onEventTap: ((BetEvent) -> Void)?

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

    deinit {
        print("cart deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.current.background

        // Configure the diffable data source
        configureDataSource()
        setupTableView()
        bindViewModel()

        applySnapshot()
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Register the cell
        tableView.register(BetTableViewCell.self, forCellReuseIdentifier: BetTableViewCell.identifier)

        // Set the table view's delegate and data source
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundColor = ThemeManager.current.background

        // Add the table view to the main view
        view.addSubview(tableView)

        // Set up constraintsad
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Configure diffable data source
    private func configureDataSource() {
        dataSource = CartDataSource(viewModel: viewModel, tableView: tableView) { [weak self] (tableView, indexPath, bet) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: BetTableViewCell.identifier, for: indexPath) as! BetTableViewCell

            cell.configure(with: bet)
            cell.onDelete = { [weak self] in
                guard let self = self else { return }
                self.viewModel.removeBet(id: bet.event.id)
            }

            return cell
        }
    }

    private func bindViewModel() {
        viewModel.bets
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.applySnapshot()
                self.updateTitle()
            })
            .disposed(by: disposeBag)
    }

    // Apply snapshot to update data
    private func applySnapshot() {
        let snapshot = dataSource.generateSnapshot()
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateTitle() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        let price = String(
            format: "%.\(AppConstants.Formatting.priceDecimalPlaces)f", viewModel.totalBetPrice
        )

        title = "\(viewModel.bets.value.count) Event(s) - Total: " + price
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onEventTap?(viewModel.bets.value[indexPath.row].event)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            self.viewModel.removeBet(at: indexPath.row)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
