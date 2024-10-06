//
//  MovieCellViewModelTests.swift
//  banquemisr.challenge05Tests
//
//  Created by Engy on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05

final class MovieCellViewModelTests: XCTestCase {

    var viewModel: MovieCellViewModel!
    var movie: Movie!
    
    override func setUpWithError() throws {
        viewModel = MovieCellViewModel()
        movie = Movie(revenue: nil, budget: nil, adult: false, backdropPath: "/gZWl93sf8AxavYpVT1Un6EF3oCj.jpg", id: 475557, originalLanguage: "en", overview: "", popularity: 903.781, posterPath: "/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", releaseDate: "2019-10-01", title: "Joker", voteAverage: 8.154, voteCount: 25301, genres: nil, runtime: nil, tagline: nil)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        movie = nil
    }

    func testLoadingImage() throws {
        let expectation = expectation(description: "Testing trying to load image from API")
        
        viewModel.setLoadingImage = {
            expectation.fulfill()
        }
        viewModel.loadImage(for: movie)
        
        waitForExpectations(timeout: 2)
    }
    
    func testLoadedImage() throws {
        let expectation = expectation(description: "Testing successful loaded image from API")
        
        viewModel.setLoadedImage = { _ in
            expectation.fulfill()
        }
        viewModel.loadImage(for: movie)
        
        waitForExpectations(timeout: 8)
    }

    func testNoPosterImage() throws {
        let expectation = expectation(description: "Testing no poster image because of wrong url")
                
        movie = Movie(revenue: nil, budget: nil, adult: false, backdropPath: "wrongUrlImagePath", id: 475557, originalLanguage: "en", overview: "", popularity: 903.781, posterPath: "wrongUrlImagePath", releaseDate: "2019-10-01", title: "Joker", voteAverage: 8.154, voteCount: 25301, genres: nil, runtime: nil, tagline: nil)
        
        viewModel.setNoPosterImage = {
            expectation.fulfill()
        }
        viewModel.loadImage(for: movie)
        
        waitForExpectations(timeout: 8)
    }

}
