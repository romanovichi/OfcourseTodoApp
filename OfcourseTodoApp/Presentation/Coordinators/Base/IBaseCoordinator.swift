//
//  IBaseCoordinator.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import UIKit

protocol IBaseCoordinator: AnyObject {
    
    var dependencyContainer: AppDIContainer { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func back(animated: Bool)
}
