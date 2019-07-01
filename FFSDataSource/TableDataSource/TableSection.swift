//
//  TableSection.swift
//  FFSDataSource
//
//  Created by Alex da Franca
//  Copyright (c) 2015 Farbflash. All rights reserved.
//

import Foundation

/// TableSection
/// A single section of a TableDataSource object
public extension TableDataSource {
    open class TableSection {
        open var showSectionHeaders = false
        open var showSectionFooters = false
        open var headerData: TableDataItemModel?
        open var footerData: TableDataItemModel?
        open var index = 0
        open var visible = true
        
        // compatibility with older version, where "headerData" was "sectionData"
        public var sectionData: TableDataItemModel? {
            return headerData
        }
        
        private var tableItems = [TableItem]()
        
        deinit {
            headerData = nil
            footerData = nil
            tableItems = [TableItem]()
        }
        
        public init(with headerData: TableDataItemModel?=nil, footerData: TableDataItemModel?=nil, at index: Int?=nil) {
            self.headerData = headerData
            if let index = index {
                self.index = index
            } else {
                self.index = tableItems.count - 1
            }
        }
        
        /**
         Create, add and return a new table cell source
         
         - parameter model:  Any object to act as "payload"
         - parameter index:  optional index to insert this item to (if nil, the item will be appended to the end of the item list)
         - parameter action: closure to be executed on table cell selection AND deselection!
         
         - returns: the newly created TableDataSource.TableItem, so that it can be further configured, if necessary
         */
        @discardableResult
        open func addTableItem(with model: TableDataItemModel) -> TableItem {
            let newIndex = tableItems.count
            let newItem = TableItem(with: model, at: tableItems.count, inSection: self.index)
            tableItems.insert(newItem, at: newIndex)
            
            reIndexItems()
            return newItem
        }
        
        /**
         Does the same as the above method, except, that it returns self in order to chain item creation
         
         Example:
         let dataSrc = TableDataSource()
         dataSrc.addSection("First section")
         .addTableItemInChain "First item in section 1")
         .addTableItemInChain "Second item in section 1")
         .addTableItemInChain "Third item in section 1")
         dataSrc.showSectionHeaders = true
         
         - parameter model:  Any object to act as "payload"
         - parameter index:  optional index to insert this item to (if nil, the item will be appended to the end of the item list)
         - parameter action: optional closure to be executed on table cell selection AND deselection!
         
         - returns: returns an instance of self, so that cell creation can be chained
         */
        @discardableResult
        open func addTableItemInChain(with model: TableDataItemModel) -> TableSection {
            addTableItem(with: model)
            return self
        }
        
        /**
         Adds an already existsing TableItem to the section
         
         - parameter newItem: an instance of TableDataSource.TableItem
         - parameter index:   optional index to insert this item to (if nil, the item will be appended to the end of the item list)
         */
        open func insert(_ item: TableItem, at index: Int?=nil) {
            let cnt = tableItems.count
            var newIndex = cnt
            
            if let index = index { // just append at the end if nil
                // there is no point of filling in items here, that's a pilot error
                if cnt < index {
                    #if DEBUG
                    fatalError("FFSDataSource: Trying to insert tableItem at index \(index), but tableItems.count is \(cnt)")
                    #else
                    return
                    #endif
                }
                newIndex = index
            }
            
            tableItems.insert(item, at: newIndex)
            reIndexItems()
        }
        
        /**
         Remove all items in section
         */
        open func removeAllItems() {
            tableItems = [TableItem]()
        }
        
        /**
         Get all items in section as array
         */
        open var allItems: [TableItem] {
            return tableItems
        }
        
        /**
         Get all visible items in section as array
         */
        open var allVisibleItems: [TableItem] {
            return tableItems.filter { $0.visible }
        }
        
        func reIndexItems() {
            let visibleItems = allVisibleItems
            for i in 0..<visibleItems.count {
                visibleItems[i].updateIndexPath(row: i, section: index)
            }
        }
        
        open var numberOfTableItems: Int {
            return allVisibleItems.count
        }
        
        open func itemHeight(at index: Int) -> CGFloat {
            return item(at: index)?.cellheight ?? CGFloat(0)
        }
        
        open func item(at index: Int) -> TableItem? {
            return allVisibleItems.item(at: index)
        }
        
        @discardableResult
        open func removeItem(at index: Int) -> TableItem? {
            guard let retval = tableItems.item(at: index) else { return nil }
            tableItems.remove(at: index)
            reIndexItems()
            return retval
        }
        
        open func model(at index: Int) -> TableDataItemModel? {
            return item(at: index)?.model
        }
        
        @discardableResult
        open func removeItem(with elementId: String) -> TableItem? {
            for i in stride(from: (tableItems.count - 1), through: 0, by: -1) {
                let thisItem = tableItems[i]
                if thisItem.model.elementId == elementId {
                    tableItems.remove(at: i)
                    reIndexItems()
                    return thisItem
                }
            }
            return nil
        }
        
        func doSelectionAction(at index: Int) {
            allVisibleItems.item(at: index)?.doSelectionAction()
        }
        
        func doDeselectionAction(at index: Int) {
            allVisibleItems.item(at: index)?.doDeselectionAction()
        }
    }
}
