//
//  CellSourceModel.swift
//  FFSDataSource
//
//  Created by Alex da Franca on 11.07.18.
//  Copyright © 2018 Farbflash. All rights reserved.
//

import Foundation

/// This is a 'sample' CellSourceModel. It complies to protocol 'TableDataItemModel'
/// It can be used or subclassed as a 'starting point' for a cell model
///
/// However any other class or struct can be used as cell models, as long as they
/// comply to protocol 'TableDataItemModel'
///
/// Your specific use case decides, whether to use your own class/struct or
/// to subclass this class as your customized model
///
open class CellSourceModel: CollapsableTableDataItemModel, ValidatableTableDataItemModel {

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

    /// Closure to configure the table cell
    open var configureTableViewCell: TableViewCellConfiguration?

    /// Closure to configure the collectionView cell
    open var configureCollectionViewCell: CollectionViewCellConfiguration?

    /// Closure to execute on cell selection
    open var onSelect: TableItemAction?

    /// Closure to execute on cell deselection
    open var onDeselect: TableItemAction?

    /// fixed cellHeight (leave nil for self sizing cells)
    open var cellHeight: Double?

    /// UITableViewRowAction's that can be applied for cell
    open var rowActions: [UITableViewRowAction]?

    public init(
        cellIdentifier: String,
        elementId: String=UUID().uuidString,
        selected: Bool=false,
        collapsed: Bool=false,
        cellHeight: Double?=nil,
        configureTableViewCell: TableViewCellConfiguration?=nil,
        configureCollectionViewCell: CollectionViewCellConfiguration?=nil,
        onSelect: TableItemAction?=nil,
        onDeselect: TableItemAction?=nil
        ) {
        self.cellIdentifier = cellIdentifier
        self.elementId = elementId
        self.configureTableViewCell = configureTableViewCell
        self.configureCollectionViewCell = configureCollectionViewCell
        self.selected = selected
        self.collapsed = collapsed
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        self.cellHeight = cellHeight
    }
}
