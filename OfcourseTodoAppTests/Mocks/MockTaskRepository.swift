//
//  MockTaskRepository.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockTaskRepository: TaskRepositoryProtocol {
    var tasks: [Task] = []

    func saveTask(title: String, comment: String?) async -> Result<Task, Error> {
        let task = Task(id: UUID(), title: title, comment: comment, isCompleted: false)
        tasks.append(task)
        return .success(task)
    }

    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<Task, Error> {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            let updatedTask = Task(
                id: id,
                title: title,
                comment: comment ?? tasks[index].comment,
                isCompleted: isCompleted ?? tasks[index].isCompleted
            )
            tasks[index] = updatedTask
            return .success(updatedTask)
        } else {
            return .failure(NSError(domain: "Task not found", code: 404, userInfo: nil))
        }
    }

    func removeTask(by id: UUID) async -> Result<Bool, Error> {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
            return .success(true)
        } else {
            return .failure(NSError(domain: "Task not found", code: 404, userInfo: nil))
        }
    }

    func fetchTask(by id: UUID) async -> Result<Task, Error> {
        if let task = tasks.first(where: { $0.id == id }) {
            return .success(task)
        } else {
            return .failure(NSError(domain: "Task not found", code: 404, userInfo: nil))
        }
    }

    func fetchAllTasks() async -> Result<[Task], Error> {
        return .success(tasks)
    }

    func fetchIncompleteTasks() async -> Result<[Task], Error> {
        let incompleteTasks = tasks.filter { !$0.isCompleted }
        return .success(incompleteTasks)
    }

    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[Task], Error> {
        let filteredTasks = tasks.filter {
            $0.title.contains(title) && (!includeOnlyIncomplete || !$0.isCompleted)
        }
        return .success(filteredTasks)
    }
}
