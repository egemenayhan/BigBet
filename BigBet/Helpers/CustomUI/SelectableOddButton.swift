//
//  SelectableOddButton.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit

class SelectableOddButton: UIButton {

    var isOddSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor
        titleLabel?.font = ThemeManager.current.oddsFont
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        setTitleColor(.label, for: .normal)
        backgroundColor = .systemGray6
    }

    private func updateAppearance() {
        backgroundColor = isOddSelected ? ThemeManager.current.primaryGreen : ThemeManager.current.oddUnselected
        setTitleColor(isOddSelected ? ThemeManager.current.textPrimary : ThemeManager.current.textSecondary, for: .normal)
    }
}
