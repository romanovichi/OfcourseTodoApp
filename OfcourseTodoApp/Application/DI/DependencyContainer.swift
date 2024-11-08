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
    lazy var addNewTaskUseCase: AddNewTaskUseCaseProtocol = {
        return AddNewTaskUseCase(taskRepository: taskRepository,
                                 taskValidationService: taskValidationService)
    }()
    
    lazy var fetchTasksUseCase: FetchTasksUseCaseProtocol = {
        return FetchTasksUseCase(taskRepository: taskRepository)
    }()
    
    lazy var taskActionsUseCase: TaskActionsUseCaseProtocol = {
        return TaskActionsUseCase(taskRepository: taskRepository,
                                 taskValidationService: taskValidationService)
    }()
    
    lazy var changeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol = {
        return ChangeTaskStatusUseCase(taskRepository: taskRepository,
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
    func makeMainCoordinator(navigationController: UINavigationController) -> MainCoordinator {
        return MainCoordinator(navigationController: navigationController,
                               dependencyContainer: self)
    }
    
    // MARK: - Task List
    func makeMoviesListViewController(actions: TaskListViewModelActions) -> TaskListViewController {
        TaskListViewController(viewModel: makeMoviesListViewModel(actions: actions))
    }
    
    func makeMoviesListViewModel(actions: TaskListViewModelActions) -> TaskListViewModel {
        TaskListViewModel(fetchTasksUseCase: fetchTasksUseCase,
                          changeTaskStatusUseCase: changeTaskStatusUseCase,
                          actions: actions
        )
    }
    
    // MARK: - Add Task
    func makeTaskViewController(id: UUID?, actions: TaskViewModelActions) -> TaskViewController {
        TaskViewController(viewModel: makeAddTaskViewModel(id: id, actions: actions))
    }
    
    func makeAddTaskViewModel(id: UUID?, actions: TaskViewModelActions) -> TaskViewModel {
        TaskViewModel(id: id,
                      taskActionsUseCase: taskActionsUseCase,
                      addNewTaskUseCase: addNewTaskUseCase,
                      actions: actions)
    }
}
