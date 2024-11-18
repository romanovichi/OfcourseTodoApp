//
//  MockAddNewTaskUseCase.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 17.11.2024.
//

import Foundation
@testable import OfcourseTodoApp

class MockAddNewTaskUseCase: AddNewTaskUseCaseProtocol {
    
    var createTaskResult: Result<TaskObject, ShowableError>?
    var isCreateTaskCalled = false
    
    init(createTaskResult: Result<TaskObject, ShowableError>? = nil) {
        self.createTaskResult = createTaskResult
    }
    
    func createTask(title: String, comment: String?) async -> Result<TaskObject, ShowableError> {
        isCreateTaskCalled = true
        return createTaskResult ?? .failure(ShowableError.createNewTaskError)
    }
}
