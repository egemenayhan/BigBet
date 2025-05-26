//
//  BetEvent+UI.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import UIKit

// MARK: - UI Related Extensions
extension BetEvent {
    
    var displayTitle: String {
        "\(homeTeam) - \(awayTeam)"
    }
    
    var displayDate: String {
        Self.sharedDateFormatter.string(from: commenceTime)
    }
    
    var statusTextColor: UIColor {
        if commenceTime < Date() {
            ThemeManager.current.textSecondary
        } else {
            ThemeManager.current.textPrimary
        }
    }
    
    var timeUntilEvent: String {
        let timeInterval = commenceTime.timeIntervalSinceNow
        
        if timeInterval < 0 {
            return "Started"
        } else {
            let hours = Int(timeInterval) / 3600
            let minutes = Int(timeInterval) % 3600 / 60
            
            if hours > 24 {
                let days = hours / 24
                return "\(days)d \(hours % 24)h"
            } else if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
    }
    
    var isLive: Bool {
        commenceTime <= Date()
    }
    
    var cardBackgroundColor: UIColor {
        isLive ? ThemeManager.current.cardBackground.withAlphaComponent(0.8) : ThemeManager.current.cardBackground
    }
}

// MARK: - Search Related Extensions
extension BetEvent {
    
    var searchableText: String {
        "\(homeTeam) \(awayTeam) \(sportTitle)".lowercased()
    }
    
    func matches(searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        
        let lowercasedSearch = searchText.lowercased()
        return homeTeam.localizedCaseInsensitiveContains(lowercasedSearch) ||
               awayTeam.localizedCaseInsensitiveContains(lowercasedSearch) ||
               sportTitle.localizedCaseInsensitiveContains(lowercasedSearch)
    }
} 
