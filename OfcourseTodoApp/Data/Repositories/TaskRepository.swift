//
//  TaskRepository.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 27.10.2024.
//

import Foundation

class TaskRepository: TaskRepositoryProtocol {
    
    var database: TaskDatabaseProtocol
    
    init(database: TaskDatabaseProtocol) {
        self.database = database
    }
    
    func saveTask(title: String, comment: String?) async -> Result<TaskObject, Error> {
        return await database.saveTask(title: title, comment: comment, isCompleted: false)
    }
    
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<TaskObject, Error> {
        return await database.updateTask(with: id, title: title, comment: comment, isCompleted: isCompleted)
    }
    
    func removeTask(by id: UUID) async -> Result<Bool, Error> {
        return await database.removeTask(by: id)
    }
    
    func fetchTask(by id: UUID) async -> Result<TaskObject, Error> {
        return await database.fetchTask(by: id)
    }
    
    func fetchAllTasks() async -> Result<[TaskObject], Error> {
        return await database.fetchAllTasks()
    }
    
    func fetchIncompleteTasks() async -> Result<[TaskObject], Error> {
        return await database.fetchIncompleteTasks()
    }
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], Error> {
        return await database.searchTasks(by: title, includeOnlyIncomplete: includeOnlyIncomplete)
    }
}
