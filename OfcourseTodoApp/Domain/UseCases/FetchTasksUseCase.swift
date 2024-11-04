//
//  FetchTasksUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 30.10.2024.
//

import Foundation

protocol FetchTasksUseCaseProtocol {
    func fetchAllTasks() async -> Result<[TaskObject], ShowableError>
    func fetchIncompleteTasks() async -> Result<[TaskObject], ShowableError>
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], ShowableError>
}

final class FetchTasksUseCase: FetchTasksUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    func fetchAllTasks() async -> Result<[TaskObject], ShowableError> {
        let result = await taskRepository.fetchAllTasks()
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("fetchAllTasks error: \(failure)")
            return .failure(ShowableError.fetchDatabaseError)
        }
    }

    func fetchIncompleteTasks() async -> Result<[TaskObject], ShowableError> {
        let result = await taskRepository.fetchIncompleteTasks()
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("fetchIncompleteTasks error: \(failure)")
            return .failure(ShowableError.fetchIncompleteTasksError)
        }
    }

    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], ShowableError> {
        let result = await taskRepository.searchTasks(by: title, includeOnlyIncomplete: includeOnlyIncomplete)
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            print("searchTasks error: \(failure)")
            return .failure(ShowableError.searchTasksError)
        }
    }
}

