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
    let revenue: Int?
    let budget: Int?
    let adult: Bool
    let backdropPath: String
    let id: Int
    let originalLanguage: String
    let overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String
    let voteAverage: Double
    let voteCount: Int
    let genres: [Genre]?
    let runtime: Int?
    let tagline: String?

    enum CodingKeys: String, CodingKey {
        case adult, revenue, budget
        case backdropPath = "backdrop_path"
        case id
        case originalLanguage = "original_language"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genres, tagline, runtime
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

enum MovieImageType: String {
    case poster
    case backdrop
}

