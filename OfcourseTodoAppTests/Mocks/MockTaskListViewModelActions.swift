//
//  MockTaskListViewModelActions.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 02.11.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockTaskListViewModelActions {
    private(set) var didShowTaskDetails = false
    private(set) var didAddNewTask = false
    private(set) var shownTaskId: UUID?

    func makeActions() -> TaskListViewModelActions {
        return TaskListViewModelActions(
            showDetailsForTask: { [weak self] id in
                self?.didShowTaskDetails = true
                self?.shownTaskId = id
            },
            addNewTask: { [weak self] in
                self?.didAddNewTask = true
            }
        )
    }
}
