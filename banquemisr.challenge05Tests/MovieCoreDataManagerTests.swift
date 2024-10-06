//
//  MovieCoreDataManagerTests.swift
//  banquemisr.challenge05Tests
//
//  Created by Engy on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05

final class MovieCoreDataManagerTests: XCTestCase {

    var coreDataManager: MovieCoreDataServiceProtocol!
    
    override func setUpWithError() throws {
        coreDataManager = MovieCoreDataManager.shared
        clearEntityCache()
    }

    override func tearDownWithError() throws {
        coreDataManager = nil
//        clearEntityCache()
    }

    func clearEntityCache() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            clearCoreData(for: "MovieEntity", context: context)
        }
    }
    
    func testSavingAndGettingMoviesFromCoreData() throws {
        var (movies, images) = coreDataManager.getMovies(category: .nowPlaying)
        XCTAssertEqual(movies.count, 0)
        
        coreDataManager.storeMovies(movies: [
            Movie(revenue: nil, budget: nil, adult: false, backdropPath: "/gZWl93sf8AxavYpVT1Un6EF3oCj.jpg", id: 475557, originalLanguage: "en", overview: "", popularity: 903.781, posterPath: "/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", releaseDate: "2019-10-01", title: "Joker", voteAverage: 8.154, voteCount: 25301, genres: nil, runtime: nil, tagline: nil)
        ], category: .nowPlaying)
        
        (movies, images) = coreDataManager.getMovies(category: .nowPlaying)
        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.count, images.count)
        XCTAssertEqual(movies.first?.id, 475557)
    }

    func testGettingMovieFromCoreData() throws {
        coreDataManager.storeMovies(movies: [
            Movie(revenue: nil, budget: nil, adult: false, backdropPath: "/gZWl93sf8AxavYpVT1Un6EF3oCj.jpg", id: 475557, originalLanguage: "en", overview: "", popularity: 903.781, posterPath: "/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", releaseDate: "2019-10-01", title: "Joker", voteAverage: 8.154, voteCount: 25301, genres: nil, runtime: nil, tagline: nil)
        ], category: .nowPlaying)
        
        let (movie, image) = coreDataManager.getMovie(forMovieWithId: 475557)
        XCTAssertEqual(movie?.id, 475557)
        XCTAssertEqual(movie?.title, "Joker")
        XCTAssertNil(image)
    }
    
    func testUpdateMovieFromCoreData() throws {
        coreDataManager.storeMovies(movies: [
            Movie(revenue: nil, budget: nil, adult: false, backdropPath: "/gZWl93sf8AxavYpVT1Un6EF3oCj.jpg", id: 475557, originalLanguage: "en", overview: "", popularity: 903.781, posterPath: "/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", releaseDate: "2019-10-01", title: "Joker", voteAverage: 8.154, voteCount: 25301, genres: nil, runtime: nil, tagline: nil)
        ], category: .nowPlaying)
        
        var (movie, _) = coreDataManager.getMovie(forMovieWithId: 475557)
        XCTAssertEqual(movie?.revenue, 0)
        XCTAssertEqual(movie?.budget, 0)
        XCTAssertNil(movie?.genres?.first)
        XCTAssertEqual(movie?.runtime, 0)
        XCTAssertNil(movie?.tagline)
        
        let updatedMovie = Movie(revenue: 500_000, budget: 1_000_000, adult: false, backdropPath: "/gZWl93sf8AxavYpVT1Un6EF3oCj.jpg", id: 475557, originalLanguage: "en", overview: "", popularity: 903.781, posterPath: "/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", releaseDate: "2019-10-01", title: "Joker", voteAverage: 8.154, voteCount: 25301, genres: [Genre(id: 1, name: "Horror")], runtime: 93, tagline: "Updated Tagline")
        
        coreDataManager.updateMovie(withId: 475557, updatedMovie: updatedMovie)
        
        (movie, _) = coreDataManager.getMovie(forMovieWithId: 475557)
        XCTAssertEqual(movie?.revenue, 500_000)
        XCTAssertEqual(movie?.budget, 1_000_000)
        XCTAssertEqual(movie?.genres?.first?.id, 1)
        XCTAssertEqual(movie?.genres?.first?.name, "Horror")
        XCTAssertEqual(movie?.runtime, 93)
        XCTAssertEqual(movie?.tagline, "Updated Tagline")
    }

    func testStoreMovieImage() throws {
        coreDataManager.storeMovies(movies: [
            Movie(revenue: nil, budget: nil, adult: false, backdropPath: "/gZWl93sf8AxavYpVT1Un6EF3oCj.jpg", id: 475557, originalLanguage: "en", overview: "", popularity: 903.781, posterPath: "/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", releaseDate: "2019-10-01", title: "Joker", voteAverage: 8.154, voteCount: 25301, genres: nil, runtime: nil, tagline: nil)
        ], category: .nowPlaying)
        
        let testingData = "Testing".data(using: .utf8) ?? Data()
        coreDataManager.storeMovieImage(testingData, forMovieWithId: 475557, imageType: .backdrop)
        
        let (_, image) = coreDataManager.getMovie(forMovieWithId: 475557)
        XCTAssertEqual(image, testingData)
    }
}
