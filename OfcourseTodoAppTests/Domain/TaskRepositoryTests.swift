//
//  TaskRepositoryTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import XCTest
@testable import OfcourseTodoApp

final class TaskRepositoryTests: XCTestCase {

    var repository: TaskRepository!
    var mockDatabase: MockTaskDatabase!

    override func setUpWithError() throws {
        super.setUp()
        mockDatabase = MockTaskDatabase()
        repository = TaskRepository(database: mockDatabase)
    }

    override func tearDownWithError() throws {
        repository = nil
        mockDatabase = nil
        super.tearDown()
    }

    func test_saveTaskSuccess() async {
        let result = await repository.saveTask(title: "Test Task", comment: "This is a test task")
        switch result {
        case .success(let task):
            XCTAssertNotNil(task, "Task should not be nil")
            XCTAssertEqual(task.title, "Test Task", "Task title should be 'Test Task'")
            XCTAssertEqual(task.comment, "This is a test task", "Task comment should be 'This is a test task'")
        case .failure:
            XCTFail("Failed to save task")
        }
    }

    func test_updateTask() async {
        let saveResult = await repository.saveTask(title: "Initial Task", comment: "Initial comment")
        guard case .success(let createdTask) = saveResult else {
            XCTFail("Failed to create task")
            return
        }
        
        let updateResult = await repository.updateTask(with: createdTask.id, title: "Updated Task", comment: "Updated comment", isCompleted: true)
        
        switch updateResult {
        case .success(let updatedTask):
            XCTAssertNotNil(updatedTask, "Updated task should not be nil")
            XCTAssertEqual(updatedTask.title, "Updated Task", "Task title should be 'Updated Task'")
            XCTAssertEqual(updatedTask.comment, "Updated comment", "Task comment should be 'Updated comment'")
        case .failure:
            XCTFail("Failed to update task")
        }
    }

    func test_removeTask() async {
        let saveResult = await repository.saveTask(title: "Task to delete", comment: "Initial comment")
        guard case .success(let createdTask) = saveResult else {
            XCTFail("Failed to create task")
            return
        }

        let removeTaskResult = await repository.removeTask(by: createdTask.id)
        
        switch removeTaskResult {
        case .success(let isDeleted):
            XCTAssertTrue(isDeleted, "Task should be deleted successfully")
        case .failure:
            XCTFail("Failed to delete task")
        }
        
        let allTasksResult = await repository.fetchAllTasks()
        switch allTasksResult {
        case .success(let allTasks):
            XCTAssertTrue(allTasks.isEmpty, "Database should be empty after task is deleted")
        case .failure:
            XCTFail("Failed to fetch all tasks")
        }
    }

    func test_fetchAllTasks() async {
        await repository.saveTask(title: "Task 1", comment: "Comment 1")
        await repository.saveTask(title: "Task 2", comment: "Comment 2")

        let allTasksResult = await repository.fetchAllTasks()
        switch allTasksResult {
        case .success(let allTasks):
            XCTAssertEqual(allTasks.count, 2, "There should be 2 tasks after creation")
        case .failure:
            XCTFail("Failed to fetch all tasks")
        }
    }
}
