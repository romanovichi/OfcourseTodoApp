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
    
    func saveTask(title: String, comment: String?) -> Task? {
        database.saveTask(title: title, comment: comment, isCompleted: false)
    }
    
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) -> Task? {
        database.updateTask(with: id, title: title, comment:comment, isCompleted: isCompleted)
    }
    
    func removeTask(by id: UUID) -> Result<Bool, Error> {
        database.removeTask(by: id)
    }
    
    func fetchTask(by id: UUID) -> Result<Task, Error> {
        database.fetchTask(by: id)
    }
    
    func fetchAllTasks() -> [Task] {
        database.fetchAllTasks()
    }
    
    func fetchIncompleteTasks() -> [Task] {
        database.fetchIncompleteTasks()
    }
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) -> [Task] {
        database.searchTasks(by: title, includeOnlyIncomplete: includeOnlyIncomplete)
    }
}
