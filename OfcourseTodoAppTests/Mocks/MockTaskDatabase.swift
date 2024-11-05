//
//  MockTaskDatabase.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockTaskDatabase: TaskDatabaseProtocol {
  
    var tasks: [TaskObject] = []
    
    @discardableResult
    func saveTask(title: String, comment: String?, isCompleted: Bool) async -> Result<TaskObject, Error> {
        let task = TaskObject(id: UUID(), title: title, comment: comment, isCompleted: isCompleted)
        tasks.append(task)
        return .success(task)
    }
    
    func changeTaskStatus(with id: UUID) async -> Result<TaskObject, any Error> {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].toggleIsCompleted()
            return .success(tasks[index])
        }
        return .failure(NSError(domain: "TaskErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "TaskObject not found"]))
    }
    
    func updateTask(with id: UUID, title: String, comment: String?) async -> Result<TaskObject, any Error> {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            let task = TaskObject(id: id, title: title, comment: comment)
            tasks[index] = task
            return .success(tasks[index])
        }
        return .failure(NSError(domain: "TaskErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "TaskObject not found"]))
    }

    func removeTask(by id: UUID) async -> Result<Bool, Error> {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
            return .success(true)
        }
        return .failure(NSError(domain: "TaskErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "TaskObject not found"]))
    }
    
    func fetchTask(by id: UUID) async -> Result<TaskObject, Error> {
        if let task = tasks.first(where: { $0.id == id }) {
            return .success(task)
        }
        return .failure(NSError(domain: "TaskErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "TaskObject not found"]))
    }
    
    func fetchAllTasks() async -> Result<[TaskObject], Error> {
        return .success(tasks)
    }
    
    func fetchIncompleteTasks() async -> Result<[TaskObject], Error> {
        let incompleteTasks = tasks.filter { !$0.isCompleted }
        return .success(incompleteTasks)
    }

    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], Error> {
        let filteredTasks = tasks.filter { $0.title.contains(title) && (!includeOnlyIncomplete || !$0.isCompleted) }
        return .success(filteredTasks)
    }
}
