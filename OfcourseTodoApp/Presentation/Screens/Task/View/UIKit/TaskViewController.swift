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
    @IBOutlet weak var taskCommentTextView: PlaceholderTextView!
    
    @IBOutlet weak var actionButtonsStackView: UIStackView!
    @IBOutlet weak var deleteTaskButton: SwipeToDeleteButton!
    
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
        
        bindFetchedTask()
        bindErrorMessages()
        
        viewModel.initialLoad()
//        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeToDelete(_:)))
//        swipeRight.direction = .right
//        deleteTaskButton.addGestureRecognizer(swipeRight)
    }
    
//    @objc private func didSwipeToDelete(_ gesture: UISwipeGestureRecognizer) {
//        if gesture.state == .ended {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//                self?.viewModel.onDelete()
//            }
//        }
//    }
    
    private func setupNavigationBar() {
        title = "Task"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapAddTask)
        )
    }
    
    private func configureUIElements() {
        taskTitleTextField.becomeFirstResponder()
        
        taskTitleTextField.layer.cornerRadius = 5
        taskCommentTextView.layer.cornerRadius = 5

        taskTitleTextField.layer.borderWidth = 1
        taskTitleTextField.layer.borderColor = UIColor.systemBrown.cgColor
        taskCommentTextView.layer.borderWidth = 1
        taskCommentTextView.layer.borderColor = UIColor.systemBrown.cgColor
        taskCommentTextView.placeholder = "Enter comment here"
        
        deleteTaskButton.backgroundColor = .systemRed
        deleteTaskButton.layer.cornerRadius = 5
        deleteTaskButton.delegate = self
    }
    
    private func hideActionButtonsStackView(_ isHidden: Bool) {
        actionButtonsStackView.isHidden = isHidden
    }
    
    private func bindFetchedTask() {
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
    
    private func updateUI(with task: TaskModel?) {
        if let task = task {
            taskTitleTextField.text = task.title
            taskCommentTextView.text = task.comment
            hideActionButtonsStackView(false)
        } else {
            taskTitleTextField.text = ""
            taskCommentTextView.text = ""
            hideActionButtonsStackView(true)
        }
    }
    
    @objc private func didTapAddTask() {
        viewModel.onSave(title: taskTitleTextField.text ?? "",
                         comment: taskCommentTextView.text)
    }
}

extension TaskViewController: Alertable {
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
}

extension TaskViewController: SwipeToDeleteButtonDelegate {
    
    func didTriggerDeleteAction() {
        viewModel.onDelete()
    }
}
