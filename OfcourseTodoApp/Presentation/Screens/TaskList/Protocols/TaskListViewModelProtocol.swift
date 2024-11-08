//
//  TaskListViewModelActions.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 08.11.2024.
//

import Foundation
import RxSwift

typealias TaskListViewModelProtocol = TaskListViewModelInput & TaskListViewModelOutput & TaskListViewModelCellEventInput

protocol TaskListViewModelInput {
    func initialLoad()
    func updateData()
    func addNewTask()
    func toggleCompletionFilter()
    func search(by title: String)
    func resetSearch()
    func showItemWith(id: UUID)
}

protocol TaskListViewModelCellEventInput: AnyObject {
    func completeTaskWith(id: UUID)
}

protocol TaskListViewModelOutput {
    var errorTitle: String { get }
    var updatedItem: BehaviorSubject<TaskListCellViewModel?> { get }
    var taskCellViewModels: BehaviorSubject<[TaskListCellViewModel]> { get }
    var error: BehaviorSubject<String> { get }
    var isIncompleteFilter: BehaviorSubject<Bool> { get }
}

