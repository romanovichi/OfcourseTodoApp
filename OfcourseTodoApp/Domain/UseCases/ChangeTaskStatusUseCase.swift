//
//  ChangeTaskStatusUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 30.10.2024.
//

import Foundation

protocol ChangeTaskStatusUseCaseProtocol {
    func completeTask(with id: UUID) async -> Result<TaskObject, Error>
    func incompleteTask(with id: UUID) async -> Result<TaskObject, Error>
}

final class ChangeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    private let taskValidationService: TaskValidationServiceProtocol
    
    init(taskRepository: TaskRepositoryProtocol,
         taskValidationService: TaskValidationServiceProtocol) {
        
        self.taskRepository = taskRepository
        self.taskValidationService = taskValidationService
    }
    
    func completeTask(with id: UUID) async -> Result<TaskObject, Error> {
        return await taskRepository.updateTask(with: id, title: "", comment: "", isCompleted: true)
    }
    
    func incompleteTask(with id: UUID) async -> Result<TaskObject, Error> {
        return await taskRepository.updateTask(with: id, title: "", comment: "", isCompleted: false)
    }
}
