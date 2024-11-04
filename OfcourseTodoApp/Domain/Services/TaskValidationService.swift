//
//  TaskValidationService.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation

protocol TaskValidationServiceProtocol {
    func validateTitle(_ title: String) -> ShowableError?
    func validateComment(_ comment: String) -> ShowableError?
}

final class TaskValidationService: TaskValidationServiceProtocol {
    
    private let maxTitleLength = 100
    private let maxCommentLength = 500

    func validateTitle(_ title: String) -> ShowableError? {
        
        if title.isEmpty {
            return .titleIsEmptyError
        }
        if title.count > maxTitleLength {
            return .titleTooLongError
        }
        
        return nil
    }
    
    func validateComment(_ comment: String) -> ShowableError? {
        
        if comment.count > maxCommentLength {
            return .commentTooLongError
        }
        
        return nil
    }
}
