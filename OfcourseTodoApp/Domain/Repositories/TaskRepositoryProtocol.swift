//
//  TaskRepositoryProtocol.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 27.10.2024.
//

import Foundation

protocol TaskRepositoryProtocol {
    @discardableResult
    func saveTask(title: String, comment: String?) async -> Result<Task, Error>
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<Task, Error>
    func removeTask(by id: UUID) async -> Result<Bool, Error>
    
    func fetchTask(by id: UUID) async -> Result<Task, Error>
    func fetchAllTasks() async -> Result<[Task], Error>
    func fetchIncompleteTasks() async -> Result<[Task], Error>
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[Task], Error>
}
