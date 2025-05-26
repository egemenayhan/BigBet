//
//  Theme.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//


import UIKit

enum Theme: String {
    case bilyoner
    case light
    case dark

    // MARK: - Colors
    var background: UIColor {
        switch self {
        case .bilyoner: UIColor(hex: "#121212")
        case .light:    .white
        case .dark:     UIColor(hex: "#000000")
        }
    }

    var cardBackground: UIColor {
        switch self {
        case .bilyoner: UIColor(hex: "#1E1E1E")
        case .light:    UIColor(hex: "#F2F2F7")
        case .dark:     UIColor(hex: "#1C1C1E")
        }
    }

    var cardShadowColor: UIColor {
        switch self {
        case .bilyoner: UIColor.white.withAlphaComponent(0.3)
        case .light:    UIColor.black.withAlphaComponent(0.1)
        case .dark:     UIColor.white.withAlphaComponent(0.4)
        }
    }

    var textPrimary: UIColor {
        switch self {
        case .bilyoner: .white
        case .light:    .black
        case .dark:     .white
        }
    }

    var textSecondary: UIColor {
        switch self {
        case .bilyoner: UIColor(hex: "#9E9E9E")
        case .light:    .darkGray
        case .dark:     UIColor(hex: "#B0B0B0")
        }
    }

    var primaryGreen: UIColor {
        switch self {
        case .bilyoner: UIColor(hex: "#00B671")
        case .light:    UIColor.systemGreen
        case .dark:     UIColor(hex: "#00B671")
        }
    }

    var oddUnselected: UIColor {
        switch self {
        case .bilyoner: UIColor(hex: "#2A2A2D")
        case .light:    UIColor.systemGray5
        case .dark:     UIColor(hex: "#2C2C2E")
        }
    }

    var borderColor: UIColor {
        switch self {
        case .bilyoner: UIColor(hex: "#2A2A2D")
        case .light:    UIColor.systemGray4
        case .dark:     UIColor(hex: "#3A3A3C")
        }
    }

    var accentYellow: UIColor {
        UIColor(hex: "#FFD600") // Same across themes
    }

    var errorRed: UIColor {
        UIColor(hex: "#FF3B30") // Same across themes
    }

    var navBarBackgroundColor: UIColor {
        switch self {
        case .bilyoner: UIColor(hex: "#1E1E1E")
        case .light:    .white
        case .dark:     UIColor(hex: "#121212")
        }
    }

    var navBarTitleColor: UIColor {
        switch self {
        case .bilyoner: .white
        case .light:    .black
        case .dark:     .white
        }
    }

    var navBarTintColor: UIColor {
        navBarTitleColor // icons & back button
    }

    // MARK: - Fonts

    var titleFont: UIFont {
        UIFont.boldSystemFont(ofSize: 16)
    }

    var oddsFont: UIFont {
        UIFont.systemFont(ofSize: 14, weight: .bold)
    }

    var detailFont: UIFont {
        UIFont.systemFont(ofSize: 13)
    }
}

class ThemeManager {
    static var current: Theme = .bilyoner
}
