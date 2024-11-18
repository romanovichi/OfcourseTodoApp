//
//  MockTaskActionsUseCase.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 17.11.2024.
//

import Foundation
@testable import OfcourseTodoApp

class MockTaskActionsUseCase: TaskActionsUseCaseProtocol {
    
    var fetchTaskResult: Result<TaskObject, ShowableError>?
    var removeTaskResult: Result<Bool, ShowableError>?
    var updateTaskResult: Result<TaskObject, ShowableError>?
    
    var isFetchTaskCalled = false
    var isRemoveTaskCalled = false
    var isUpdateTaskCalled = false
    
    init(fetchTaskResult: Result<TaskObject, ShowableError>? = nil,
         removeTaskResult: Result<Bool, ShowableError>? = nil,
         updateTaskResult: Result<TaskObject, ShowableError>? = nil) {
        self.fetchTaskResult = fetchTaskResult
        self.removeTaskResult = removeTaskResult
        self.updateTaskResult = updateTaskResult
    }
    
    func fetchTask(by id: UUID) async -> Result<TaskObject, ShowableError> {
        isFetchTaskCalled = true
        return fetchTaskResult ?? .failure(ShowableError.fetchTaskByIdError)
    }
    
    func removeTask(by id: UUID) async -> Result<Bool, ShowableError> {
        isRemoveTaskCalled = true
        return removeTaskResult ?? .failure(ShowableError.removeTaskError)
    }
    
    func updateTask(with id: UUID, title: String, comment: String?) async -> Result<TaskObject, ShowableError> {
        isUpdateTaskCalled = true
        return updateTaskResult ?? .failure(ShowableError.updateTaskError)
    }
}
