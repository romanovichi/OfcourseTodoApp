//
//  TaskViewController.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 31.10.2024.
//

import UIKit
import RxSwift
class TaskViewController: UIViewController {
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCommentTextView: UITextView!
    
    @IBOutlet weak var actionButtonsStackView: UIStackView!
    @IBOutlet weak var editTaskButton: UIButton!
    @IBOutlet weak var deleteTaskButton: UIButton!
    
    private var viewModel: NewTaskViewModelProtocol!
    private let disposeBag = DisposeBag()

    init(viewModel: NewTaskViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: "TaskViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        configureUIElements()
        setupBindings()
        bindErrorMessages()
        
        viewModel.initialLoad()
    }
    
    private func setupNavigationBar() {
        title = "Task"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapAddTask)
        )
    }
    
    private func configureUIElements() {
        taskTitleTextField.layer.cornerRadius = 5
        taskCommentTextView.layer.cornerRadius = 5

        taskTitleTextField.layer.borderWidth = 1
        taskTitleTextField.layer.borderColor = UIColor.systemBrown.cgColor
        taskCommentTextView.layer.borderWidth = 1
        taskCommentTextView.layer.borderColor = UIColor.systemBrown.cgColor
        
        setUserInteractionEnabled(true)
    }
    
    private func setUserInteractionEnabled(_ enabled: Bool) {
        taskTitleTextField.isUserInteractionEnabled = enabled
        taskCommentTextView.isUserInteractionEnabled = enabled
        actionButtonsStackView.isHidden = enabled
    }
    
    private func setupBindings() {
        viewModel.fetchedTask
            .skip(while: { $0 == nil })
            .subscribe(onNext: { [weak self] task in
                guard let self else { return }
                self.updateUI(with: task)
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
    
    private func updateUI(with task: TaskObject?) {
        if let task = task {
            taskTitleTextField.text = task.title
            taskCommentTextView.text = task.comment
            setUserInteractionEnabled(false)
        } else {
            taskTitleTextField.text = ""
            taskCommentTextView.text = ""
            setUserInteractionEnabled(true)
        }
    }
    
    @objc private func didTapAddTask() {
        viewModel.onSave(title: taskTitleTextField.text ?? "",
                         comment: taskCommentTextView.text)
    }
    
    @IBAction func didTapEditTask(_ sender: Any) {
        title = "Edit task"
        setUserInteractionEnabled(true)
    }
    
    @IBAction func didTapDeleteTask(_ sender: Any) {
        viewModel.onDelete()
    }
}

extension TaskViewController: Alertable {
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
}
