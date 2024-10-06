//
//  MovieDetailsViewControllerTests.swift
//  banquemisr.challenge05UITests
//
//  Created by Mohamed Ayman on 06/10/2024.
//

import XCTest
@testable import banquemisr_challenge05

final class MovieDetailsViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        sleep(3)
        
        let firstMovieCell = app.tables.cells.firstMatch
        XCTAssertTrue(firstMovieCell.exists, "The first movie cell should exist")
        firstMovieCell.tap()
        
//        sleep(2)
//        
//        let runtimeLabel = app.staticTexts["Runtime: "]
//        XCTAssertTrue(runtimeLabel.exists, "Movie runtime label should exist in MovieDetailsViewController")
    }

}
