//
//  EventCardView.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//


import UIKit

class EventCardView: UIView {

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let infoStack = UIStackView()
    private let oddsStack = UIStackView()
    private let mainStack = UIStackView()
    
    private var oddButtons: [SelectableOddButton] = []
    
    var onOddTapped: ((Int?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Setup the card view container
        self.layer.cornerRadius = 8
        self.layer.borderColor = ThemeManager.current.borderColor.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = ThemeManager.current.cardBackground

        // Main vertical stack
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])

        // Info stack (team name left, time right)
        infoStack.axis = .horizontal
        infoStack.alignment = .center
        infoStack.distribution = .fill
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = ThemeManager.current.textPrimary
        titleLabel.numberOfLines = 0

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = ThemeManager.current.textSecondary
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

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
