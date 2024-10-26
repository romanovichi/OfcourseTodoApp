//
//  BaseCoordinator.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import UIKit

class BaseCoordinator: IBaseCoordinator {
    
    var navigationController: UINavigationController
    var dependencyContainer: DependencyContainer

    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {

    }
    
    func back(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }
}
