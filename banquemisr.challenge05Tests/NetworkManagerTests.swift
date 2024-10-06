//
//  NetworkManagerTests.swift
//  banquemisr.challenge05Tests
//
//  Created by Engy on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05

final class NetworkManagerTests: XCTestCase {

    var networkManager: NetworkManagerProtocol!
    
    override func setUpWithError() throws {
        networkManager = NetworkManager()
    }

    override func tearDownWithError() throws {
        networkManager = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

}
