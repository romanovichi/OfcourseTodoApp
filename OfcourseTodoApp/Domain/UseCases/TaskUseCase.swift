//
//  TaskUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation

protocol TaskUseCaseProtocol {
    func createTask(title: String, comment: String?) async -> Result<Task, Error>
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<Task, Error>
    func removeTask(by id: UUID) async -> Result<Bool, Error>
    func fetchTask(by id: UUID) async -> Result<Task, Error>
    func fetchAllTasks() async -> Result<[Task], Error>
    func fetchIncompleteTasks() async -> Result<[Task], Error>
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[Task], Error>
}

final class TaskUseCase: TaskUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    private let taskValidationService: TaskValidationServiceProtocol

    init(taskRepository: TaskRepositoryProtocol,
         taskValidationService: TaskValidationServiceProtocol) {
        
        self.taskRepository = taskRepository
        self.taskValidationService = taskValidationService
    }

    func createTask(title: String, comment: String?) async -> Result<Task, Error> {
        
        if let validationError = taskValidationService.validateTitle(title) {
            return .failure(validationError)
        }
        
        return await taskRepository.saveTask(title: title, comment: comment)
    }

    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<Task, Error> {
        
        if let validationError = taskValidationService.validateTitle(title) {
            return .failure(validationError)
        }
        
        return await taskRepository.updateTask(with: id, title: title, comment: comment, isCompleted: isCompleted)
    }

    func removeTask(by id: UUID) async -> Result<Bool, Error> {
        return await taskRepository.removeTask(by: id)
    }

    func fetchTask(by id: UUID) async -> Result<Task, Error> {
        return await taskRepository.fetchTask(by: id)
    }

    func fetchAllTasks() async -> Result<[Task], Error> {
        return await taskRepository.fetchAllTasks()
    }

    func fetchIncompleteTasks() async -> Result<[Task], Error> {
        return await taskRepository.fetchIncompleteTasks()
    }

    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[Task], Error> {
        return await taskRepository.searchTasks(by: title, includeOnlyIncomplete: includeOnlyIncomplete)
    }
}
