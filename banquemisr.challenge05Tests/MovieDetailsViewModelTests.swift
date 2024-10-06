//
//  MovieDetailsViewModelTests.swift
//  banquemisr.challenge05Tests
//
//  Created by Engy on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05

final class MovieDetailsViewModelTests: XCTestCase {

    var viewModel: MovieDetailsViewModel!
    
    override func setUpWithError() throws {
        viewModel = MovieDetailsViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testLoadDataFromAPI() throws {
        viewModel.movieID = 475557
        
        let expectation = expectation(description: "Testing successful loading data from API")

        viewModel.setupUI = {
            XCTAssertNotNil(self.viewModel.movie)
            XCTAssertEqual(self.viewModel.movie?.title, "Joker")
            XCTAssertEqual(self.viewModel.movie?.runtime, 122)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 5)
    }
    
    func testLoadDataFromCoreData() throws {
        viewModel.movieID = 475557
        viewModel.connectivityManager = ConnectivityManagerDisconnectedMock()
        
        let expectation = expectation(description: "Testing successful loading data from CoreData")

        viewModel.setupUI = {
            XCTAssertNotNil(self.viewModel.movie)
            XCTAssertEqual(self.viewModel.movie?.title, "Joker")
            XCTAssertEqual(self.viewModel.movie?.runtime, 122)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 5)
    }
    
    func testLoadBackDropImageFromAPI() throws {
        viewModel.movieID = 475557
        
        let expectation = expectation(description: "Testing successful loading BackDrop Image from API")

        viewModel.setupUI = {
            self.viewModel.loadBackdropImage()
        }
        viewModel.setBackdropImage = { _ in
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 8)
    }
    
    func testLoadBackDropImageFromCoreData() throws {
        viewModel.movieID = 475557
        viewModel.connectivityManager = ConnectivityManagerDisconnectedMock()
        
        let expectation = expectation(description: "Testing successful loading BackDrop Image from CoreData")

        viewModel.setupUI = {
            self.viewModel.connectionState = false
            self.viewModel.loadBackdropImage()
        }
        viewModel.setBackdropImage = { _ in
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 5)
    }
    
    func testLoadBackDropImageFromCoreDataFail() throws {
        viewModel.movieID = 0
        viewModel.connectivityManager = ConnectivityManagerDisconnectedMock()
        
        let expectation = expectation(description: "Testing failure loading BackDrop Image from CoreData")

        viewModel.displayEmptyMessage = { _ in
            self.viewModel.connectionState = false
            self.viewModel.loadBackdropImage()
        }
        viewModel.displayImageEmptyMessage = { message in
            XCTAssertEqual(message.errorDescription, DataError.noCachedDataFound.errorDescription)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 8)
    }
    
    func testNoCoreDataManager() throws {
        let expectation = expectation(description: "Testing failure loading data because CoreData Manager is not set properly")
        
        viewModel.movieID = 475557
        viewModel.coreDataManager = nil
        viewModel.connectivityManager = ConnectivityManagerDisconnectedMock()
        
        viewModel.displayEmptyMessage = { message in
            XCTAssertEqual(message.errorDescription, DataError.noCoreDataAvailable.errorDescription)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 2)
    }
    
    func testNoCachedDataForCategory() throws {
        let expectation = expectation(description: "Testing failure loading data because CoreData has no cached data")
        
        viewModel.movieID = 475557
        viewModel.connectivityManager = ConnectivityManagerDisconnectedMock()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            clearCoreData(for: "MovieEntity", context: context)
        }
        
        viewModel.displayEmptyMessage = { message in
            XCTAssertEqual(message.errorDescription, DataError.noCachedDataFound.errorDescription)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 2)
    }

    func testCalculateRuntime() throws {
        XCTAssertEqual(viewModel.calculateRuntime(0), "⏲️ Currently not available")
        XCTAssertEqual(viewModel.calculateRuntime(67), "🕔1h 7m")
    }
    
    func testCalculatePopularity() {
        let noPopularityCase = viewModel.calculatePopularity(0)
        let lowPopularityCase = viewModel.calculatePopularity(300)
        let moderatePopularityCase = viewModel.calculatePopularity(700)
        let highPopularityCase = viewModel.calculatePopularity(1200)

        XCTAssertEqual(noPopularityCase.0, "Not Available")
        XCTAssertEqual(noPopularityCase.1, "")
        
        XCTAssertEqual(lowPopularityCase.0, "300 - Low")
        XCTAssertEqual(lowPopularityCase.1, Constants.lowPopularity)
        
        XCTAssertEqual(moderatePopularityCase.0, "700 - Moderate")
        XCTAssertEqual(moderatePopularityCase.1, Constants.moderatePopularity)
        
        XCTAssertEqual(highPopularityCase.0, "1200 - High")
        XCTAssertEqual(highPopularityCase.1, Constants.highPopularity)
    }

    func testFormattedVoteAverage() {
        XCTAssertEqual(viewModel.formattedVoteAverage(0.0), "No Rating Yet")
        XCTAssertEqual(viewModel.formattedVoteAverage(6.832), "★ 6.8")
    }
    
    func testFormattedGenres() {
        let genres = [
            Genre(id: 1, name: "Action"),
            Genre(id: 2, name: "Horror"),
            Genre(id: 3, name: "Drama")
        ]
        
        XCTAssertEqual(viewModel.formattedGenres(nil), "No Genres Available")
        XCTAssertEqual(viewModel.formattedGenres(genres), "Action | Horror | Drama")
    }
    
    func testFormattedAmount() {
        XCTAssertEqual(viewModel.formattedAmount(0), "Not available")
        XCTAssertEqual(viewModel.formattedAmount(10_000_000), "10,000,000$💰")
    }
}
