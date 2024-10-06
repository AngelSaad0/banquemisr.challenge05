//
//  MovieRepositoryTests.swift
//  banquemisr.challenge05Tests
//
//  Created by Engy on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05

final class MovieRepositoryTests: XCTestCase {

    var movieRepository: MovieRepositoryProtocol!
    
    override func setUpWithError() throws {
        movieRepository = MovieRepository()
    }

    override func tearDownWithError() throws {
        movieRepository = nil
    }

    func testFetchingUpcomingMoviesFromAPI() throws {
        let expectation = expectation(description: "Testing successful fetching upcoming movies from API")
        movieRepository.fetchData(from: MovieAPIProvider.upcoming, responseType: Movies.self) { result, error in
            if error != nil {
                XCTFail()
            }
            guard let result = result else {
                XCTFail()
                return
            }
            XCTAssertGreaterThan(result.results.count, 0)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testFetchingMovieDetailsFromAPI() throws {
        let expectation = expectation(description: "Testing successful fetching movie details from API")
        movieRepository.fetchData(from: MovieAPIProvider.details(id: 475557), responseType: Movie.self) { result, error in
            if error != nil {
                XCTFail()
            }
            guard let result = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(result.id, 475557)
            XCTAssertEqual(result.title, "Joker")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testNetworkDecodingFailure() throws {
        let expectation = expectation(description: "Testing failure decoding movies from API because of wrong response type")
        movieRepository.fetchData(from: MovieAPIProvider.upcoming, responseType: Movie.self) { result, error in
            if result != nil {
                XCTFail()
            }
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.errorDescription, APIError.decodingFailure.errorDescription)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testLoadImageFromAPI() throws {
        let expectation = expectation(description: "Testing successful loading image from API")
        movieRepository.loadImage(from: "/gZWl93sf8AxavYpVT1Un6EF3oCj.jpg") { data in
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testFailureLoadImageFromAPI() throws {
        let expectation = expectation(description: "Testing failure loading image from API because of invalid image path")
        movieRepository.loadImage(from: "invalidPath") { data in
            XCTAssertNil(data)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
