//
//  TableDataItemModel.swift
//  FFSDataSource
//
//  Created by Alex da Franca
//  Copyright (c) 2015 Farbflash. All rights reserved.
//

import Foundation

/// Elements which conform to TableDataItemModel represent an item in the datasource.
/// You can use either a class or a struct to represent a model.
/// For your convenience there is a specified baseclass CellSourceModel
/// to use 'as is' or as a starting point by subclassing or extending.
public protocol TableDataItemModel {
    
    /// The cellReuseIdentifier to be used to dequeue a cell
    /// - required
    var cellIdentifier: String { get set }
    
    /// Any string to identify the model
    /// Must not necessarly be unique
    /// - optional (defaults to unique UUID)
    var elementId: String { get set }
    
    /// Specify a fixed cellheight
    /// - optional
    var cellHeight: Double? { get set }
    
    /// Closure to execute on selection of the cell
    /// Provided parameters are: indexPath and model
    /// - optional
    var onSelect: CellAction? { get set }
    
    /// Closure to execute on deSelection of the cell
    /// Provided parameters are: indexPath and model
    /// - optional
    var onDeselect: CellAction? { get set }
    
    /// Closure to execute on creation of the cell (dequeuing from tableView)
    /// Provided parameters are: cell, model and indexPath
    /// - optional
    var configureCell: CellConfiguration? { get set }
    
    /// The associated UITableViewRowActions for the cell
    /// - optional
    var rowActions: [UITableViewRowAction]? { get set }
}

/// A specialized type of TableDataItemModel, which supports collapsing.
/// Elements conforming to this protocol provide information to collapse/expand the cell
public protocol CollapsableTableDataItemModel: TableDataItemModel {
    
    /// The delta of between collapsed and uncollapsed rowHeight
    /// This is kind of an alternate rowHeight
    /// - optional (default: 0)
    var cellExpandHeightDifference: Int { get }
    
    /// A boolean flag, whether or not the cell height shall be
    /// with or without the cellExpandHeightDifference
    /// - optional (default: false)
    var collapsed: Bool { get }
}

/// A specialized type of TableDataItemModel, which supports validation.
/// Elements conforming to this protocol provide a closure to evaluate the cell content
public protocol ValidatableTableDataItemModel: TableDataItemModel {
    
    /// Closure to execute to validate the model
    /// Provided parameter is the model
    /// Must return a boolean
    /// - optional (default: returns true => model is not validated => success)
    var onEvaluate: ((_ model: TableDataItemModel) -> [String]?) { get }

    /// Call the onEvaluate closure and return false in case of failed validation
    /// or return true in case of successful validation
    ///
    /// - Returns: boolean result
    func evaluate() -> [String]?
}

public extension ValidatableTableDataItemModel {
    
    /// Default implementation of evaluate() function for convenience
    ///
    /// - Returns: the receiver, if onEvaluate() returns false, or nil, if onEvaluate() returns true
    func evaluate() -> [String]? {
        return onEvaluate(self)
    }
}
