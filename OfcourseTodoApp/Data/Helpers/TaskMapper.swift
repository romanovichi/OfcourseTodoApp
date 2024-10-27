//
//  Mapper.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import Foundation
import CoreData

class TaskMapper {
    
    static func mapToObject(taskEntity: TaskEntity) -> Task {
        return Task(
            id: taskEntity.uuid,
            title: taskEntity.title ?? "",
            comment: taskEntity.comment,
            isCompleted: taskEntity.isCompleted,
            dateCreated: taskEntity.dateCreated
        )
    }
}
