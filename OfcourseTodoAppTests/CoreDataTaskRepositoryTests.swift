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
        
        let updatedTask = repository.updateTask(with: createdTask.id, title: "Updated Task", comment: "Updated comment")
        
        XCTAssertNotNil(updatedTask, "Updated task should not be nil")
        XCTAssertEqual(updatedTask?.title, "Updated Task", "Task title should be 'Updated Task'")
        XCTAssertEqual(updatedTask?.comment, "Updated comment", "Task comment should be 'Updated comment'")
    }
}
