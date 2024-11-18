//
//  TaskViewModelTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 15.11.2024.
//

import XCTest
import RxSwift
@testable import OfcourseTodoApp

final class TaskViewModelTests: XCTestCase {
    
    private var viewModel: TaskViewModel!
    private var taskActionsUseCase: MockTaskActionsUseCase!
    private var addNewTaskUseCase: MockAddNewTaskUseCase!
    private var disposeBag: DisposeBag!
    private var actions: MockTaskViewModelActions!
    
    override func setUp() {
        super.setUp()
        actions = MockTaskViewModelActions()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
        taskActionsUseCase = nil
        addNewTaskUseCase = nil
        disposeBag = nil
        super.tearDown()
    }
    
    private func setupEnvironment(
        id: UUID?,
        fetchTaskResult: Result<TaskObject, ShowableError>? = nil,
        addNewTaskResult: Result<TaskObject, ShowableError>? = nil,
        updateTaskResult: Result<TaskObject, ShowableError>? = nil,
        removeTaskResult: Result<Bool, ShowableError>? = nil
    ) {
        taskActionsUseCase = MockTaskActionsUseCase(
            fetchTaskResult: fetchTaskResult ?? .success(TaskObject(id: UUID(), title: "Test Task", comment: "")),
            removeTaskResult: removeTaskResult ?? .success(true),
            updateTaskResult: updateTaskResult ?? .success(TaskObject(id: UUID(), title: "Updated Task", comment: "Updated Comment"))
        )
        
        addNewTaskUseCase = MockAddNewTaskUseCase(createTaskResult: addNewTaskResult ?? .success(TaskObject(id: UUID(), title: "New Task", comment: "")))
        
        viewModel = TaskViewModel(
            id: id,
            taskActionsUseCase: taskActionsUseCase,
            addNewTaskUseCase: addNewTaskUseCase,
            actions: actions.makeActions()
        )
    }

    func test_initialLoadFetchesTaskSuccessfully() async {
        
        // given
        let expectation = XCTestExpectation(description: "Task fetched successfully")
        let task = TaskObject(id: UUID(), title: "Test Task", comment: "")
        setupEnvironment(id: task.id, fetchTaskResult: .success(task))

        // when
        viewModel.fetchedTask
            .skip(1)
            .subscribe(onNext: { task in
                XCTAssertEqual(task?.title, "Test Task")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        await viewModel.initialLoad()
        
        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(taskActionsUseCase.isFetchTaskCalled)
    }

    func test_onSaveAddsNewTask() async {
        // given
        let expectation = XCTestExpectation(description: "New task added successfully")
        setupEnvironment(id: nil, addNewTaskResult: .success(TaskObject(id: UUID(), title: "New Task", comment: "New Comment")))

        // when
        await viewModel.onSave(title: "New Task", comment: "New Comment")
        expectation.fulfill()
        
        // then
        await fulfillment(of: [expectation])
        XCTAssertTrue(addNewTaskUseCase.isCreateTaskCalled)
        XCTAssertTrue(actions.didCloseCalled)
    }

    func test_onSaveUpdatesExistingTask() async {
        // given
        let initialLoadExpectation = XCTestExpectation(description: "Task fetched by id successfully")
        
        let taskID = UUID()
        setupEnvironment(id: taskID,
                         fetchTaskResult: .success(TaskObject(id: taskID, title: "Old Task", comment: "Old Comment")),
                         updateTaskResult: .success(TaskObject(id: taskID, title: "Updated Task", comment: "Updated Comment")))
        
        // when
        viewModel.fetchedTask
            .skip(1)
            .subscribe(onNext: { task in
                XCTAssertEqual(task?.title, "Old Task")
                XCTAssertEqual(task?.comment, "Old Comment")
                initialLoadExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        await viewModel.initialLoad()

        // then
        await fulfillment(of: [initialLoadExpectation], timeout: 1.0)
        XCTAssertTrue(taskActionsUseCase.isFetchTaskCalled)
        
        // given
        let onSaveExpectation = XCTestExpectation(description: "Existing task updated successfully")

        // when
        await viewModel.onSave(title: "Updated Task", comment: "Updated Comment")
        onSaveExpectation.fulfill()

        // then
        await fulfillment(of: [onSaveExpectation], timeout: 1.0)
        XCTAssertTrue(taskActionsUseCase.isUpdateTaskCalled)
        XCTAssertTrue(actions.didCloseCalled)
    }

    func test_onDeleteRemovesTaskSuccessfully() async {
        // given
        let initialLoadExpectation = XCTestExpectation(description: "Task fetched by id successfully")
        let taskID = UUID()
        setupEnvironment(id: taskID,
                         fetchTaskResult: .success(TaskObject(id: taskID, title: "Task to Delete", comment: "")),
                         removeTaskResult: .success(true))
        
        await viewModel.initialLoad()
        
        // then
        XCTAssertTrue(taskActionsUseCase.isFetchTaskCalled)

        // given
        let onDeleteExpectation = XCTestExpectation(description: "Task deleted successfully")

        // when
        await viewModel.onDelete()
        onDeleteExpectation.fulfill()

        
        await fulfillment(of: [onDeleteExpectation], timeout: 1.0)
        XCTAssertTrue(taskActionsUseCase.isRemoveTaskCalled)
        XCTAssertTrue(actions.didCloseCalled)
    }
    
    func test_onSaveWithFailedUpdateShowsError() async {
        // given
        let expectation = XCTestExpectation(description: "Error shown for failed update")
        let expectedError = ShowableError.createNewTaskError
        setupEnvironment(id: UUID(), updateTaskResult: .failure(expectedError))
        
        await viewModel.initialLoad()
        
        // when
        await viewModel.onSave(title: "New Title", comment: "New Comment")
        
        viewModel.error
            .skip(1)
            .subscribe(onNext: { errorMessage in
                XCTAssertEqual(errorMessage, ErrorMapper.mapToDescription(showableError: expectedError), "Expected error message")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(taskActionsUseCase.isUpdateTaskCalled)
    }
}
