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

final class TaskListViewModel: TaskListViewModelProtocol {
    
    private let fetchTasksUseCase: FetchTasksUseCaseProtocol
    private let changeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol
    private let actions: TaskListViewModelActions?
    private let disposeBag = DisposeBag()
    
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    private(set) var updatedItem = BehaviorSubject<TaskListCellViewModel?>(value: nil)
    private(set) var taskCellViewModels = BehaviorSubject<[TaskListCellViewModel]>(value: [])
    private(set) var error = BehaviorSubject<String>(value: "")
    private(set) var isIncompleteFilter = BehaviorSubject<Bool>(value: false)

    private var searchQuery: String = ""
    @MainActor private var isIncompleteFilterEnabled = false {
        didSet {
            isIncompleteFilter.onNext(isIncompleteFilterEnabled)
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
    
    // MARK: - INPUT. View event methods
    
    func addNewTask() {
        actions?.addNewTask()
    }
    
    func showItemWith(id: UUID) {
        actions?.showDetailsForTask(id)
    }
    
    @MainActor
    func initialLoad() {
        fetchAndFilterTasks()
    }
    
    @MainActor
    func updateData() {
        fetchAndFilterTasks()
    }
    
    @MainActor
    func toggleCompletionFilter() {
        isIncompleteFilterEnabled.toggle()
        isIncompleteFilter.onNext(isIncompleteFilterEnabled)
        fetchAndFilterTasks()
    }
    
    @MainActor
    func resetSearch() {
        searchQuery = ""
        fetchAndFilterTasks()
    }
    
    @MainActor
    func search(by title: String) {
        searchQuery = title
        fetchAndFilterTasks()
    }
    
    @MainActor
    private func fetchAndFilterTasks() {
        Task { [weak self] in
            guard let self else { return }
            
            let result: Result<[TaskObject], ShowableError>
            
            if searchQuery.isEmpty {
                result = isIncompleteFilterEnabled
                    ? await fetchTasksUseCase.fetchIncompleteTasks()
                    : await fetchTasksUseCase.fetchAllTasks()
            } else {
                result = await fetchTasksUseCase.searchTasks(by: searchQuery,
                                                             includeOnlyIncomplete: isIncompleteFilterEnabled)
            }

            switch result {
            case .success(let fetchedTasks):
                mapToTaskListCellViewModels(fetchedTasks)
            case .failure(let error):
                self.error.onNext(ErrorMapper.mapToDescription(showableError: error))
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
        Task { [weak self] in
            guard let self else { return }
            
            let result = await changeTaskStatusUseCase.changeStatusForTask(with: id)
            switch result {
            case .success(let completedTask):
                self.updateTask(completedTask)
            case .failure(let error):
                self.error.onNext(ErrorMapper.mapToDescription(showableError: error))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func mapToTaskListCellViewModels(_ tasks: [TaskObject]) {
        let cellViewModels = tasks.mapToSortedCellViewModels(delegate: self)
        self.taskCellViewModels.onNext(cellViewModels)
    }
}
