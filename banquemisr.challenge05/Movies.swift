//
//  Movies.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import Foundation

// MARK: - Movies
struct Movies: Codable {
    let results: [Movie]
}

// MARK: - Result
struct Movie: Codable {
    let id: Int
    let posterPath, backdropPath, releaseDate, title: String
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
    }
}

