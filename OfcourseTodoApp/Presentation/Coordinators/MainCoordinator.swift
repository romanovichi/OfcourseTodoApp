//
//  MainCoordinator.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import UIKit

protocol MainCoordinatorProtocol: IBaseCoordinator {
    
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
        let actions = TaskListViewModelActions(showTaskDetails: showTaskDetails,
                                               addNewTask: editTask)
        
        let vc = dependencyContainer.makeMoviesListViewController(actions: actions)

        navigationController?.pushViewController(vc, animated: false)
        taskListVC = vc
    }
    
    func back(animated: Bool = true) {
        navigationController?.dismiss(animated: animated)
    }
    
    private func showTaskDetails(movie: TaskObject) {
//        let vc = dependencies.makeMoviesDetailsViewController(movie: movie)
//        navigationController?.pushViewController(vc, animated: true)
    }

//    private func addNewTask(didSelect: @escaping (MovieQuery) -> Void) {
//        guard let moviesListViewController = moviesListVC, moviesQueriesSuggestionsVC == nil,
//            let container = moviesListViewController.suggestionsListContainer else { return }
//
//        let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(didSelect: didSelect)
//
//        moviesListViewController.add(child: vc, container: container)
//        moviesQueriesSuggestionsVC = vc
//        container.isHidden = false
//    }

    private func editTask() {
//        moviesQueriesSuggestionsVC?.remove()
//        moviesQueriesSuggestionsVC = nil
//        moviesListVC?.suggestionsListContainer.isHidden = true
    }
}
