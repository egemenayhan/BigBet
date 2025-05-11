//
//  EventTableViewCell.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    static let identifier = "EventTableViewCell"

    var onOddTapped: ((Int?) -> Void)?

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let infoStack = UIStackView()
    private let oddsStack = UIStackView()
    private let mainStack = UIStackView()

    private var oddButtons: [SelectableOddButton] = []

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

        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 8
        cardView.layer.borderColor = ThemeManager.current.borderColor.cgColor
        cardView.layer.borderWidth = 1
        cardView.backgroundColor = ThemeManager.current.cardBackground
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        // Main vertical stack
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])

        // Info stack (team name left, time right)
        infoStack.axis = .horizontal
        infoStack.alignment = .center
        infoStack.distribution = .fill
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = ThemeManager.current.textPrimary

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = ThemeManager.current.textSecondary

        infoStack.addArrangedSubview(titleLabel)
        infoStack.addArrangedSubview(UIView()) // spacer
        infoStack.addArrangedSubview(dateLabel)
        mainStack.addArrangedSubview(infoStack)

        // Odds horizontal stack
        oddsStack.axis = .horizontal
        oddsStack.spacing = 8
        oddsStack.distribution = .fillEqually
        oddsStack.alignment = .fill
        oddsStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(oddsStack)
    }

    // Configure with event + selectedIndex (from ViewModel)
    func configure(with event: BetEvent, selectedIndex: Int?) {
        titleLabel.text = event.displayTitle
        dateLabel.text = event.displayDate

        // Clear old buttons
        oddButtons.forEach { $0.removeFromSuperview() }
        oddButtons.removeAll()

        for (i, outcome) in event.odds.enumerated() {
            let button = SelectableOddButton()
            button.setTitle(String(format: "%.2f\n%@", outcome.price, outcome.label.rawValue), for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(oddTapped(_:)), for: .touchUpInside)
            oddsStack.addArrangedSubview(button)
            oddButtons.append(button)
        }

        applySelection(at: selectedIndex)
    }

    private func applySelection(at selectedIndex: Int?) {
        for (i, button) in oddButtons.enumerated() {
            button.isOddSelected = (i == selectedIndex)
        }
    }

    @objc private func oddTapped(_ sender: UIButton) {
        guard let tappedIndex = oddButtons.firstIndex(of: sender as! SelectableOddButton) else { return }
        let isAlreadySelected = oddButtons[tappedIndex].isOddSelected
        onOddTapped?(isAlreadySelected ? nil : tappedIndex)
    }
}
