//
//  CoreDataTaskRepositoryTests.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 26.10.2024.
//

import XCTest
import CoreData
@testable import OfcourseTodoApp

final class CoreDataTaskDatabaseTests: XCTestCase {

    var repository: CoreDataTaskDatabase!
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
        
        repository = CoreDataTaskDatabase(persistentContainer: persistentContainer)
    }

    override func tearDownWithError() throws {

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TaskEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to delete all data: \(error)")
        }
        
        repository = nil
        persistentContainer = nil
        super.tearDown()
    }

    
    func test_createTask() async {
        let result = await repository.saveTask(title: "Test Task", comment: "This is a test task")
        
        switch result {
        case .success(let task):
            XCTAssertNotNil(task, "Task should not be nil")
            XCTAssertEqual(task.title, "Test Task", "Task title should be 'Test Task'")
            XCTAssertEqual(task.comment, "This is a test task", "Task comment should be 'This is a test task'")
        case .failure(let error):
            XCTFail("Failed to create task: \(error)")
        }
    }
    
    func test_updateTask() async {
        let createResult = await repository.saveTask(title: "Initial Task", comment: "Initial comment")
        
        guard case let .success(createdTask) = createResult else {
            XCTFail("Failed to create task")
            return
        }
        
        let updateResult = await repository.updateTask(with: createdTask.id, title: "Updated Task", comment: "Updated comment", isCompleted: true)
        
        switch updateResult {
        case .success(let updatedTask):
            XCTAssertNotNil(updatedTask, "Updated task should not be nil")
            XCTAssertEqual(updatedTask.title, "Updated Task", "Task title should be 'Updated Task'")
            XCTAssertEqual(updatedTask.comment, "Updated comment", "Task comment should be 'Updated comment'")
        case .failure(let error):
            XCTFail("Failed to update task: \(error)")
        }
    }
    
    func test_removeTask() async {
        let createResult = await repository.saveTask(title: "Task to delete", comment: "Initial comment")
        
        guard case let .success(createdTask) = createResult else {
            XCTFail("Failed to create task")
            return
        }

        XCTAssertNotNil(createdTask, "Task created successfully")

        let removeResult = await repository.removeTask(by: createdTask.id)
        
        switch removeResult {
        case .success(let isDeleted):
            XCTAssertTrue(isDeleted, "Task should be deleted successfully")
        case .failure(let error):
            XCTFail("Failed to delete task: \(error)")
        }
        
        let allTasksResult = await repository.fetchAllTasks()
        switch allTasksResult {
        case .success(let tasks):
            XCTAssertTrue(tasks.isEmpty, "Database should be empty after task is deleted")
        case .failure(let error):
            XCTFail("Failed to fetch tasks after deletion: \(error)")
        }
    }

    func test_fetchAllTasks() async {
        let _ = await repository.saveTask(title: "Task 1", comment: "Comment 1")
        let _ = await repository.saveTask(title: "Task 2", comment: "Comment 2")
        
        let allTasksResult = await repository.fetchAllTasks()
        
        switch allTasksResult {
        case .success(let allTasks):
            XCTAssertEqual(allTasks.count, 2, "There should be 2 tasks after creation")
            XCTAssertEqual(allTasks[0].title, "Task 1")
            XCTAssertEqual(allTasks[1].title, "Task 2")
            XCTAssertEqual(allTasks[0].comment, "Comment 1")
            XCTAssertEqual(allTasks[1].comment, "Comment 2")
        case .failure(let error):
            XCTFail("Failed to fetch all tasks: \(error)")
        }
    }
    
    func test_fetchIncompleteTasks() async {
        await repository.saveTask(title: "Task 1", comment: nil, isCompleted: true)
        await repository.saveTask(title: "Task 2", comment: nil)
        await repository.saveTask(title: "Task 3", comment: nil, isCompleted: true)
    
        let incompleteTasksResult = await repository.fetchIncompleteTasks()
        
        switch incompleteTasksResult {
        case .success(let incompleteTasks):
            XCTAssertEqual(incompleteTasks.count, 1, "There should be 1 incomplete task")
        case .failure(let error):
            XCTFail("Failed to fetch incomplete tasks: \(error)")
        }
    }

    func test_searchTasksWithFilter() async {
        await repository.saveTask(title: "Important Task", comment: nil, isCompleted: true)
        await repository.saveTask(title: "Less Important Task", comment: nil)
        await repository.saveTask(title: "Another Task", comment: nil)
        
        let searchResult = await repository.searchTasks(by: "Important")
        
        switch searchResult {
        case .success(let allTasks):
            XCTAssertEqual(allTasks.count, 2, "There should be 2 tasks with 'Important' in the title")
        case .failure(let error):
            XCTFail("Failed to search tasks: \(error)")
        }
        
        let incompleteSearchResult = await repository.searchTasks(by: "Important", includeOnlyIncomplete: true)
        switch incompleteSearchResult {
        case .success(let incompleteTasks):
            XCTAssertEqual(incompleteTasks.count, 1, "There should be 1 incomplete task with 'Important' in the title")
        case .failure(let error):
            XCTFail("Failed to search for incomplete tasks: \(error)")
        }
    }
}
