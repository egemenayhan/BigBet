//
//  AppConstants.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import Foundation
import UIKit

enum AppConstants {
    
    enum Search {
        static let debounceTimeMilliseconds = 300
        static let cacheLimit = 50
        static let placeholder = "Search teams"
    }
    
    enum UI {
        static let cardCornerRadius: CGFloat = 8
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 20
        static let cellVerticalPadding: CGFloat = 10
        
        // Shadow properties
        static let shadowOpacity: Float = 0.2
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = CGSize(width: 0, height: 2)
        
        // Animation durations
        static let defaultAnimationDuration: TimeInterval = 0.3
        static let fastAnimationDuration: TimeInterval = 0.15
    }
    
    enum Network {
        static let cacheTimeoutSeconds: TimeInterval = 300 // 5 minutes
        static let requestTimeoutSeconds: TimeInterval = 30
        static let maxRetryAttempts = 3
    }
    
    enum Sports {
        static let defaultSportKey = "soccer_turkey_super_league"
        static let defaultRegion = "eu"
        static let defaultMarket = "h2h"
        static let defaultOddsFormat = "decimal"
        static let defaultDateFormat = "iso"
    }
    
    enum Formatting {
        static let priceDecimalPlaces = 2
        static let maxFractionDigits = 2
        
        // Date formatting
        static let shortDateStyle = DateFormatter.Style.short
        static let shortTimeStyle = DateFormatter.Style.short
    }
    
    enum Analytics {
        enum Events {
            static let eventDetailTap = "event_detail_tap"
            static let cartAdd = "cart_add"
            static let cartRemove = "cart_remove"
            static let searchPerformed = "search_performed"
        }
        
        enum Parameters {
            static let eventId = "event_id"
            static let eventName = "event_name"
            static let oddValue = "odd_value"
            static let searchTerm = "search_term"
        }
    }
    
    enum ErrorMessages {
        static let networkError = "Network connection failed. Please try again."
        static let dataParsingError = "Unable to load event data. Please try again."
        static let genericError = "Something went wrong. Please try again."
        static let noEventsFound = "No events found matching your search."
    }
} 
