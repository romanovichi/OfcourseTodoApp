//
//  TaskService.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import Foundation
import CoreData

protocol TaskRepositoryProtocol {
    func saveTask(title: String, comment: String?) -> Task?
    func getTask(by id: NSManagedObjectID) -> Result<Task, Error>
    func updateTask(with id: NSManagedObjectID, title: String, comment: String?) -> Task?
    func fetchAllTasks() -> [Task]
}

class CoreDataTaskRepository: TaskRepositoryProtocol {

    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getTask(by id: NSManagedObjectID) -> Result<Task, Error> {
        let context = persistentContainer.viewContext

        do {
            let taskEntity = try context.existingObject(with: id) as! TaskEntity
            return .success(TaskMapper.mapToObject(taskEntity: taskEntity))
        } catch {
            print("Error fetching task: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func saveTask(title: String, comment: String?) -> Task? {
        
        let context = persistentContainer.viewContext
        let taskEntity = TaskEntity(context: context)
        
        taskEntity.title = title
        taskEntity.comment = comment
        taskEntity.dateCreated = Date()
        taskEntity.isCompleted = false

        do {
            try saveContext()
            return TaskMapper.mapToObject(taskEntity: taskEntity)
        } catch {
            print("Failed to save task: \(error)")
            return nil
        }
    }

    func updateTask(with id: NSManagedObjectID, title: String, comment: String?) -> Task? {
        let context = persistentContainer.viewContext

        do {
            let taskEntity = try context.existingObject(with: id) as! TaskEntity
            taskEntity.title = title
            taskEntity.comment = comment
            
            try saveContext()
            return TaskMapper.mapToObject(taskEntity: taskEntity)
        } catch {
            print("Failed to update task: \(error)")
            return nil
        }
    }
    
    func fetchAllTasks() -> [Task] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let taskEntity = try context.fetch(fetchRequest)
            return taskEntity.map { TaskMapper.mapToObject(taskEntity: $0) }
        } catch {
            print("Failed to fetch tasks: \(error)")
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

