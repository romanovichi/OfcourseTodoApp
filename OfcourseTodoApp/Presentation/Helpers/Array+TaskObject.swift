//
//  Array+TaskObject.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 05.11.2024.
//

import Foundation

extension Array where Element == TaskObject {
    
    func mapToSortedCellViewModels(delegate: TaskListViewModelCellEventInput) -> [TaskListCellViewModel] {
        var cellViewModels = [TaskListCellViewModel]()
        cellViewModels.reserveCapacity(self.count)
        
        for task in self {
            cellViewModels.append(TaskListCellViewModel(
                id: task.id,
                title: task.title,
                isCompleted: task.isCompleted,
                delegate: delegate
            ))
        }
        
        return cellViewModels.sorted { !$0.isCompleted && $1.isCompleted }
    }
}
