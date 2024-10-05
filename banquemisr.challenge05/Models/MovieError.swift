//
//  MovieError.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/4/24.
//
import Foundation

enum MovieError: Error, CustomNSError {
    case responseMalformed
    case endpointUnavailable
    case networkIssue
    case emptyResponse
    case decodingFailure
    case noInternetConnection

    var localizedDescription: String {
        switch self {
        case .responseMalformed:
            return NSLocalizedString("The server response is malformed.", comment: "Malformed Response")
        case .endpointUnavailable:
            return NSLocalizedString("The API endpoint is not available.", comment: "Unavailable Endpoint")
        case .emptyResponse:
            return NSLocalizedString("Received an empty response from the server.", comment: "Empty Response")
        case .decodingFailure:
            return NSLocalizedString("Unable to decode the response data.", comment: "Decoding Failure")
        case .networkIssue:
            return NSLocalizedString("There was a problem connecting to the API.", comment: "Network Issue")
        case .noInternetConnection:
            return NSLocalizedString("You are not connected to the internet or the connection is unstable.", comment: "No Internet Connection")
        }
    }

    var errorUserInfo: [String: Any] {
        return [NSLocalizedDescriptionKey: localizedDescription]
    }
}
