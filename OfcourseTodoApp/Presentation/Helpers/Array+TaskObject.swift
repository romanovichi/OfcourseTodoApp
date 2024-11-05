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

extension Array where Element == TaskListCellViewModel {
    
    /// Updates an element in the array with the same ID as `updatedElement`.
    /// - Parameter updatedElement: The element with the updated properties.
    mutating func updateWithElement(_ updatedElement: Element) {
        if let index = self.firstIndex(where: { $0.id == updatedElement.id }) {
            self[index] = updatedElement
        }
    }
}
