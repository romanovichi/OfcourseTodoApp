//
//  TaskModel.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 08.11.2024.
//

import Foundation

struct TaskModel: Equatable {
    
    let id: UUID
    var title: String
    var comment: String?
    
    internal init(id: UUID, title: String, comment: String? = nil) {
        self.id = id
        self.title = title
        self.comment = comment
    }
    
    init(taskObject: TaskObject) {
        self.id = taskObject.id
        self.title = taskObject.title
        self.comment = taskObject.comment
    }
}
