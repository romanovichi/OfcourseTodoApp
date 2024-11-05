//
//  TaskActionsUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 30.10.2024.
//

import Foundation

protocol TaskActionsUseCaseProtocol {
    func fetchTask(by id: UUID) async -> Result<TaskObject, ShowableError>
    func removeTask(by id: UUID) async -> Result<Bool, ShowableError>
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<TaskObject, ShowableError>
}

final class TaskActionsUseCase: TaskActionsUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    private let taskValidationService: TaskValidationServiceProtocol
    
    init(taskRepository: TaskRepositoryProtocol,
         taskValidationService: TaskValidationServiceProtocol) {
        
        self.taskRepository = taskRepository
        self.taskValidationService = taskValidationService
    }
    
    func fetchTask(by id: UUID) async -> Result<TaskObject, ShowableError> {
        let result = await taskRepository.fetchTask(by: id)
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("fetchTaskById error: \(failure)")
            return .failure(ShowableError.fetchTaskByIdError)
        }
    }

    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<TaskObject, ShowableError> {
        
        if let validationError = taskValidationService.validateTitle(title) {
            return .failure(validationError)
        }
        
        if let comment = comment, let validationError = taskValidationService.validateComment(comment) {
            return .failure(validationError)
        }
        
        let result = await taskRepository.updateTask(with: id, title: title, comment: comment)
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("updateTask error: \(failure)")
            return .failure(ShowableError.updateTaskError)
        }
    }

    func removeTask(by id: UUID) async -> Result<Bool, ShowableError> {
        let result = await taskRepository.removeTask(by: id)
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("removeTask error: \(failure)")
            return .failure(ShowableError.removeTaskError)
        }
    }
}
