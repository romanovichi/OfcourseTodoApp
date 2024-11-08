//
//  TaskListViewController.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import UIKit
import RxSwift
import RxCocoa
class TaskListViewController: UIViewController {
    
    enum Section {
        case incomplete
        case completed
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var toDoOnlyButton: TodoButton!
    
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
        configureTableView()
        setupBindings()
        
        viewModel.initialLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateData()
    }
    
    private func configureTableView() {
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.register(TaskListCell.self, forCellReuseIdentifier: "TaskListCell")
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
        bindTaskCellViewModels()
        bindIsIncompleteFilter()
        bindErrorMessages()
    }
    
    private func bindTaskCellViewModels() {
        viewModel.taskCellViewModels
            .skip(1)
            .subscribe(onNext: { [weak self] in
                self?.updateTaskCells($0)
            })
            .disposed(by: disposeBag)
    }

    private func bindIsIncompleteFilter() {
        viewModel.isIncompleteFilter
            .subscribe(onNext: { [weak self] in
                self?.toDoOnlyButton.isSelected = $0
            })
            .disposed(by: disposeBag)
    }

    private func bindErrorMessages() {
        viewModel.error
            .skip(1)
            .subscribe(onNext: { [weak self] in
                self?.showError($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, TaskListCellViewModel>(tableView: tableView) { (tableView, indexPath, viewModel) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath) as? TaskListCell else { return nil }
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    private func updateTaskCells(_ tasks: [TaskListCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskListCellViewModel>()
        
        let incompleteTasks = tasks.filter { !$0.isCompleted }
        let completedTasks = tasks.filter { $0.isCompleted }

        snapshot.appendSections([.incomplete, .completed])
        snapshot.appendItems(incompleteTasks, toSection: .incomplete)
        snapshot.appendItems(completedTasks, toSection: .completed)

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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == 0 ? "Todo" : "Completed"
        return TaskSectionHeaderView(title: title)
    }
}

extension TaskListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(by: searchText)
    }
}
