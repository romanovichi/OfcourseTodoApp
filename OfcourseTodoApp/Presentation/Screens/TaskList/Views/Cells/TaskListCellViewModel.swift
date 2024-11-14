//
//  TaskListCellViewModel.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 03.11.2024.
//

import UIKit

struct TaskListCellViewModel: Equatable, Hashable {
    
    static func == (lhs: TaskListCellViewModel, rhs: TaskListCellViewModel) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.isCompleted == rhs.isCompleted
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(isCompleted)
    }
    
    let id: UUID
    let title: String
    let isCompleted: Bool
    let dateCreated: Date

    weak var delegate: TaskListViewModelCellEventInput?
    
    func completeTask() {
        delegate?.completeTaskWith(id: self.id)
    }
}

extension TaskListCellViewModel {

    init(task: TaskObject, delegate: TaskListViewModelCellEventInput) {
        self.id = task.id
        self.title = task.title
        self.isCompleted = task.isCompleted
        self.dateCreated = task.dateCreated
        self.delegate = delegate
    }
}

extension TaskListCellViewModel: CheckboxButtonOutput {

    func didTapCheckbox() {
        delegate?.completeTaskWith(id: self.id)
    }
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
