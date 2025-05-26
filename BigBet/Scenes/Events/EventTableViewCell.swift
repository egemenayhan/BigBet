//
//  EventTableViewCell.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    static let identifier = "EventTableViewCell"

    var onOddTapped: ((Int?) -> Void)? {
        didSet {
            eventCardView.onOddTapped = onOddTapped
        }
    }

    private(set) var event: BetEvent?
    private let eventCardView = EventCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.layer.shadowColor = ThemeManager.current.cardShadowColor.cgColor
        contentView.layer.shadowOffset = AppConstants.UI.shadowOffset
        contentView.layer.shadowOpacity = AppConstants.UI.shadowOpacity
        contentView.layer.shadowRadius = AppConstants.UI.shadowRadius
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        contentView.backgroundColor = .clear

        contentView.addSubview(eventCardView)

        eventCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppConstants.UI.cellVerticalPadding),
            eventCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppConstants.UI.defaultPadding),
            eventCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppConstants.UI.defaultPadding),
            eventCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppConstants.UI.cellVerticalPadding)
        ])
    }

    func configure(with event: BetEvent, selectedIndex: Int?) {
        self.event = event
        eventCardView.configure(with: event, selectedIndex: selectedIndex)
    }
}
