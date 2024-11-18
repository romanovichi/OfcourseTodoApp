//
//  MockTaskViewModelActions.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 17.11.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockTaskViewModelActions {
    
    private(set) var didCloseCalled = false

    func makeActions() -> TaskViewModelActions {
        return TaskViewModelActions(
            close: { [weak self] in
                self?.didCloseCalled = true
            }
        )
    }
}
