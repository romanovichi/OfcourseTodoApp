//
//  TaskListViewModelTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 01.11.2024.
//
import XCTest
import RxSwift
import RxCocoa
@testable import OfcourseTodoApp

final class TaskListViewModelTests: XCTestCase {
    
    private var viewModel: TaskListViewModel!
    private var fetchTasksUseCase: MockFetchTasksUseCase!
    private var changeTaskStatusUseCase: MockChangeTaskStatusUseCase!
    private var actions: MockTaskListViewModelActions!
    private var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
        fetchTasksUseCase = nil
        changeTaskStatusUseCase = nil
        actions = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func setupEnvironment(fetchTasksUseCaseResult: Result<[TaskObject], ShowableError>? = nil,
                          changeTaskStatusUseCaseInitData: TaskObject? = nil) {
        
        fetchTasksUseCase = MockFetchTasksUseCase(result: fetchTasksUseCaseResult ?? .success([
            TaskObject(id: UUID(), title: "Test Task 1", comment: "", isCompleted: false),
            TaskObject(id: UUID(), title: "Test Task 2", comment: "", isCompleted: true)
        ]))
        
        changeTaskStatusUseCase = MockChangeTaskStatusUseCase(task: changeTaskStatusUseCaseInitData ??
            TaskObject(id: UUID(), title: "Test Task 1", comment: "", isCompleted: false)
        )
        
        actions = MockTaskListViewModelActions()
        let actions = self.actions.makeActions()
        
        viewModel = TaskListViewModel(
            fetchTasksUseCase: fetchTasksUseCase,
            changeTaskStatusUseCase: changeTaskStatusUseCase,
            actions: actions
        )
    }
    
    func test_didTapCompleteTask() async {
        // given
        let expectation = XCTestExpectation(description: "Data loaded and task status updated")

        setupEnvironment()
        await viewModel.initialLoad()

        viewModel.taskCellViewModels
            .skip(1)
            .subscribe(onNext: { taskCellViewModels in
                XCTAssertEqual(taskCellViewModels.count, 2)
                XCTAssertTrue(taskCellViewModels.first!.isCompleted)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        await viewModel.completeTaskWith(id: 0)
        
        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertTrue(fetchTasksUseCase.isFetchAllTasksCalled)
        XCTAssertTrue(changeTaskStatusUseCase.changeStatusForTaskCalled)
    }
    
    
    func test_didTapCompletionFilter() async {
        // given
        let expectation = XCTestExpectation(description: "Completion filter toggled")
        
        setupEnvironment(fetchTasksUseCaseResult: .success([
            TaskObject(id: UUID(), title: "Test Task 1", comment: "", isCompleted: false),
        ]))
        
        // when
        await viewModel.toggleCompletionFilter() // toggle to completed
        await viewModel.toggleCompletionFilter() // toggle to incompleted
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation])
        
        // then
        XCTAssertTrue(fetchTasksUseCase.isFetchIncompletedTasksCalled)
        XCTAssertTrue(fetchTasksUseCase.isFetchAllTasksCalled)
        
    }
    
    func test_didSelectTask() async {
        
        // given
        let expectation = XCTestExpectation()
        
        let taskToShow = TaskObject(id: UUID(), title: "Test Task 1", comment: "", isCompleted: false)
        setupEnvironment(fetchTasksUseCaseResult: .success([taskToShow]))
        await viewModel.initialLoad()
        
        expectation.fulfill()
        // when
        
        await fulfillment(of: [expectation])
        
        viewModel.showItemWith(id: 0)
        
        // then
        XCTAssertTrue(actions.didShowTaskDetails)
        XCTAssertEqual(actions.shownTask, taskToShow)
    }

    func test_dddNewTask() {
        
        // given
        setupEnvironment()
        
        // when
        viewModel.addNewTask()
        
        // then
        XCTAssertTrue(actions.didAddNewTask)
    }
    
    func test_initialLoadSucsess() async {

        // given
        let expectation = XCTestExpectation(description: "Data loaded")

        setupEnvironment()
        
        // when
        await viewModel.initialLoad()
        
        // then
        var taskCellViewModels: [TaskListCellViewModel]?
        viewModel.taskCellViewModels
            .subscribe(onNext: { fetchedTasks in
                taskCellViewModels = fetchedTasks
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        
        await fulfillment(of: [expectation])

        XCTAssertEqual(taskCellViewModels?.first?.title, "Test Task 1")
        XCTAssertEqual(taskCellViewModels?.count, 2)
        XCTAssertTrue(fetchTasksUseCase.isFetchAllTasksCalled)
    }

    func test_initialLoadWithFailure() async {
        // given
        let expectation = XCTestExpectation(description: "Data loaded")

        let error = ShowableError.fetchDatabaseError
        setupEnvironment(fetchTasksUseCaseResult: .failure(error))
        
        // when
        await viewModel.initialLoad()
        
        // then
        var tasks: [TaskListCellViewModel]?
        viewModel.taskCellViewModels
            .subscribe(onNext: { fetchedTasks in
                tasks = fetchedTasks
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        await fulfillment(of: [expectation])
        
        XCTAssertEqual(tasks?.count, 0)
        XCTAssertTrue(fetchTasksUseCase.isFetchAllTasksCalled)
    }
}
