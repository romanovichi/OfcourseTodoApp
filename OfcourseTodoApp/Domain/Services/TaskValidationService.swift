//
//  TaskValidationService.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation

protocol TaskValidationServiceProtocol {
    func validateTitle(_ title: String) -> ValidationError?
}

enum ValidationError: Error {
    case emptyTitle
    case titleTooLong
}

final class TaskValidationService: TaskValidationServiceProtocol {
    
    private let maxTitleLength = 100

    func validateTitle(_ title: String) -> ValidationError? {
        
        if title.isEmpty {
            return .emptyTitle
        }
        if title.count > maxTitleLength {
            return .titleTooLong
        }
        
        return nil
    }
}
