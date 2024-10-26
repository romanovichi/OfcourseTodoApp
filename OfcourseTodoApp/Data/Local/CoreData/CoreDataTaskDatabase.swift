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
    func saveTask(title: String, comment: String?, isCompleted: Bool) -> Task?
    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) -> Task?
    func removeTask(by id: UUID) -> Result<Bool, Error>
    
    func fetchTask(by id: UUID) -> Result<Task, Error>
    func fetchAllTasks() -> [Task]
    func fetchIncompleteTasks() -> [Task]
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) -> [Task]
}

class CoreDataTaskDatabase: TaskDatabaseProtocol {

    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func fetchTask(by id: UUID) -> Result<Task, Error> {
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
    func saveTask(title: String, comment: String?, isCompleted: Bool = false) -> Task? {
        let context = persistentContainer.viewContext
        let taskEntity = TaskEntity(context: context)
        
        taskEntity.uuid = UUID()
        taskEntity.title = title
        taskEntity.comment = comment
        taskEntity.dateCreated = Date()
        taskEntity.isCompleted = isCompleted

        do {
            try saveContext()
            return TaskMapper.mapToObject(taskEntity: taskEntity)
        } catch {
            print("Failed to save task: \(error)")
            return nil
        }
    }

    func updateTask(with id: UUID, title: String, comment: String?, isCompleted: Bool?) -> Task? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)

        do {
            if let taskEntity = try context.fetch(fetchRequest).first {
                taskEntity.title = title
                taskEntity.comment = comment
                taskEntity.isCompleted = isCompleted ?? taskEntity.isCompleted

                try saveContext()
                return TaskMapper.mapToObject(taskEntity: taskEntity)
            } else {
                return nil
            }
        } catch {
            print("Failed to update task: \(error)")
            return nil
        }
    }

    func removeTask(by id: UUID) -> Result<Bool, Error> {
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
    
    func fetchAllTasks() -> [Task] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        do {
            let taskEntities = try context.fetch(fetchRequest)
            return taskEntities.map { TaskMapper.mapToObject(taskEntity: $0) }
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    func fetchIncompleteTasks() -> [Task] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: false))

        do {
            let taskEntities = try context.fetch(fetchRequest)
            return taskEntities.map { TaskMapper.mapToObject(taskEntity: $0) }
        } catch {
            print("Failed to fetch incomplete tasks: \(error)")
            return []
        }
    }

    func searchTasks(by title: String, includeOnlyIncomplete: Bool = false) -> [Task] {
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
            return taskEntities.map { TaskMapper.mapToObject(taskEntity: $0) }
        } catch {
            print("Failed to fetch tasks with search: \(error)")
            return []
        }
    }

    private func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
