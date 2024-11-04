//
//  TaskUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation

protocol AddNewTaskUseCaseProtocol {
    func createTask(title: String, comment: String?) async -> Result<TaskObject, ShowableError>
}

final class AddNewTaskUseCase: AddNewTaskUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    private let taskValidationService: TaskValidationServiceProtocol
    
    init(taskRepository: TaskRepositoryProtocol,
         taskValidationService: TaskValidationServiceProtocol) {
        
        self.taskRepository = taskRepository
        self.taskValidationService = taskValidationService
    }
    
    func createTask(title: String, comment: String?) async -> Result<TaskObject, ShowableError> {
        
        if let validationError = taskValidationService.validateTitle(title) {
            return .failure(validationError)
        }
        
        if let comment = comment, let validationError = taskValidationService.validateComment(comment) {
            return .failure(validationError)
        }
        
        let result = await taskRepository.saveTask(title: title, comment: comment)
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("saveTask error: \(failure)")
            return .failure(ShowableError.createNewTaskError)
        }
    }
}
