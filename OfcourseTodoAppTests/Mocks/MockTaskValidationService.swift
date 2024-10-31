//
//  MockTaskValidationService.swift
//  OfcourseTodoAppTests
//
//  Created by Иван Романович on 28.10.2024.
//

import Foundation
@testable import OfcourseTodoApp

final class MockTaskValidationService: TaskValidationServiceProtocol {
    
    var validationError: ShowableError?

    func validateTitle(_ title: String) -> ShowableError? {
        return validationError
    }
}
