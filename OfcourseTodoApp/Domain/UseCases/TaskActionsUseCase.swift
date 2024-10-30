//
//  TaskActionsUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 30.10.2024.
//

import Foundation

protocol TaskActionsUseCaseProtocol {
    func fetchTask(by id: UUID) async -> Result<TaskObject, Error>
    func removeTask(by id: UUID) async -> Result<Bool, Error>
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<TaskObject, Error>
}

final class TaskActionsUseCase: TaskActionsUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    private let taskValidationService: TaskValidationServiceProtocol
    
    init(taskRepository: TaskRepositoryProtocol,
         taskValidationService: TaskValidationServiceProtocol) {
        
        self.taskRepository = taskRepository
        self.taskValidationService = taskValidationService
    }
    
    func fetchTask(by id: UUID) async -> Result<TaskObject, Error> {
        return await taskRepository.fetchTask(by: id)
    }

    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<TaskObject, Error> {
        
        if let validationError = taskValidationService.validateTitle(title) {
            return .failure(validationError)
        }
        
        return await taskRepository.updateTask(with: id, title: title, comment: comment, isCompleted: isCompleted)
    }

    func removeTask(by id: UUID) async -> Result<Bool, Error> {
        return await taskRepository.removeTask(by: id)
    }
}
