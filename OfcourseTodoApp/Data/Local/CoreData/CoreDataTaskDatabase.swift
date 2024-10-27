//
//  TaskService.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import Foundation
import CoreData

protocol TaskDatabaseProtocol {
    @discardableResult
    func saveTask(title: String, comment: String?, isCompleted: Bool) async -> Result<Task, Error>
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<Task, Error>
    func removeTask(by id: UUID) async -> Result<Bool, Error>
    
    func fetchTask(by id: UUID) async -> Result<Task, Error>
    func fetchAllTasks() async -> Result<[Task], Error>
    func fetchIncompleteTasks() async -> Result<[Task], Error>
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[Task], Error>
}

class CoreDataTaskDatabase: TaskDatabaseProtocol {

    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func fetchTask(by id: UUID) async -> Result<Task, Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)

        do {
            if let taskEntity = try context.fetch(fetchRequest).first {
                return .success(TaskMapper.mapToObject(taskEntity: taskEntity))
            } else {
                return .failure(NSError(domain: "Task not found", code: 404, userInfo: nil))
            }
        } catch {
            print("Error fetching task: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    @discardableResult
    func saveTask(title: String, comment: String?, isCompleted: Bool = false) async -> Result<Task, Error> {
        let context = persistentContainer.viewContext
        let taskEntity = TaskEntity(context: context)
        
        taskEntity.uuid = UUID()
        taskEntity.title = title
        taskEntity.comment = comment
        taskEntity.dateCreated = Date()
        taskEntity.isCompleted = isCompleted

        do {
            try saveContext()
            return .success(TaskMapper.mapToObject(taskEntity: taskEntity))
        } catch {
            print("Failed to save task: \(error)")
            return .failure(error)
        }
    }

    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) async -> Result<Task, Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)

        do {
            if let taskEntity = try context.fetch(fetchRequest).first {
                taskEntity.title = title
                taskEntity.comment = comment
                taskEntity.isCompleted = isCompleted ?? taskEntity.isCompleted

                try saveContext()
                return .success(TaskMapper.mapToObject(taskEntity: taskEntity))
            } else {
                return .failure(NSError(domain: "Task not found", code: 404, userInfo: nil))
            }
        } catch {
            print("Failed to update task: \(error)")
            return .failure(error)
        }
    }

    func removeTask(by id: UUID) async -> Result<Bool, Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)

        do {
            if let taskEntity = try context.fetch(fetchRequest).first {
                context.delete(taskEntity)
                try saveContext()
                return .success(true)
            } else {
                return .failure(NSError(domain: "Task not found", code: 404, userInfo: nil))
            }
        } catch {
            print("Error fetching or deleting task: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func fetchAllTasks() async -> Result<[Task], Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        do {
            let taskEntities = try context.fetch(fetchRequest)
            let tasks = taskEntities.map { TaskMapper.mapToObject(taskEntity: $0) }
            return .success(tasks)
        } catch {
            print("Failed to fetch tasks: \(error)")
            return .failure(error)
        }
    }
    
    func fetchIncompleteTasks() async -> Result<[Task], Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: false))

        do {
            let taskEntities = try context.fetch(fetchRequest)
            let tasks = taskEntities.map { TaskMapper.mapToObject(taskEntity: $0) }
            return .success(tasks)
        } catch {
            print("Failed to fetch incomplete tasks: \(error)")
            return .failure(error)
        }
    }

    func searchTasks(by title: String, includeOnlyIncomplete: Bool = false) async -> Result<[Task], Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", title))

        if includeOnlyIncomplete {
            predicates.append(NSPredicate(format: "isCompleted == %@", NSNumber(value: false)))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        do {
            let taskEntities = try context.fetch(fetchRequest)
            let tasks = taskEntities.map { TaskMapper.mapToObject(taskEntity: $0) }
            return .success(tasks)
        } catch {
            print("Failed to fetch tasks with search: \(error)")
            return .failure(error)
        }
    }

    private func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}