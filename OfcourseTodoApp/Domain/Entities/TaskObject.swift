//
//  TodoTaskEntity.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import Foundation
import CoreData

struct TaskObject: Hashable {
    
    let id: UUID
    let title: String
    let comment: String?
    var isCompleted: Bool
    let dateCreated: Date
    
    init(id: UUID, title: String, comment: String?, isCompleted: Bool = false, dateCreated: Date? = Date()) {
        self.id = id
        self.title = title
        self.comment = comment
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated ?? Date()
    }
    
    mutating func toggleIsCompleted() {
        isCompleted = !isCompleted
    }
}
