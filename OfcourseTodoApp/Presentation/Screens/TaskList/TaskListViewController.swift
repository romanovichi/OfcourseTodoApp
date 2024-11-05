//
//  TaskListViewController.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol Alertable {}
extension Alertable where Self: UIViewController {
    
    func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
}
class TaskListViewController: UIViewController {
    
    enum Section {
        case incomplete
        case completed
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var toDoOnlyButton: UIButton!
    
    private var dataSource: UITableViewDiffableDataSource<Section, TaskListCellViewModel>!
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
        setupSearchBar()
        
        setupBindings()
        tableView.register(TaskListCell.self, forCellReuseIdentifier: "TaskListCell")
        tableView.rowHeight = 60

        viewModel.initialLoad()
    }
    
    private func setupNavigationBar() {
        title = "Tasks"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddTask)
        )
    }
    
    @IBAction func didTapToDoOnlyButton(_ sender: Any) {
        viewModel.toggleCompletionFilter()
    }
    
    @objc private func didTapAddTask() {
        viewModel.addNewTask()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for task"
    }
    
    private func setupBindings() {
        
        viewModel.taskCellViewModels
            .subscribe(onNext: { [weak self] in
                self?.updateTaskCells($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .skip(1)
            .subscribe(onNext: { [weak self] in
                self?.showError($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, TaskListCellViewModel>(tableView: tableView) { (tableView, indexPath, viewModel) -> UITableViewCell? in
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath) as? TaskListCell {
                cell.configure(with: viewModel)
                return cell
            }
            return nil
        }
    }
    
    private func updateTaskCells(_ tasks: [TaskListCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskListCellViewModel>()
        
        let incompleteTasks = tasks.filter { !$0.isCompleted }
        let completedTasks = tasks.filter { $0.isCompleted }
        
        snapshot.appendSections([.incomplete])
        snapshot.appendSections([.completed])

        if !incompleteTasks.isEmpty {
            snapshot.appendItems(incompleteTasks, toSection: .incomplete)
        }
        
        if !completedTasks.isEmpty {
            snapshot.appendItems(completedTasks, toSection: .completed)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension TaskListViewController: Alertable {
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
}

extension TaskListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        print("Selected item: \(item.title)")
        viewModel.showItemWith(id: item.id)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TaskListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(by: searchText)
    }
}
