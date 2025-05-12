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
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 4
        contentView.backgroundColor = .clear

        contentView.addSubview(eventCardView)

        eventCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            eventCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            eventCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            eventCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with event: BetEvent, selectedIndex: Int?) {
        self.event = event
        eventCardView.configure(with: event, selectedIndex: selectedIndex)
    }
}
