//
//  MoviesQueryListViewModelWrapper.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 12.11.2024.
//

import SwiftUI
import Combine
import RxSwift

@available(iOS 13.0, *)
final class TaskViewModelWrapper: ObservableObject {
    
    private var disposeBag = DisposeBag()
    private var viewModel: TaskViewModel
    
    @Published var fetchedTask: TaskModel?
    @Published var errorMessage: String? = nil
    
    init(viewModel: TaskViewModel) {
        self.viewModel = viewModel
        bindViewModel()
    }
    
    private func bindViewModel() {

        viewModel.fetchedTask
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.fetchedTask = $0
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.errorMessage = $0
            })
            .disposed(by: disposeBag)
    }
    
    @MainActor
    func onSave(title: String, comment: String) {
        viewModel.onSave(title: title, comment: comment)
    }
    
    @MainActor
    func onDelete() {
        viewModel.onDelete()
    }
}
