//
//  BetTableVIewCell.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import UIKit

class BetTableViewCell: UITableViewCell {

    static let identifier = "BetTableViewCell"

    private let teamLabel = UILabel()
    private let dateLabel = UILabel()
    private let betOutcomeLabel = UILabel()
    private let deleteButton = UIButton()

    var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Setup UI elements
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = ThemeManager.current.cardBackground

        // Configure labels
        teamLabel.font = ThemeManager.current.titleFont
        dateLabel.font = ThemeManager.current.detailFont
        betOutcomeLabel.font = ThemeManager.current.oddsFont
        betOutcomeLabel.textColor = ThemeManager.current.primaryGreen

        // Configure text color based on the theme
        teamLabel.textColor = ThemeManager.current.textPrimary
        dateLabel.textColor = ThemeManager.current.textSecondary

        // Configure delete button
        deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        deleteButton.tintColor = ThemeManager.current.errorRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // Horizontal stack view for team and date
        let teamDateStackView = UIStackView(arrangedSubviews: [teamLabel, UIView(), dateLabel])
        teamDateStackView.axis = .horizontal
        teamDateStackView.spacing = AppConstants.UI.smallPadding
        teamDateStackView.alignment = .center
        teamDateStackView.distribution = .fill

        let detailStackView = UIStackView(arrangedSubviews: [betOutcomeLabel, UIView(), deleteButton])
        detailStackView.axis = .horizontal
        detailStackView.spacing = AppConstants.UI.smallPadding
        detailStackView.alignment = .center
        detailStackView.distribution = .fill

        // Stack view for team, date, and bet outcome
        let mainStackView = UIStackView(arrangedSubviews: [teamDateStackView, detailStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 5
        mainStackView.distribution = .fill

        contentView.addSubview(mainStackView)

        // Set constraints
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        // Constraints for main stack view and delete button
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppConstants.UI.defaultPadding),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppConstants.UI.cellVerticalPadding),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppConstants.UI.cellVerticalPadding),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppConstants.UI.defaultPadding)
        ])
    }

    // Configure the cell with data
    func configure(with bet: Bet) {
        teamLabel.text = bet.event.displayTitle
        dateLabel.text = bet.event.timeUntilEvent
        betOutcomeLabel.text = bet.displayOutcome
        betOutcomeLabel.textColor = bet.outcomeColor
    }

    @objc func deleteTapped() {
        onDelete?()
    }
}
