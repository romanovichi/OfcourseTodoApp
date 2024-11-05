//
//  TaskListViewModel.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 29.10.2024.
//

import Foundation
import RxSwift
import RxCocoa

struct TaskListViewModelActions {
    let showDetailsForTask: (UUID?) -> Void
    let addNewTask: () -> Void
}

protocol TaskListViewModelInput {
    func initialLoad()
    func updateData()
    func addNewTask()
    func toggleCompletionFilter()
    func search(by title: String)
    func resetSearch()
    func showItemWith(id: UUID)
}

protocol TaskListViewModelCellEventInput: AnyObject {
    func completeTaskWith(id: UUID)
}

protocol TaskListViewModelOutput {
    var errorTitle: String { get }
    var updatedItem: BehaviorSubject<TaskListCellViewModel?> { get }
    var taskCellViewModels: BehaviorSubject<[TaskListCellViewModel]> { get }
    var error: BehaviorSubject<String> { get }
    var isIncompleteFilter: BehaviorSubject<Bool> { get }
}

typealias TaskListViewModelProtocol = TaskListViewModelInput & TaskListViewModelOutput

final class TaskListViewModel: TaskListViewModelProtocol, TaskListViewModelCellEventInput {
    
    private let fetchTasksUseCase: FetchTasksUseCaseProtocol
    private let changeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol
    private let actions: TaskListViewModelActions?
    private var tasks: [TaskObject] = []
    private let disposeBag = DisposeBag()
    
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    private(set) var updatedItem = BehaviorSubject<TaskListCellViewModel?>(value: nil)
    private(set) var taskCellViewModels = BehaviorSubject<[TaskListCellViewModel]>(value: [])
    private(set) var error = BehaviorSubject<String>(value: "")
    private(set) var isIncompleteFilter = BehaviorSubject<Bool>(value: false)

    @MainActor
    private var isIncompleteFilterEnabled = false {
        didSet {
            isIncompleteFilter.onNext(isIncompleteFilterEnabled)
            onCompletionFilterChanged()
        }
    }
    
    // MARK: - Init
    
    init(
        fetchTasksUseCase: FetchTasksUseCaseProtocol,
        changeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol,
        actions: TaskListViewModelActions? = nil
    ) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.changeTaskStatusUseCase = changeTaskStatusUseCase
        self.actions = actions
    }
}

extension TaskListViewModel {
    
    // MARK: - INPUT. View event methods
    
    func addNewTask() {
        actions?.addNewTask()
    }
    
    func showItemWith(id: UUID) {
        actions?.showDetailsForTask(id)
    }
    
    @MainActor
    func initialLoad() {
        fetchAllTasks()
    }
    
    @MainActor
    func updateData() {
        fetchAllTasks()
    }
    
    @MainActor
    func toggleCompletionFilter() {
        isIncompleteFilterEnabled = !isIncompleteFilterEnabled
    }
    
    @MainActor
    func resetSearch() {
        fetchAllTasks()
    }
    
    @MainActor
    func search(by title: String) {
        
        if title.isEmpty {
            resetSearch()
            return
        }
        
        Task {
            let result = await fetchTasksUseCase.searchTasks(by: title,
                                                             includeOnlyIncomplete: isIncompleteFilterEnabled)
            switch result {
            case .success(let fetchedTasks):
                mapToTaskListCellViewModels(fetchedTasks)
            case .failure(let error):
                self.error.onNext(error.description)
            }
        }
    }
    
    private func updateTask(_ task: TaskObject) {
        var currentTasks = try? taskCellViewModels.value()
        currentTasks?.updateWithElement(TaskListCellViewModel(task: task, delegate: self))
        
        if let updatedTasks = currentTasks {
            taskCellViewModels.onNext(updatedTasks)
        }
    }
    
    @MainActor
    func completeTaskWith(id: UUID) {
        Task {
            let result = await changeTaskStatusUseCase.changeStatusForTask(with: id)
            switch result {
            case .success(let completedTask):
                self.updateTask(completedTask)
            case .failure(let error):
                self.error.onNext(error.description)
            }
        }
    }
}

extension TaskListViewModel {
    
    @MainActor
    private func mapToTaskListCellViewModels(_ tasks: [TaskObject]) {
        let cellViewModels = tasks.mapToSortedCellViewModels(delegate: self)
        self.taskCellViewModels.onNext(cellViewModels)
    }
    
    @MainActor
    private func fetchAllTasks() {
        Task {
            let result = await fetchTasksUseCase.fetchAllTasks()
            switch result {
            case .success(let fetchedTasks):
                mapToTaskListCellViewModels(fetchedTasks)
            case .failure(let error):
                self.error.onNext(error.description)
            }
        }
    }
    
    @MainActor
    private func showIncompletedTasks() {
        Task {
            let result = await fetchTasksUseCase.fetchIncompleteTasks()
            switch result {
            case .success(let fetchedTasks):
                mapToTaskListCellViewModels(fetchedTasks)
            case .failure(let error):
                self.error.onNext(error.description)
            }
        }
    }
    
    @MainActor
    private func onCompletionFilterChanged() {
        if isIncompleteFilterEnabled {
            showIncompletedTasks()
        } else {
            fetchAllTasks()
        }
    }
}














class MockFetchTasksUseCase: FetchTasksUseCaseProtocol {
    
    private let mockTasks: [TaskObject] = [
        TaskObject(id: UUID(), title: "Создать экран добавления", comment: "This is a comment for task 1", isCompleted: true),
        TaskObject(id: UUID(), title: "Добавить модель для Presentation", comment: "Comment for task 2", isCompleted: false),
        TaskObject(id: UUID(), title: "Тесты Presentation", comment: "Another comment", isCompleted: false),
        TaskObject(id: UUID(), title: "Resources", comment: "Yet another task", isCompleted: false)
    ]
    
    func fetchAllTasks() async -> Result<[TaskObject], ShowableError> {
        return .success(mockTasks)
    }
    
    func fetchIncompleteTasks() async -> Result<[TaskObject], ShowableError> {
        let incompleteTasks = mockTasks.filter { !$0.isCompleted }
        return .success(incompleteTasks)
    }
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], ShowableError> {
        let filteredTasks = mockTasks.filter {
            $0.title.contains(title) && (!includeOnlyIncomplete || !$0.isCompleted)
        }
        return .success(filteredTasks)
    }
}
