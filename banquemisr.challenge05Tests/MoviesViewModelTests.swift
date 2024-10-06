//
//  MoviesViewModelTests.swift
//  banquemisr.challenge05Tests
//
//  Created by Engy on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05

final class MoviesViewModelTests: XCTestCase {

    var viewModel: MoviesViewModel!
    
    override func setUpWithError() throws {
        viewModel = MoviesViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testLoadDataFromAPI() throws {
        let category = MovieAPIProvider.nowPlaying
        viewModel.moviesCategory = category
        viewModel.navigationTitle = category.title
        
        let expectation = expectation(description: "Testing successful loading data from API")
        
        viewModel.bindDataToTableView = {
            XCTAssertGreaterThan(self.viewModel.movieList.count, 0)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 5)
    }
    
    

    func testLoadDataFromCoreData() throws {
        let category = MovieAPIProvider.nowPlaying
        viewModel.moviesCategory = category
        viewModel.navigationTitle = category.title
        viewModel.connectivityManager = ConnectivityManagerDisconnectedMock()
        
        let expectation = expectation(description: "Testing successful loading data from CoreData")
        
        viewModel.bindDataToTableView = {
            XCTAssertGreaterThan(self.viewModel.movieList.count, 0)
            XCTAssertEqual(self.viewModel.movieList.count, self.viewModel.movieImages.count)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 5)
    }
    
    
    func testLoadDataCategoryFailure() throws {
        let expectation = expectation(description: "Testing failure loading data because category is missing")
        
        viewModel.displayEmptyMessage = { message in
            XCTAssertEqual(message.errorDescription, DataError.unknownError.errorDescription)
            expectation.fulfill()
        }
        viewModel.loadData()
        
        waitForExpectations(timeout: 2)
    }
    
    func testNoCoreDataManager() throws {
        let expectation = expectation(description: "Testing failure loading data because CoreData Manager is not set properly")
        
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
        
        let category = MovieAPIProvider.popular
        viewModel.moviesCategory = category
        viewModel.navigationTitle = category.title
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

}

