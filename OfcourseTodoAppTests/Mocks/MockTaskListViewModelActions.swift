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
    private(set) var shownTask: TaskObject?

    func makeActions() -> TaskListViewModelActions {
        return TaskListViewModelActions(
            showTaskDetails: { [weak self] task in
                self?.didShowTaskDetails = true
                self?.shownTask = task
            },
            addNewTask: { [weak self] in
                self?.didAddNewTask = true
            }
        )
    }
}
