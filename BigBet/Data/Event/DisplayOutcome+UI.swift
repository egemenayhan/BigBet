//
//  DisplayOutcome+UI.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit

// MARK: - UI Related Extensions
extension DisplayOutcome {
    
    var buttonDisplayText: String {
        String(format: "%.\(AppConstants.Formatting.priceDecimalPlaces)f\n%@", price, label.rawValue)
    }
    
    func buttonBackgroundColor(isSelected: Bool) -> UIColor {
        isSelected ? ThemeManager.current.primaryGreen : ThemeManager.current.oddUnselected
    }
    
    func buttonTextColor(isSelected: Bool) -> UIColor {
        isSelected ? .white : ThemeManager.current.textPrimary
    }
    
    func buttonBorderColor(isSelected: Bool) -> UIColor {
        isSelected ? ThemeManager.current.primaryGreen : ThemeManager.current.borderColor
    }
    
    var formattedPrice: String {
        String(format: "%.\(AppConstants.Formatting.priceDecimalPlaces)f", price)
    }
    
    var oddsCategory: OddsCategory {
        if price < 1.5 {
            .veryLow
        } else if price < 2.0 {
            .low
        } else if price < 3.0 {
            .medium
        } else if price < 5.0 {
            .high
        } else {
            .veryHigh
        }
    }
}

// MARK: - Supporting Types
extension DisplayOutcome {
    enum OddsCategory {
        case veryLow, low, medium, high, veryHigh
        
        var indicatorColor: UIColor {
            switch self {
            case .veryLow:
                .systemRed
            case .low:
                .systemOrange
            case .medium:
                .systemYellow
            case .high:
                .systemGreen
            case .veryHigh:
                .systemBlue
            }
        }
    }
} 
