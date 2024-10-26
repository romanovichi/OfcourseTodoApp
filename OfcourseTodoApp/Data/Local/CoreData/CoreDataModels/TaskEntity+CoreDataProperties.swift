//
//  TaskEntity+CoreDataProperties.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 26.10.2024.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var title: String?
    @NSManaged public var comment: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var isCompleted: Bool

}

extension TaskEntity : Identifiable {

}
