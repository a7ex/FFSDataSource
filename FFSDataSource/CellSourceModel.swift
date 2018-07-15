//
//  CellSourceModel.swift
//  FFSDataSource
//
//  Created by Alex da Franca on 11.07.18.
//  Copyright © 2018 Farbflash. All rights reserved.
//

import UIKit

public protocol ReuseIdentifierProvider where Self: UIView {
    static var reuseIdentifier: String { get }
}

/// This is a 'sample' CellSourceModel. It complies to protocol 'TableDataItemModel'
/// It can be used or subclassed as a 'starting point' for a cell model
///
/// However any other class or struct can be used as cell models, as long as they
/// comply to protocol 'TableDataItemModel'
///
/// Your specific use case decides, whether to use your own class/struct or
/// to subclass this class as your customized model
///
open class CellSourceModel<T: ReuseIdentifierProvider>: CollapsableTableDataItemModel, ValidatableTableDataItemModel {
    
    /// ID (unique??) of this element as string
    open var elementId: String

    /// TableViewCell storyboard identifier to be used, when dequeing a reusable UITableViewCell
    open var cellIdentifier: String

    /// Boolean flag for checkbox-style buttons
    open var selected: Bool

    /// "Shadow"-height of collapsable cells (e.g. cells with a picker)
    open var cellExpandHeightDifference = 0

    /// Boolean flag of the current collapsed state of a collapsable cell
    open var collapsed: Bool

    /// Closure to execute in order to evaluate the model
    open var evaluation:((_ model: TableDataItemModel) -> Bool)?

    /// Closure to configure the cell
    open var configureCell: CellConfiguration?

    /// Closure to execute on cell selection
    open var onSelect: CellAction?

    /// Closure to execute on cell deselection
    open var onDeselect: CellAction?

    /// fixed cellHeight (leave nil for self sizing cells)
    open var cellHeight: Double?

    /// UITableViewRowAction's that can be applied for cell
    open var rowActions: [UITableViewRowAction]?

    public init<V: CellSourceModel>(
        cellIdentifier: String=T.reuseIdentifier,
        elementId: String=UUID().uuidString,
        selected: Bool=false,
        collapsed: Bool=false,
        cellHeight: Double?=nil,
        configureCell: ((T, V, IndexPath) -> Void)?=nil,
        onSelect: CellAction?=nil,
        onDeselect: CellAction?=nil
        ) {
        self.cellIdentifier = cellIdentifier
        self.elementId = elementId
        self.configureCell = { (cell, model, indexPath) in
            guard let cell = cell as? T else {
                fatalError("Wrong cell subclass was specified!")
            }
            guard let model = model as? V else {
                fatalError("Model class is wrong!")
            }
            configureCell?(cell, model, indexPath)
        }
        self.selected = selected
        self.collapsed = collapsed
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        self.cellHeight = cellHeight
    }
}
