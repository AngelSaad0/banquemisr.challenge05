//
//  DataError.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/5/24.
//


import Foundation

enum DataError:LocalizedError {
    case noCoreDataAvailable
    case noCachedDataFound
    case networkError
    case dataCorruption
    case permissionDenied
    case unknownError

    var errorDescription: String? {
        switch self {
        case .noCoreDataAvailable:
            return "📁❌ No Core Data Available.\nPlease ensure your data source is set up correctly and try again later."
        case .noCachedDataFound :
            return "🗄️😕 No Cached Data Found.\nPlease pull to refresh and check if new data is available! 🔄"
        case .networkError :
            return  "🌐⚠️ Network Error.\nPlease check your internet connection and try again. 📶"
        case .dataCorruption :
            return "🚫🛠️ Data Corruption Detected.\nPlease restart the app or clear the cache."
        case .permissionDenied :
            return  "🔒🚫 Permission Denied.\nPlease check your app settings to allow access."
        case .unknownError :
            return "❓⚠️ An unknown error occurred.\nPlease try again or contact support if the issue persists. 📞"

        }
    }
}
