//
//  TaskValidationServiceTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import XCTest
@testable import OfcourseTodoApp

final class TaskValidationServiceTests: XCTestCase {
    
    var validationService: TaskValidationServiceProtocol!

    override func setUpWithError() throws {
        super.setUp()
        validationService = TaskValidationService()
    }

    override func tearDownWithError() throws {
        validationService = nil
        super.tearDown()
    }

    func test_validateEmptyTitle() {
        let result = validationService.validateTitle("")
        XCTAssertEqual(result, .titleIsEmptyError, "Validation should return emptyTitle error for empty title")
    }

    func test_validateLongTitle() {
        let longTitle = String(repeating: "a", count: 101)
        let result = validationService.validateTitle(longTitle)
        XCTAssertEqual(result, .titleTooLongError, "Validation should return titleTooLong error for titles longer than 100 characters")
    }

    func test_validateValidTitle() {
        let validTitle = "Valid Task Title"
        let result = validationService.validateTitle(validTitle)
        XCTAssertNil(result, "Validation should return nil for valid title")
    }
}
