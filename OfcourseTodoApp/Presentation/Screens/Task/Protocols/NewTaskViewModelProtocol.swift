//
//  NewTaskViewModelProtocol.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 08.11.2024.
//

import Foundation
import RxSwift

typealias NewTaskViewModelProtocol = NewTaskViewModelInput & NewTaskViewModelOutput

protocol NewTaskViewModelInput {
    func initialLoad()
    func onDelete()
    func onSave(title: String, comment: String)
}

protocol NewTaskViewModelOutput {
    var errorTitle: String { get }

    var fetchedTask: BehaviorSubject<TaskModel?> { get }
    var error: BehaviorSubject<String> { get }
}
