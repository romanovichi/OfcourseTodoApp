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
    let showTaskDetails: (TaskObject) -> Void
    let addNewTask: () -> Void
}

protocol TaskListViewModelInput {
    func initialLoad()
    func addNewTask()
    func toggleCompletionFilter()
    func search(by title: String)
    func resetSearch()
    func showItemWith(id: Int)
}

protocol TaskListViewModelCellEventInput {
    func completeTaskWith(id: Int)
}

protocol TaskListViewModelOutput {
    var errorTitle: String { get }
    var taskCellViewModels: BehaviorSubject<[TaskListCellViewModel]> { get }
    var error: BehaviorSubject<String> { get }

}

typealias TaskListViewModelProtocol = TaskListViewModelInput & TaskListViewModelOutput

final class TaskListViewModel: TaskListViewModelProtocol, TaskListViewModelCellEventInput {
    
    private let fetchTasksUseCase: FetchTasksUseCaseProtocol
    private let changeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol
    private let actions: TaskListViewModelActions?
    private var tasks: [TaskObject] = []
    private let disposeBag = DisposeBag()
    
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    private(set) var taskCellViewModels = BehaviorSubject<[TaskListCellViewModel]>(value: [])
    private(set) var error = BehaviorSubject<String>(value: "")

    @MainActor
    private var isIncompleteFilterEnabled = false {
        didSet {
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
    
    @MainActor
    func initialLoad() {
        fetchAllTasks()
    }
    
    func addNewTask() {
        actions?.addNewTask()
    }
    
    @MainActor
    func toggleCompletionFilter() {
        isIncompleteFilterEnabled = !isIncompleteFilterEnabled
    }
    
    @MainActor
    func search(by title: String) {
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
    
    func resetSearch() {
        
    }
    
    func showItemWith(id index: Int) {
        actions?.showTaskDetails(tasks[index])
    }
    
    @MainActor
    func completeTaskWith(id index: Int) {
        Task {
            let result = await changeTaskStatusUseCase.changeStatusForTask(with: tasks[index].id, isCompleted: true)
            switch result {
            case .success(let completedTask):
                tasks[index] = completedTask
                mapAndUpdateToTaskListCellViewModel(at: index, task: completedTask)
            case .failure(let error):
                self.error.onNext(error.description)
            }
        }
    }
}

extension TaskListViewModel {
    
    @MainActor
    private func mapAndUpdateToTaskListCellViewModel(at index: Int, task: TaskObject) {
        let taskListCellViewModel = TaskListCellViewModel(task: task)
        var currentTaskCellViewModels = try! taskCellViewModels.value()
        
        currentTaskCellViewModels[index] = taskListCellViewModel
        taskCellViewModels.onNext(currentTaskCellViewModels)
    }
    
    @MainActor
    func mapToTaskListCellViewModels(_ tasks: [TaskObject]) {
        // Преобразуем массив `TaskObject` в массив `TaskListCellViewModel`
        let cellViewModels = tasks.map { task in
            TaskListCellViewModel(id: task.id, title: task.title, isCompleted: task.isCompleted)
        }
        self.taskCellViewModels.onNext(cellViewModels) // Обновляем observable
    }
    
    @MainActor
    private func fetchAllTasks() {
        Task {
            let result = await fetchTasksUseCase.fetchAllTasks()
            switch result {
            case .success(let fetchedTasks):
                tasks = fetchedTasks
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
        return .failure(ShowableError.fetchDatabaseError)
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
