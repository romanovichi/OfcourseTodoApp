//
//  ChangeTaskStatusUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 30.10.2024.
//

import Foundation

protocol ChangeTaskStatusUseCaseProtocol {
    func changeStatusForTask(with id: UUID, isCompleted: Bool) async -> Result<TaskObject, ShowableError>
}

final class ChangeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    private let taskValidationService: TaskValidationServiceProtocol
    
    init(taskRepository: TaskRepositoryProtocol,
         taskValidationService: TaskValidationServiceProtocol) {
        
        self.taskRepository = taskRepository
        self.taskValidationService = taskValidationService
    }
    
    func changeStatusForTask(with id: UUID, isCompleted: Bool) async -> Result<TaskObject, ShowableError> {
        let result = await taskRepository.updateTask(with: id, title: "", comment: "", isCompleted: isCompleted)
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("updateTask error: \(failure)")
            return .failure(ShowableError.updateTaskError)
        }
    }
}
