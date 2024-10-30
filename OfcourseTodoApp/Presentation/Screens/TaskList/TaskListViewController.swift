//
//  TaskListViewController.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import UIKit

protocol TaskListViewModelInput {
    
}

protocol TaskListViewModelOutput {
    
}

typealias TaskListViewModelProtocol = TaskListViewModelInput & TaskListViewModelOutput

class TaskListViewController: UIViewController {
    
    private var viewModel: TaskListViewModelProtocol!

    init(viewModel: TaskListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupTableView() {
//        tableView = UITableView(frame: view.bounds, style: .plain)
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
//        view.addSubview(tableView)
    }
    
    private func setupDataSource() {
//        dataSource = UITableViewDiffableDataSource<Section, TaskObject>(tableView: tableView) { (tableView, indexPath, task) -> UITableViewCell? in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
//            cell.textLabel?.text = task.title
//            cell.accessoryType = task.isCompleted ? .checkmark : .none
//            return cell
//        }
    }
    
    private func updateTasks(_ tasks: [TaskObject]) {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskObject>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(tasks)
//        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
