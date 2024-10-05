//
//  Movies.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//
import Foundation

// MARK: - Movies
struct Movies: Codable {
    let dates: Dates?
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case dates, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Dates
struct Dates: Codable {
    let maximum, minimum: String
}

// MARK: - Result
struct Movie: Codable {
    let revenue: Int?
    let budget: Int?
    let adult: Bool
    let backdropPath: String
    let genreIDS: [Int]?
    let id: Int
    let originalLanguage: String
    let originalTitle, overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    let genres: [Genre]?
    let runtime: Int?
    let tagline: String?

    enum CodingKeys: String, CodingKey {
        case adult, revenue, budget
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genres, tagline, runtime
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

