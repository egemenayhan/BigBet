//
//  CartDataSource.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import UIKit

enum CartSection {
    case main
}

class CartDataSource: UITableViewDiffableDataSource<CartSection, Bet> {

    private var viewModel: CartViewModel

    init(viewModel: CartViewModel, tableView: UITableView, cellProvider: @escaping (UITableView, IndexPath, Bet) -> UITableViewCell) {
        self.viewModel = viewModel
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    func generateSnapshot() -> NSDiffableDataSourceSnapshot<CartSection, Bet> {
        var snapshot = NSDiffableDataSourceSnapshot<CartSection, Bet>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.bets)
        return snapshot
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
//            if let self = self {
//                self.viewModel.removeBet(at: indexPath.row)
//            }
//            completion(true)
//        }
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
}
