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
    
    var description: String {
        switch self {
        case .createNewTaskError:
            return "Can't create new task, try again"
        case .updateTaskError:
            return "Can't update task"
        case .removeTaskError:
            return "Couldn't remove task from storage"
            
        case .fetchDatabaseError:
            return "Can't fetch tasks from storage"
        case .fetchIncompleteTasksError:
            return "Can't fetch incompleted tasks from storage"
        case .fetchTaskByIdError:
            return "Couldn't fetch task from storage"
        case .searchTasksError:
            return "Can't search tasks in storage"
            
        case .titleIsEmptyError:
            return "Task title is empty"
        case .titleTooLongError:
            return "Task title should be less than 100 symbols"
        case .commentTooLongError:
            return "Task comment should be less than 500 symbols"
            
        case .unknownError:
            return "Some unknown error, our scienists are already researching it"
        }
    }
}
