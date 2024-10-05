//
//  MovieApi.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import Foundation
enum MovieAPIProvider
 {
    private static let baseUrl = "https://api.themoviedb.org/3/movie/"
    private static let apiKey = "30dafbee1b24fdef15b88ce161deecc2"

    case nowPlaying
    case popular
    case upcoming
    case details(id: Int)

    var path: String {
        switch self {
        case .nowPlaying:
            return "now_playing"
        case .popular:
            return "popular"
        case .upcoming:
            return "upcoming"
        case .details(let id):
            return "\(id)"
        }
    }

    var urlString: String {
        return "\(MovieAPIProvider.baseUrl)\(self.path)?api_key=\(MovieAPIProvider.apiKey)"
    }

    var title: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .popular:
            return "Popular"
        case .upcoming:
            return "Upcoming"
        default: 
            return ""
        }
    }
}
