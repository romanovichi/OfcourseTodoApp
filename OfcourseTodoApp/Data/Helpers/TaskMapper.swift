//
//  Mapper.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//

import Foundation
import CoreData

class TaskMapper {
    
    static func mapToObject(taskEntity: TaskEntity) -> TaskObject {
        return TaskObject(
            id: taskEntity.uuid,
            title: taskEntity.title ?? "",
            comment: taskEntity.comment,
            isCompleted: taskEntity.isCompleted,
            dateCreated: taskEntity.dateCreated
        )
    }
}
