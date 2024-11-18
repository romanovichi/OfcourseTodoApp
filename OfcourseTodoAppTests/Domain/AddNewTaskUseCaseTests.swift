//
//  TaskUseCaseTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import XCTest
@testable import OfcourseTodoApp

final class AddNewTaskUseCaseTests: XCTestCase {
    
    private var taskRepositoryMock: MockTaskRepository!
    private var taskValidationServiceMock: MockTaskValidationService!
    private var useCase: AddNewTaskUseCase!
    
    override func setUp() {
        super.setUp()
        taskRepositoryMock = MockTaskRepository()
        taskValidationServiceMock = MockTaskValidationService()
        useCase = AddNewTaskUseCase(taskRepository: taskRepositoryMock,
                                    taskValidationService: taskValidationServiceMock)
    }
    
    override func tearDown() {
        taskRepositoryMock = nil
        taskValidationServiceMock = nil
        useCase = nil
        super.tearDown()
    }
    
    func test_createTask_success() async {
        // given
        let expectedTask = TaskObject(id: UUID(), title: "Valid Title", comment: "Valid Comment")
        taskValidationServiceMock.validateTitleError = nil
        taskValidationServiceMock.validateCommentError = nil
        
        // when
        let result = await useCase.createTask(title: "Valid Title", comment: "Valid Comment")
        
        // then
        switch result {
        case .success(let task):
            XCTAssertEqual(task.title, expectedTask.title)
            XCTAssertEqual(task.comment, expectedTask.comment)
        case .failure:
            XCTFail("Expected success but got failure")
        }
        
        XCTAssertTrue(taskValidationServiceMock.validateTitleCalled)
        XCTAssertTrue(taskValidationServiceMock.validateCommentCalled)
        XCTAssertTrue(taskRepositoryMock.saveTaskCalled)
    }
    
    func test_createTask_titleValidationError() async {
        // given
        let validationError = ShowableError.titleIsEmptyError
        taskValidationServiceMock.validateTitleError = validationError
        
        // when
        let result = await useCase.createTask(title: "Invalid Title", comment: "Valid Comment")
        
        // then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, validationError)
        }
        
        XCTAssertTrue(taskValidationServiceMock.validateTitleCalled)
        XCTAssertFalse(taskRepositoryMock.saveTaskCalled)
    }
    
    func test_createTask_commentValidationError() async {
        // given
        let validationError = ShowableError.commentTooLongError
        taskValidationServiceMock.validateCommentError = validationError
        
        // when
        let result = await useCase.createTask(title: "Valid Title", comment: "Invalid Comment")
        
        // then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, validationError)
        }
        
        XCTAssertTrue(taskValidationServiceMock.validateCommentCalled)
        XCTAssertFalse(taskRepositoryMock.saveTaskCalled)
    }
    
    func test_createTask_saveTaskError() async {
        // given
        taskValidationServiceMock.validateTitleError = nil
        taskValidationServiceMock.validateCommentError = nil
        taskRepositoryMock.errorResult = .failure(ShowableError.createNewTaskError)
        
        // when
        let result = await useCase.createTask(title: "Valid Title", comment: "Valid Comment")
        
        // then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, ShowableError.createNewTaskError)
        }
        
        XCTAssertTrue(taskValidationServiceMock.validateTitleCalled)
        XCTAssertTrue(taskValidationServiceMock.validateCommentCalled)
        XCTAssertTrue(taskRepositoryMock.saveTaskCalled)
    }
}
