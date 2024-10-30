//
//  FetchTasksUseCase.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 30.10.2024.
//

import Foundation

protocol FetchTasksUseCaseProtocol {
    func fetchAllTasks() async -> Result<[TaskObject], Error>
    func fetchIncompleteTasks() async -> Result<[TaskObject], Error>
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], Error>
}

final class FetchTasksUseCase: FetchTasksUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    func fetchAllTasks() async -> Result<[TaskObject], Error> {
        return await taskRepository.fetchAllTasks()
    }

    func fetchIncompleteTasks() async -> Result<[TaskObject], Error> {
        return await taskRepository.fetchIncompleteTasks()
    }

    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], Error> {
        return await taskRepository.searchTasks(by: title, includeOnlyIncomplete: includeOnlyIncomplete)
    }
}

