//
//  TaskRepositoryProtocol.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 27.10.2024.
//

import Foundation

protocol TaskRepositoryProtocol {
    @discardableResult
    func saveTask(title: String, comment: String?) -> Task?
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) -> Task?
    func removeTask(by id: UUID) -> Result<Bool, Error>
    
    func fetchTask(by id: UUID) -> Result<Task, Error>
    func fetchAllTasks() -> [Task]
    func fetchIncompleteTasks() -> [Task]
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) -> [Task]
}
