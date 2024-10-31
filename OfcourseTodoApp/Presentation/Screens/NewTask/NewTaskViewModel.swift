//
//  NewTaskViewModel.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 01.11.2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol NewTaskViewModelInput {
    func onSave()
}

protocol NewTaskViewModelOutput {
}

typealias NewTaskViewModelProtocol = NewTaskViewModelInput & NewTaskViewModelOutput


class NewTaskViewModel: NewTaskViewModelProtocol {    
    
    private let addNewTaskUseCase: AddNewTaskUseCaseProtocol
    private let actions: NewTaskViewModelActions?
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Init
    
    init(
        addNewTaskUseCase: AddNewTaskUseCaseProtocol,
        actions: NewTaskViewModelActions? = nil
    ) {
        self.addNewTaskUseCase = addNewTaskUseCase
        self.actions = actions
    }
    
    // MARK: - INPUT. View event methods
    
    func onSave() {
        actions?.close()
    }
}
