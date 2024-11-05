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

        let testTask = TaskObject(id: UUID(), title: "Test Task 1", comment: "", isCompleted: false)

        setupEnvironment(fetchTasksUseCaseResult: .success([testTask]),
                         changeTaskStatusUseCaseInitData: testTask)
        
        await viewModel.initialLoad()

        viewModel.taskCellViewModels
            .skip(1)
            .subscribe(onNext: { taskCellViewModels in
                if let completedTask = taskCellViewModels.filter({ $0.id == testTask.id }).first {
                    XCTAssertTrue(completedTask.isCompleted)
                }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        await viewModel.completeTaskWith(id: testTask.id)
        
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
        
        viewModel.showItemWith(id: taskToShow.id)
        
        // then
        XCTAssertTrue(actions.didShowTaskDetails)
        XCTAssertEqual(actions.shownTaskId, taskToShow.id)
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
    
    func test_searchSuccess() async {
        // given
        let expectation = XCTestExpectation(description: "Tasks fetched successfully")
        
        let expectedTasks = [
            TaskObject(id: UUID(), title: "Test Task", comment: "", isCompleted: false)
        ]
        
        setupEnvironment(fetchTasksUseCaseResult: .success(expectedTasks))
        
        var fetchedTaskTitles: [String] = []
        viewModel.taskCellViewModels
            .subscribe(onNext: { tasks in
                fetchedTaskTitles = tasks.map { $0.title }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // when
        await viewModel.search(by: "Test Task")
        
        // then
        await fulfillment(of: [expectation])
        
        XCTAssertEqual(fetchedTaskTitles, ["Test Task"], "Должен был загрузиться список задач с именем \"Test Task\".")
        XCTAssertTrue(fetchTasksUseCase.isSearchByCalled)
    }
    
    func test_searchNonexistentSuccess() async {
        // given
        let expectation = XCTestExpectation(description: "Tasks fetched successfully")
        
        let expectedTasks: [TaskObject] = []
        
        setupEnvironment(fetchTasksUseCaseResult: .success(expectedTasks))
        
        var fetchedTaskTitles: [String] = []
        viewModel.taskCellViewModels
            .subscribe(onNext: { tasks in
                fetchedTaskTitles = tasks.map { $0.title }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // when
        await viewModel.search(by: "Nonexistent")
        
        // then
        await fulfillment(of: [expectation])
        
        XCTAssertEqual(fetchedTaskTitles, [], "Должен был загрузиться список задач с именем \"Test Task\".")
        XCTAssertTrue(fetchTasksUseCase.isSearchByCalled)
    }

    func test_searchFailure() async {
        // given
        let expectation = XCTestExpectation(description: "Error triggered on search failure")
        
        let expectedError = ShowableError.searchTasksError
        setupEnvironment(fetchTasksUseCaseResult: .failure(expectedError))
        
        var receivedErrorMessage: String?
        viewModel.error
            .skip(1)
            .subscribe(onNext: { errorMessage in
                receivedErrorMessage = errorMessage
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // when
        await viewModel.search(by: "Nonexistent Task")
        
        // then
        await fulfillment(of: [expectation])
        
        XCTAssertEqual(receivedErrorMessage, expectedError.description, "Ошибка должна передаваться в свойство error.")
        XCTAssertTrue(fetchTasksUseCase.isSearchByCalled)
    }
    
    func test_searchResetsOnEmptyQuery() async {
        
        // given
        let expectation = XCTestExpectation(description: "Tasks fetched and reset on empty search query")
        
        let initialTasks = [
            TaskObject(id: UUID(), title: "Test Task 1", comment: "", isCompleted: false),
            TaskObject(id: UUID(), title: "Another Task", comment: "", isCompleted: true)
        ]
        
        setupEnvironment(fetchTasksUseCaseResult: .success(initialTasks))
        
        var fetchedTaskTitles: [String] = []
        viewModel.taskCellViewModels
            .skip(1)
            .subscribe(onNext: { tasks in
                fetchedTaskTitles = tasks.map { $0.title }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // when
        await viewModel.search(by: "Test")
        
        // then
        await fulfillment(of: [expectation])
        XCTAssertTrue(fetchTasksUseCase.isSearchByCalled)
        XCTAssertEqual(fetchedTaskTitles, ["Test Task 1"], "После поиска по 'Test' должен остаться только 'Test Task 1'")
        
        // Reset expectation
        let resetExpectation = XCTestExpectation(description: "Tasks reset on empty search query")
        
        viewModel.taskCellViewModels
            .skip(1)
            .subscribe(onNext: { tasks in
                fetchedTaskTitles = tasks.map { $0.title }
                resetExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // when
        await viewModel.search(by: "")
        
        // then
        await fulfillment(of: [resetExpectation])
        XCTAssertEqual(fetchedTaskTitles, ["Test Task 1", "Another Task"], "При пустом поисковом запросе должен вернуться полный список задач.")
        XCTAssertTrue(fetchTasksUseCase.isSearchByCalled)
    }

    func test_resetSearchRestoresInitialTaskList() async {
        
        // given
        let expectationSearch = XCTestExpectation(description: "Tasks filtered by search query")

        let initialTasks = [
            TaskObject(id: UUID(), title: "Test Task 1", comment: "", isCompleted: false),
            TaskObject(id: UUID(), title: "Another Task", comment: "", isCompleted: true)
        ]
        
        setupEnvironment(fetchTasksUseCaseResult: .success(initialTasks))
        
        var fetchedTaskTitles: [String] = []
        viewModel.taskCellViewModels
            .skip(1)
            .subscribe(onNext: { tasks in
                fetchedTaskTitles = tasks.map { $0.title }
                expectationSearch.fulfill()
            })
            .disposed(by: disposeBag)
        
        // when
        await viewModel.search(by: "Test")
        
        // then
        await fulfillment(of: [expectationSearch])
        XCTAssertEqual(fetchedTaskTitles, ["Test Task 1"], "После поиска по 'Test' должен остаться только 'Test Task 1'")
        
        let expectationReset = XCTestExpectation(description: "Tasks reset after calling resetSearch")
        viewModel.taskCellViewModels
            .skip(1)
            .subscribe(onNext: { tasks in
                fetchedTaskTitles = tasks.map { $0.title }
                expectationReset.fulfill()
            })
            .disposed(by: disposeBag)
        
        // when
        await viewModel.resetSearch()
        
        // then
        await fulfillment(of: [expectationReset])
        XCTAssertEqual(fetchedTaskTitles, ["Test Task 1", "Another Task"], "После сброса поиска должен вернуться полный список задач.")
    }

}
