//
//  DependencyContainer.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import CoreData

final class DependencyContainer {
    
    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "OfcourseTodoApp")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    lazy var coreDataTaskDatabase: TaskDatabaseProtocol = {
        return CoreDataTaskDatabase(persistentContainer: persistentContainer)
    }()
    
    lazy var taskRepository: TaskRepositoryProtocol = {
        return TaskRepository(database: coreDataTaskDatabase)
    }()
}
