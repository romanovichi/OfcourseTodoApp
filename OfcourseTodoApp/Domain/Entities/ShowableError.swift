//
//  ShowableError.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 05.11.2024.
//

import Foundation

enum ShowableError: Error {
    
    case createNewTaskError
    case updateTaskError
    case removeTaskError

    case fetchDatabaseError
    case fetchIncompleteTasksError
    case fetchTaskByIdError
    case searchTasksError

    case titleIsEmptyError
    case titleTooLongError
    case commentTooLongError
    
    case unknownError
}
