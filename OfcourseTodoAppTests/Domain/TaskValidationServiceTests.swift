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

    func testValidateTitle_WhenTitleIsEmpty_ReturnsEmptyTitleError() {
        let result = validationService.validateTitle("")
        XCTAssertEqual(result, .validationError, "Validation should return emptyTitle error for empty title")
    }

    func testValidateTitle_WhenTitleIsTooLong_ReturnsTitleTooLongError() {
        let longTitle = String(repeating: "a", count: 101) // 101 characters long
        let result = validationService.validateTitle(longTitle)
        XCTAssertEqual(result, .validationError, "Validation should return titleTooLong error for titles longer than 100 characters")
    }

    func testValidateTitle_WhenTitleIsValid_ReturnsNil() {
        let validTitle = "Valid Task Title"
        let result = validationService.validateTitle(validTitle)
        XCTAssertNil(result, "Validation should return nil for valid title")
    }
}
