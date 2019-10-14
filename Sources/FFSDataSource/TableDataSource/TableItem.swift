//
//  TableItem.swift
//  FFSDataSource
//
//  Created by Alex da Franca
//  Copyright (c) 2015 Farbflash. All rights reserved.
//

import UIKit

/// TableItem
/// A single item of a TableSection object
public extension TableDataSource {
    open class TableItem {
        open var model: TableDataItemModel
        open var index: Int = 0
        open var section: Int = 0
        open var cellheight: CGFloat = 0.0
        open var visible = true
        
        public init(with model: TableDataItemModel,
                    at index: Int?=nil,
                    inSection section: Int?=nil) {
            self.model = model
            if let section = section {
                self.section = section
            }
            if let index = index {
                self.index = index
            }
            if let cHeight = model.cellHeight {
                cellheight = CGFloat(cHeight)
            }
        }
        
        public func getIndexPath() -> IndexPath {
            return IndexPath(row: index, section: section)
        }
        
        public func doSelectionAction() {
            model.onSelect?(getIndexPath(), model)
        }
        
        public func doDeselectionAction() {
            model.onDeselect?(getIndexPath(), model)
        }
        
        func updateIndexPath(row: Int, section: Int) {
            index = row
            self.section = section
        }
    }
}
