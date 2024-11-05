//
//  MockFetchTasksUseCase.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 02.11.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockFetchTasksUseCase: FetchTasksUseCaseProtocol {
        
    var isFetchAllTasksCalled = false
    var isFetchIncompletedTasksCalled = false
    var isSearchByCalled = false

    var result: Result<[TaskObject], ShowableError>
    
    init(result: Result<[TaskObject], ShowableError>) {
        self.result = result
    }

    func fetchAllTasks() async -> Result<[TaskObject], ShowableError> {
        isFetchAllTasksCalled = true
        return result
    }
    
    func fetchIncompleteTasks() async -> Result<[TaskObject], ShowableError> {
        isFetchIncompletedTasksCalled = true
        return result
    }
    
    func searchTasks(by title: String, includeOnlyIncomplete: Bool) async -> Result<[TaskObject], ShowableError> {
        isSearchByCalled = true
        switch result {
        case .success(let tasks):
            let filteredTasks = tasks.filter { $0.title.contains(title) }
            return .success(filteredTasks)
        case .failure(let error):
            return .failure(error)
        }
    }
}
