//
//  MainCoordinator.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import UIKit

protocol MainCoordinatorProtocol: IBaseCoordinator {
    
}

protocol Closable {
    var close: () -> Void { get }
}

struct TaskViewModelActions: Closable {
    var close: () -> Void
}

final class MainCoordinator {
    
    private weak var navigationController: UINavigationController?
    private var dependencyContainer: AppDIContainer

    private weak var taskListVC: TaskListViewController?

    init(navigationController: UINavigationController, dependencyContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        let actions = TaskListViewModelActions(showDetailsForTask: showDetailsForTask,
                                               addNewTask: addTask)
        
        let vc = dependencyContainer.makeMoviesListViewController(actions: actions)

        navigationController?.pushViewController(vc, animated: false)
        taskListVC = vc
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showDetailsForTask(id: UUID?) {
        let actions = TaskViewModelActions(close: back)
        let vc = dependencyContainer.makeTaskViewController(id: id, actions: actions)
        
        navigationController?.pushViewController(vc, animated: true)
    }

    private func addTask() {
        let actions = TaskViewModelActions(close: back)
        let vc = dependencyContainer.makeTaskViewController(id: nil, actions: actions)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
