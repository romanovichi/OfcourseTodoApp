//
//  TaskValidationService.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation

protocol TaskValidationServiceProtocol {
    func validateTitle(_ title: String) -> ShowableError?
}

final class TaskValidationService: TaskValidationServiceProtocol {
    
    private let maxTitleLength = 100

    func validateTitle(_ title: String) -> ShowableError? {
        
        if title.isEmpty {
            return .validationError
        }
        if title.count > maxTitleLength {
            return .validationError
        }
        
        return nil
    }
}
