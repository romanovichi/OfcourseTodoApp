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

class TaskListViewModel: TaskListViewModelProtocol {
    
    private let fetchTasksUseCase: FetchTasksUseCaseProtocol
    private let changeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol
    private let actions: TaskListViewModelActions?
    private let disposeBag = DisposeBag()
       
    private(set) var tasks = BehaviorSubject<[TaskObject]>(value: [])
    
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
    
    // MARK: - INPUT. View event methods
    
    func didSelect(task: TaskObject) {
        actions?.showTaskDetails(task)
    }
    
    func addNewTask() {
        actions?.addNewTask()
    }
    
    @MainActor
    func fetchInitialData() {
        Task {
            let result = await fetchTasksUseCase.fetchAllTasks()
            switch result {
            case .success(let fetchedTasks):
                tasks.onNext(fetchedTasks)
            case .failure(let error):
                print("Ошибка загрузки задач: \(error)")
                tasks.onNext([])
            }
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
    
    func fetchAllTasks() async -> Result<[TaskObject], any Error> {
        return .success(mockTasks)
    }
    
    func fetchIncompleteTasks() async -> Result<[TaskObject], any Error> {
        let incompleteTasks = mockTasks.filter { !$0.isCompleted }
        return .success(incompleteTasks)
    }
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], any Error> {
        let filteredTasks = mockTasks.filter {
            $0.title.contains(title) && (!includeOnlyIncomplete || !$0.isCompleted)
        }
        return .success(filteredTasks)
    }
}
