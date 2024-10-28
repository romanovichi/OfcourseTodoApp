//
//  MockTaskValidationService.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockTaskValidationService: TaskValidationServiceProtocol {
    
    var validationError: ValidationError?

    func validateTitle(_ title: String) -> ValidationError? {
        return validationError
    }
}
