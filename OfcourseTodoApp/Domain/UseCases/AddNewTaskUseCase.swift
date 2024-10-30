//
//  TaskUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation

protocol AddNewTaskUseCaseProtocol {
    func createTask(title: String, comment: String?) async -> Result<TaskObject, Error>
}

enum ShowableError: Error {
    
    case newTaskError
    case fetchDatabaseError
    case validationError
    case unknownError
    
    var errorTitle: String {
        switch self {
        case .newTaskError:
            return "Can't create new task, try again"
        case .fetchDatabaseError:
            return "Can't fetch tasks from storage"
        case .validationError:
            return "I decided the task title should be less that 100 symbols and task comment should be less that 500 symbols. You just follow."
        case .unknownError:
            return "Some unknown error, call scienists"
        }
    }
}

final class AddNewTaskUseCase: AddNewTaskUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    private let taskValidationService: TaskValidationServiceProtocol
    
    init(taskRepository: TaskRepositoryProtocol,
         taskValidationService: TaskValidationServiceProtocol) {
        
        self.taskRepository = taskRepository
        self.taskValidationService = taskValidationService
    }
    
    func createTask(title: String, comment: String?) async -> Result<TaskObject, Error> {
        
        if let validationError = taskValidationService.validateTitle(title) {
            return .failure(validationError)
        }
        
        return await taskRepository.saveTask(title: title, comment: comment)
    }
}
