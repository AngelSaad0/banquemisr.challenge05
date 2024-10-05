//
//  MovieError.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/4/24.
//
import Foundation

enum APIError: LocalizedError {
    case responseMalformed
    case endpointUnavailable
    case networkIssue
    case emptyResponse
    case decodingFailure
    case noInternetConnection
    var errorDescription: String? {
        switch self {
        case .responseMalformed:
            return NSLocalizedString("🚫 The server response is malformed.\n Please try again later.", comment: "Malformed Response")
        case .endpointUnavailable:
            return NSLocalizedString("🔗 The API endpoint is not available. \nCheck the API status.", comment: "Unavailable Endpoint")
        case .emptyResponse:
            return NSLocalizedString("📭 Received an empty response from the server.\nPlease check the request.", comment: "Empty Response")
        case .decodingFailure:
            return NSLocalizedString("🛠️ Unable to decode the response data.\nPlease contact support.", comment: "Decoding Failure")
        case .networkIssue:
            return NSLocalizedString("🌐 There was a problem connecting to the API.\nPlease check your connection.", comment: "Network Issue")
        case .noInternetConnection:
            return NSLocalizedString("📶 You are not connected to the internet or the connection is unstable.\nPlease try again.", comment: "No Internet Connection")
            
        }
    }


}
