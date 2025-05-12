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
        case .bilyoner: return UIColor(hex: "#121212")
        case .light:    return .white
        case .dark:     return UIColor(hex: "#000000")
        }
    }

    var cardBackground: UIColor {
        switch self {
        case .bilyoner: return UIColor(hex: "#1E1E1E")
        case .light:    return UIColor(hex: "#F2F2F7")
        case .dark:     return UIColor(hex: "#1C1C1E")
        }
    }

    var cardShadowColor: UIColor {
        switch self {
        case .bilyoner: return UIColor.white.withAlphaComponent(0.3)
        case .light:    return UIColor.black.withAlphaComponent(0.1)
        case .dark:     return UIColor.white.withAlphaComponent(0.4)
        }
    }

    var textPrimary: UIColor {
        switch self {
        case .bilyoner: return .white
        case .light:    return .black
        case .dark:     return .white
        }
    }

    var textSecondary: UIColor {
        switch self {
        case .bilyoner: return UIColor(hex: "#9E9E9E")
        case .light:    return .darkGray
        case .dark:     return UIColor(hex: "#B0B0B0")
        }
    }

    var primaryGreen: UIColor {
        switch self {
        case .bilyoner: return UIColor(hex: "#00B671")
        case .light:    return UIColor.systemGreen
        case .dark:     return UIColor(hex: "#00B671")
        }
    }

    var oddUnselected: UIColor {
        switch self {
        case .bilyoner: return UIColor(hex: "#2A2A2D")
        case .light:    return UIColor.systemGray5
        case .dark:     return UIColor(hex: "#2C2C2E")
        }
    }

    var borderColor: UIColor {
        switch self {
        case .bilyoner: return UIColor(hex: "#2A2A2D")
        case .light:    return UIColor.systemGray4
        case .dark:     return UIColor(hex: "#3A3A3C")
        }
    }

    var accentYellow: UIColor {
        return UIColor(hex: "#FFD600") // Same across themes
    }

    var errorRed: UIColor {
        return UIColor(hex: "#FF3B30") // Same across themes
    }

    var navBarBackgroundColor: UIColor {
        switch self {
        case .bilyoner: return UIColor(hex: "#1E1E1E")
        case .light:    return .white
        case .dark:     return UIColor(hex: "#121212")
        }
    }

    var navBarTitleColor: UIColor {
        switch self {
        case .bilyoner: return .white
        case .light:    return .black
        case .dark:     return .white
        }
    }

    var navBarTintColor: UIColor {
        return navBarTitleColor // icons & back button
    }

    // MARK: - Fonts

    var titleFont: UIFont {
        return UIFont.boldSystemFont(ofSize: 16)
    }

    var oddsFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .bold)
    }

    var detailFont: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }
}

class ThemeManager {
    static var current: Theme = .bilyoner
}
