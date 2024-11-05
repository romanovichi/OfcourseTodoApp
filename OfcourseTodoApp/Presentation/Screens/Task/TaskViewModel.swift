//
//  TaskViewModel.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 01.11.2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol NewTaskViewModelInput {
    func initialLoad()
    func onDelete()
    func onSave(title: String, comment: String)
}

protocol NewTaskViewModelOutput {
    var errorTitle: String { get }

    var fetchedTask: BehaviorSubject<TaskObject?> { get }
    var error: BehaviorSubject<String> { get }
}

typealias NewTaskViewModelProtocol = NewTaskViewModelInput & NewTaskViewModelOutput


class TaskViewModel: NewTaskViewModelProtocol {    
    
    private let id: UUID?
    private let taskActionsUseCase: TaskActionsUseCaseProtocol
    private let addNewTaskUseCase: AddNewTaskUseCaseProtocol
    private let actions: TaskViewModelActions?
    private let disposeBag = DisposeBag()
    
    var fetchedTask = BehaviorSubject<TaskObject?>(value: nil)
    private(set) var error = BehaviorSubject<String>(value: "")

    let errorTitle = NSLocalizedString("Error", comment: "")

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
        
        Task {
            let result = await taskActionsUseCase.fetchTask(by: id)
            switch result {
            case .success(let task):
                self.fetchedTask.onNext(task)
            case .failure(let error):
                self.error.onNext(error.description)
            }
        }
    }
    
    @MainActor
    func onSave(title: String, comment: String) {
        Task {
            let result = await addNewTaskUseCase.createTask(title: title, comment: comment)
            switch result {
            case .success(let task):
                actions?.close()
            case .failure(let error):
                self.error.onNext(error.description)
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
                self.error.onNext(error.description)
            }
        }
    }
}
