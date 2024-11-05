//
//  MockChangeTaskStatusUseCase.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 02.11.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockChangeTaskStatusUseCase: ChangeTaskStatusUseCaseProtocol {
    
    private(set) var changeStatusForTaskCalled = false
    
    var task: TaskObject
    
    init(task: TaskObject) {
        self.task = task
    }

    func changeStatusForTask(with id: UUID) async -> Result<TaskObject, ShowableError> {
        self.changeStatusForTaskCalled = true
        task.toggleIsCompleted()
        return .success(task)
    }
}
