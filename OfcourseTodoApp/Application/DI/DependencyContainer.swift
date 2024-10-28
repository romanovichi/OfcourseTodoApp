//
//  DependencyContainer.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import CoreData
import UIKit

final class AppDIContainer {
    
    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "OfcourseTodoApp")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Use cases
    lazy var taskUseCase: TaskUseCaseProtocol = {
        return TaskUseCase(taskRepository: taskRepository,
                           taskValidationService: taskValidationService)
    }()
    
    // MARK: - Services
    lazy var taskValidationService: TaskValidationServiceProtocol = {
        return TaskValidationService()
    }()

    // MARK: - Storages
    lazy var coreDataTaskDatabase: TaskDatabaseProtocol = {
        return CoreDataTaskDatabase(persistentContainer: persistentContainer)
    }()
    
    // MARK: - Repositories
    lazy var taskRepository: TaskRepositoryProtocol = {
        return TaskRepository(database: coreDataTaskDatabase)
    }()
    
    // MARK: - Coordinators
    func makeMainCoordinator(navigationController: UINavigationController) -> MainCoordinatorProtocol {
        return MainCoordinator(navigationController: navigationController,
                               dependencyContainer: self)
    }
}
