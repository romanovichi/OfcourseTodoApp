//
//  TaskListViewController.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol TaskListViewModelInput {
    func fetchInitialData()
    func addNewTask()
}

protocol TaskListViewModelOutput {
    var tasks: BehaviorSubject<[TaskObject]> { get }
}

typealias TaskListViewModelProtocol = TaskListViewModelInput & TaskListViewModelOutput

class TaskListViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: UITableViewDiffableDataSource<Section, TaskObject>!
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
        
        setupDataSource()
        setupNavigationBar()
        
        setupBindings()
        tableView.register(TaskListCell.self, forCellReuseIdentifier: "TaskListCell")
        tableView.rowHeight = 60

        viewModel.fetchInitialData()
    }
    
    private func setupNavigationBar() {
        title = "Tasks"  // Заголовок экрана
        
        // Кнопка "Добавить" справа
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddTask)
        )
    }
    
    @objc private func didTapAddTask() {
        viewModel.addNewTask()
    }
    
    private func setupBindings() {
        viewModel.tasks
            .subscribe(onNext: { [weak self] in
                self?.updateTasks($0)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, TaskObject>(tableView: tableView) { (tableView, indexPath, task) -> UITableViewCell? in
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath) as? TaskListCell {
                cell.configure(with: task.title, isCompleted: task.isCompleted)
                return cell
            }
            return nil
        }
    }
    
    private func updateTasks(_ tasks: [TaskObject]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskObject>()
        snapshot.appendSections([.main])
        snapshot.appendItems(tasks)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
