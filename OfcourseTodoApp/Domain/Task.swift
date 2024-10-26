//
//  TodoTaskEntity.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import Foundation
import CoreData

struct Task {
    
    let id: NSManagedObjectID
    let title: String
    let comment: String?
    let isCompleted: Bool
    let dateCreated: Date
    
    init(id: NSManagedObjectID, title: String, comment: String?, isCompleted: Bool = false, dateCreated: Date? = Date()) {
        self.id = id
        self.title = title
        self.comment = comment
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated ?? Date()
    }
}
