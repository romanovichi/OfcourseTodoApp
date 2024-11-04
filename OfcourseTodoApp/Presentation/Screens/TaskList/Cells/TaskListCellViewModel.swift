//
//  TaskListCellViewModel.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 03.11.2024.
//

import UIKit

struct TaskListCellViewModel: Equatable, Hashable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    
    var isCompletedLabelValue: String {
        return isCompleted ? "✓" : ""
    }
    
    var isCompletedLabelColor: UIColor {
        return isCompleted ? .black : .clear
    }
}

extension TaskListCellViewModel {

    init(task: TaskObject) {
        self.id = task.id
        self.title = task.title
        self.isCompleted = task.isCompleted
//        self.dateCreated = "\(NSLocalizedString("Creation date", comment: "")): \(dateFormatter.string(from: task.dateCreated))"
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
