//
//  MockTaskValidationService.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockTaskValidationService: TaskValidationServiceProtocol {
    
    var validateTitleError: ShowableError?
    var validateCommentError: ShowableError?
    
    private(set) var validateTitleCalled = false
    private(set) var validateCommentCalled = false
    
    func validateTitle(_ title: String) -> ShowableError? {
        validateTitleCalled = true
        return validateTitleError
    }
    
    func validateComment(_ comment: String) -> ShowableError? {
        validateCommentCalled = true
        return validateCommentError
    }
}
