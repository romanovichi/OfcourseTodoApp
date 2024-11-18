//
//  TaskViewModel.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 01.11.2024.
//

import Foundation
import RxSwift
import RxCocoa

class TaskViewModel: NewTaskViewModelProtocol {    
    
    private let id: UUID?
    private let taskActionsUseCase: TaskActionsUseCaseProtocol
    private let addNewTaskUseCase: AddNewTaskUseCaseProtocol
    private let actions: TaskViewModelActions?
    private let disposeBag = DisposeBag()
    
    var fetchedTask = BehaviorSubject<TaskModel?>(value: nil)
    private(set) var error = BehaviorSubject<String>(value: "")

    let errorTitle = NSLocalizedString("Error", comment: "")
    private var originalTask: TaskModel?

    // MARK: - Init
    
    init(
        id: UUID?,
        taskActionsUseCase: TaskActionsUseCaseProtocol,
        addNewTaskUseCase: AddNewTaskUseCaseProtocol,
        actions: TaskViewModelActions? = nil
    ) {
        self.id = id
        self.taskActionsUseCase = taskActionsUseCase
        self.addNewTaskUseCase = addNewTaskUseCase
        self.actions = actions
    }
    
    // MARK: - INPUT. View event methods
    
    @MainActor
    func initialLoad() {
        guard let id = id else { return }

        Task { [weak self] in
            
            guard let self else { return }
            let result = await taskActionsUseCase.fetchTask(by: id)
            switch result {
            case .success(let task):
                self.originalTask = TaskModel(taskObject: task)
                self.fetchedTask.onNext(TaskModel(taskObject: task))
            case .failure(let error):
                self.error.onNext(ErrorMapper.mapToDescription(showableError: error))
            }
        }
    }
    
    @MainActor
    func onSave(title: String, comment: String) {
        
        guard let id = id else {
            addNewTask(title: title, comment: comment)
            return
        }
        
        let currentTask = TaskModel(id: id, title: title, comment: comment)
        if currentTask != originalTask {
            updateTask(id: id, title: title, comment: comment)
        } else {
            actions?.close()
        }
    }
    
    @MainActor
    private func updateTask(id: UUID, title: String, comment: String) {
        Task {
            let result = await taskActionsUseCase.updateTask(with: id, title: title, comment: comment)
            switch result {
            case .success:
                actions?.close()
            case .failure(let error):
                self.error.onNext(ErrorMapper.mapToDescription(showableError: error))
            }
        }
    }
    
    @MainActor
    private func addNewTask(title: String, comment: String) {
        Task {
            let result = await addNewTaskUseCase.createTask(title: title, comment: comment)
            switch result {
            case .success:
                actions?.close()
            case .failure(let error):
                self.error.onNext(ErrorMapper.mapToDescription(showableError: error))
            }
        }
    }
    
    @MainActor
    func onDelete() {
        guard let id = id else { return }
        
        Task {
            let result = await taskActionsUseCase.removeTask(by: id)
            switch result {
            case .success:
                actions?.close()
            case .failure(let error):
                self.error.onNext(ErrorMapper.mapToDescription(showableError: error))
            }
        }
    }
}
