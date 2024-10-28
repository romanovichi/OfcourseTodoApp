//
//  TaskUseCaseTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import XCTest
@testable import OfcourseTodoApp

final class TaskUseCaseTests: XCTestCase {

    var mockRepository: MockTaskRepository!
    var mockValidationService: MockTaskValidationService!
    var useCase: TaskUseCase!

    override func setUpWithError() throws {
        mockRepository = MockTaskRepository()
        mockValidationService = MockTaskValidationService()
        useCase = TaskUseCase(taskRepository: mockRepository, taskValidationService: mockValidationService)
    }

    override func tearDownWithError() throws {
        mockRepository = nil
        mockValidationService = nil
        useCase = nil
    }

    func testCreateTask_Success() async {

        mockValidationService.validationError = nil

        let result = await useCase.createTask(title: "Valid Task", comment: "A valid task comment")

        switch result {
        case .success(let task):
            XCTAssertEqual(task.title, "Valid Task")
            XCTAssertEqual(task.comment, "A valid task comment")
        case .failure:
            XCTFail("Expected task creation to succeed")
        }
    }

    func testCreateTask_Failure_EmptyTitle() async {

        mockValidationService.validationError = .emptyTitle

        let result = await useCase.createTask(title: "", comment: "A valid comment")

        switch result {
        case .success:
            XCTFail("Expected task creation to fail due to empty title")
        case .failure(let error):
            XCTAssertEqual(error as? ValidationError, .emptyTitle)
        }
    }

    func testCreateTask_Failure_TitleTooLong() async {

        mockValidationService.validationError = .titleTooLong

        let result = await useCase.createTask(title: String(repeating: "a", count: 101), comment: "A valid comment")

        switch result {
        case .success:
            XCTFail("Expected task creation to fail due to title being too long")
        case .failure(let error):
            XCTAssertEqual(error as? ValidationError, .titleTooLong)
        }
    }
}
