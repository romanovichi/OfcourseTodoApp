//
//  AppDelegate.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppFlowCoordinator?
    var dependencyContainer: AppDIContainer = AppDIContainer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        
        window?.rootViewController = navigationController
        coordinator = AppFlowCoordinator(
            navigationController: navigationController,
            appDIContainer: dependencyContainer
        )
        
        coordinator?.start()
        window?.makeKeyAndVisible()
        
        return true
    }
}

