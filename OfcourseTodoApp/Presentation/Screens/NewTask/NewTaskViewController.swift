//
//  NewTaskViewController.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 31.10.2024.
//

import UIKit

class NewTaskViewController: UIViewController {
    
    private var viewModel: NewTaskViewModelProtocol!

    init(viewModel: NewTaskViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Create task"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapAddTask)
        )
    }
    
    @objc private func didTapAddTask() {
        viewModel.onSave()
    }
}
