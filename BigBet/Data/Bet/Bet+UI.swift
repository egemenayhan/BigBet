//
//  Bet+UI.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import UIKit

// MARK: - UI Related Extensions
extension Bet {
    
    var displayOutcome: String {
        "\(odd.label.rawValue) - \(String(format: "%.\(AppConstants.Formatting.priceDecimalPlaces)f", odd.price))"
    }
    
    var outcomeColor: UIColor {
        ThemeManager.current.primaryGreen
    }
    
    var cellBackgroundColor: UIColor {
        ThemeManager.current.cardBackground
    }
    
    var selectedBorderColor: UIColor {
        ThemeManager.current.primaryGreen
    }
} 
