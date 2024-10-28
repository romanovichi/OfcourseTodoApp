//
//  MainCoordinator.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import UIKit

protocol MainCoordinatorProtocol: IBaseCoordinator {
    
}

final class MainCoordinator: MainCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var dependencyContainer: AppDIContainer

    init(navigationController: UINavigationController, dependencyContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {

    }
}
