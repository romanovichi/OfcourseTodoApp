//
//  TaskRepositoryProtocol.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 27.10.2024.
//

import Foundation

protocol TaskRepositoryProtocol {
    @discardableResult
    func saveTask(title: String, comment: String?) async -> Result<TaskObject, Error>
    func changeTaskStatus(with id: UUID) async -> Result<TaskObject, Error>
    func updateTask(with id: UUID, title: String, comment: String?) async -> Result<TaskObject, Error>
    func removeTask(by id: UUID) async -> Result<Bool, Error>
    
    func fetchTask(by id: UUID) async -> Result<TaskObject, Error>
    func fetchAllTasks() async -> Result<[TaskObject], Error>
    func fetchIncompleteTasks() async -> Result<[TaskObject], Error>
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], Error>
}
