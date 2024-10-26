//
//  CoreDataTaskRepositoryTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 26.10.2024.
//

import XCTest
import CoreData
@testable import OfcourseTodoApp

final class CoreDataTaskRepositoryTests: XCTestCase {

    var repository: CoreDataTaskRepository!
    var persistentContainer: NSPersistentContainer!

    override func setUpWithError() throws {

        super.setUp()
        
        persistentContainer = NSPersistentContainer(name: "OfcourseTodoApp")
        
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load store: \(error), \(error.userInfo)")
            }
        }
        
        repository = CoreDataTaskRepository(persistentContainer: persistentContainer)
    }

    override func tearDownWithError() throws {
        repository = nil
        persistentContainer = nil
        super.tearDown()
    }
    
    func testCreateTask() {
        let task = repository.saveTask(title: "Test Task", comment: "This is a test task")
        XCTAssertNotNil(task, "Task should not be nil")
        XCTAssertEqual(task?.title, "Test Task", "Task title should be 'Test Task'")
        XCTAssertEqual(task?.comment, "This is a test task", "Task comment should be 'This is a test task'")
    }
    
    func testUpdateTask() {

        guard let createdTask = repository.saveTask(title: "Initial Task", comment: "Initial comment") else {
            XCTFail("Failed to create task")
            return
        }
        
        let updatedTask = repository.updateTask(with: createdTask.id, title: "Updated Task", comment: "Updated comment", isCompleted: true)
        
        XCTAssertNotNil(updatedTask, "Updated task should not be nil")
        XCTAssertEqual(updatedTask?.title, "Updated Task", "Task title should be 'Updated Task'")
        XCTAssertEqual(updatedTask?.comment, "Updated comment", "Task comment should be 'Updated comment'")
    }
    
    func testRemoveTask() {

        guard let createdTask = repository.saveTask(title: "Task to delete", comment: "Initial comment") else {
            XCTFail("Failed to create task")
            return
        }

        XCTAssertNotNil(createdTask, "Task created successfully")

        let removeTaskResult = repository.removeTask(by: createdTask.id)
        
        switch removeTaskResult {
        case let .success(isDeleted):
            XCTAssertTrue(isDeleted, "Task should be deleted successfully")
        case .failure:
            XCTFail("Failed to delete task")
        }
        
        let allTasksAfterDeletion = repository.fetchAllTasks()
        XCTAssertTrue(allTasksAfterDeletion.isEmpty, "Database should be empty after task is deleted")
    }

    func testFetchAllTasks() {
        
        let task1 = repository.saveTask(title: "Task 1", comment: "Comment 1")
        let task2 = repository.saveTask(title: "Task 2", comment: "Comment 2")
        
        XCTAssertNotNil(task1, "Task 1 should be created successfully")
        XCTAssertNotNil(task2, "Task 2 should be created successfully")
        
        let allTasksAfter = repository.fetchAllTasks()
        
        XCTAssertEqual(allTasksAfter.count, 2, "There should be 2 tasks after creation")
        
        XCTAssertEqual(allTasksAfter[0].title, "Task 1")
        XCTAssertEqual(allTasksAfter[1].title, "Task 2")
        XCTAssertEqual(allTasksAfter[0].comment, "Comment 1")
        XCTAssertEqual(allTasksAfter[1].comment, "Comment 2")
    }
    
    func testFetchIncompleteTasks() {
        repository.saveTask(title: "Task 1", comment: nil, isCompleted: true)
        repository.saveTask(title: "Task 2", comment: nil)
        repository.saveTask(title: "Task 3", comment: nil, isCompleted: true)
    
        let incompleteTasks = repository.fetchIncompleteTasks()
        XCTAssertEqual(incompleteTasks.count, 1)
    }

    func testSearchTasksWithFilter() {
        
        repository.saveTask(title: "Important Task", comment: nil, isCompleted: true)
        repository.saveTask(title: "Less Important Task", comment: nil)
        repository.saveTask(title: "Another Task", comment: nil)
        
        let allTasks = repository.searchTasks(by: "Important")
        XCTAssertEqual(allTasks.count, 2)
        
        let incompleteTasks = repository.searchTasks(by: "Important", includeOnlyIncomplete: true)
        XCTAssertEqual(incompleteTasks.count, 1)
    }

}
