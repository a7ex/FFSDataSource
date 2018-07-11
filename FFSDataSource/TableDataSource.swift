//
//  TableDataSource.swift
//
//  Created by Alex da Franca on 04/02/17.
//  Copyright (c) 2015 Farbflash. All rights reserved.
//

import Foundation
import UIKit

/**
 TableDataSource is a class to provide an object for UITableView datasources and delegates
 It can be used as MODEL for UITableViews and UICollectionViews, providing cell actions as closures
 
 EXAMPLE:
 ```swift
 let dataSource = TableDataSource()
 let section = dataSource.addSection()
 dataSrc.addSection("First section")
 .addTableItemInChain "First item in section 1")
 .addTableItemInChain "Second item in section 1")
 .addTableItemInChain "Third item in section 1 with a closure to act on user taps", atIndex: nil) { (indexPath, userInfo, isDeselectionEvent) -> Void in
 if !isDeselectionEvent {
 print("User selected 'Third item in section 1 with closure'")
 }
 }
 dataSrc.showSectionHeaders = true
 ```
 */


fileprivate extension Array {
    /**
     Access elements of array without index out of range error
     
     This method checks, whether the specified index in the array is within the bounds of the array
     and if NOT returns a default value, which can also be specified optionally
     
     Example:
     print(myArray.valueAt(index: -2, "Not found"))
     -- "Not found"
     
     - parameter index:        Integer zero-based index of element in array
     - parameter defaultValue: optional default value to return in case of out of bounds index (default = nil)
     
     - returns: element of array at index position OR defaultValue (nil)
     */
    func item(at index: Int, defaultValue: Element?=nil) -> Element? {
        return (index >= 0 && index < count) ? self[index] : defaultValue
    }
}

public protocol TableDataItemModel {
    var cellIdentifier: String { get set }
    var elementId: String { get set }
    var cellHeight: Double? { get set }
    var onSelect: TableItemAction? { get set }
    var onDeselect: TableItemAction? { get set }
    var configureTableViewCell: TableViewCellConfiguration? { get set }
    var configureCollectionViewCell: CollectionViewCellConfiguration? { get set }
    var rowActions: [UITableViewRowAction]? { get set }
}

public protocol CollapsableTableDataItemModel: TableDataItemModel {
    var cellExpandHeightDifference: Int { get }
    var collapsed: Bool { get }
}

public protocol ValidatableTableDataItemModel: TableDataItemModel {
    var evaluation: ((_ model: TableDataItemModel) -> Bool)? { get }
}

public typealias TableItemAction = (IndexPath, TableDataItemModel) -> Void
public typealias TableViewCellConfiguration = (UITableViewCell, TableDataItemModel, IndexPath) -> Void
public typealias CollectionViewCellConfiguration = (UICollectionViewCell, TableDataItemModel, IndexPath) -> Void

open class TableDataSource {
    
    /** @name Properties */
    
    /**
     Boolean value whether to display section headers.
     Note, that this property doesn't do anything on its own.
     Its purpose is to provide that info to the UITableViewDataSource
     */
    open var showTableHeader: Bool = false
    
    /**
     Boolean value whether to display table headers.
     Note, that this property doesn't do anything on its own.
     Its purpose is to provide that info to the UITableViewDataSource
     */
    open var showSectionHeaders: Bool = false {
        didSet {
            for thisSection in sections {
                thisSection.showSectionHeaders = showSectionHeaders
            }
        }
    }
    
    /**
     Array with objects of class TableDataSource.TableSection, for every section one
     */
    private var sections = [TableSection]()
    
    public init() { }
    
    deinit {
        sections.removeAll(keepingCapacity: false)
    }
    
    /**
     Add new leaf node to the datasource model
     
     - parameter model: any object which acts as model for a single cell
     - parameter index: index where to insert the model or nil to append at the end
     - parameter section: section index where to insert model or nil to append at the currently last section
     - parameter action: block to be executed or nil
     - returns: newly created leaf node of class TableDataSource.TableItem
     */
    @discardableResult
    open func addTableItem(with model: TableDataItemModel,
                           toSection section: Int?=nil) -> TableItem {
        
        let cnt = sections.count
        var insertInSection = 0
        
        if let section = section {
            if cnt <= section { // fill empty slots, if any
                for _ in cnt...section {
                    addSection()
                }
            }
            insertInSection = section
        }
        else { // just append at the end if nil
            if cnt < 1 { addSection() }
            else { insertInSection = cnt - 1 }
        }
        
        return sections[insertInSection].addTableItem(with: model)
    }
    
    open func insert(tableItem: TableItem,
                     atIndex index: Int?=nil,
                     inSection section: Int?=nil) {
        let cnt = sections.count
        var insertInSection = 0
        
        if let section = section {// fill empty slots, if any
            if cnt <= section {
                for _ in cnt...section {
                    addSection()
                }
            }
            insertInSection = section
        }
        else {
            // just append at the end if nil
            if cnt < 1 { addSection() }
            else { insertInSection = cnt - 1 }
        }
        sections[insertInSection].insert(tableItem, at: index)
    }
    
    /**
     Add a section to the datasource model
     
     - parameter title: A NSString to be used as the title of the section, if the property showSectionHeaders is YES
     - parameter index: section index where to insert model or nil to append at the currently last section
     - returns: newly created section object of class TableDataSource.TableSection
     */
    @discardableResult
    open func addSection(with sectionData: TableDataItemModel = TableSection.defaultModel, atIndex index: Int?=nil) -> TableSection {
        var cnt = sections.count
        var newIndex = cnt
        
        if let index = index { // just append at the end if nil
            // fill empty slots, if any
            if cnt < index {
                for _ in cnt..<index {
                    addSection()
                }
            }
            newIndex = index
        }
        
        let newSection = TableSection(with: sectionData, at: newIndex)
        sections.insert(newSection, at: newIndex)
        
        newSection.showSectionHeaders = showSectionHeaders
        
        cnt = sections.count
        for i in (newIndex + 1)..<cnt {
            sections[i].index = i
        }
        return newSection
    }
    
    /**
     Add an existing section to the datasource model
     - parameter section: A TableDataSource.TableSection object to insert
     - parameter index: section index where to insert model or nil to append at the currently last section
     */
    open func insert(_ section: TableSection, atIndex index: Int?=nil) {
        let cnt = sections.count
        var newIndex = cnt
        
        if let index = index { // just append at the end if nil
            // fill empty slots, if any
            if cnt < index {
                for _ in cnt ..< index {
                    addSection()
                }
            }
            newIndex = index
        }
        sections.insert(section, at: newIndex)
        
        for i in (newIndex + 1)..<sections.count {
            sections[i].index = i
        }
    }
    
    /**
     Remove an existing section from the datasource model
     - parameter itemTitle: title of section to remove
     */
    open func remove(_ section: TableSection) {
        sections.remove(at: section.index)
        
        for i in 0..<sections.count {
            sections[i].index = i
        }
    }
    
    /**
     Remove an existing section from the datasource model by title
     - parameter itemTitle: title of section to remove
     */
    open func removeSection(with elementId: String) -> TableSection? {
        for i in stride(from: (sections.count - 1), through: 0, by: -1) {
            let thisItem = sections[i]
            if thisItem.sectionData.elementId == elementId {
                sections.remove(at: i)
                for i in 0..<sections.count {
                    sections[i].index = i
                }
                return thisItem
            }
        }
        return nil
    }
    
    /**
     Get a section by title
     - parameter index: section index
     - returns: section object of class TableDataSource.TableSection with title 'title' or nil
     */
    open func section(at index: Int) -> TableSection? {
        return sections.item(at: index)
    }
    
    /**
     Get a section by title
     - parameter sectionTitle: A NSString to be used as the title of the section.
     - returns: section object of class TableDataSource.TableSection with title 'title' or nil
     */
    open func section(with elementId: String) -> TableSection? {
        return sections.first(where: { $0.sectionData.elementId == elementId })
    }
    
    /**
     reindex items
     */
    open func reIndexItems() {
        for i in 0..<sections.count {
            sections[i].index = i
            sections[i].reIndexItems()
        }
    }
    
    /** @name UITableDataSource methods */
    
    /**
     Number of sections in datasource model
     
     This can/should be used directly in the UITableView datasource method:
     
     func numberOfSectionsInTableView(tableView:UITableView) {
     return <TableDataSourceInstance>.numberOfSectionsInTable()
     }
     
     - returns: NSInteger
     */
    open func numberOfSections() -> Int {
        return sections.count
    }
    
    /**
     Number of row items for a given section
     
     This can/should be used directly in the UITableView datasource method:
     
     func tableView(tableView:UITableView, numberOfRowsInSection, section:Int) {
     return <TableDataSourceInstance>.numberOfItems(in: section)
     }
     
     - parameter section: NSInteger for the section
     - returns: NSInteger
     */
    open func numberOfItems(in section: Int) -> Int {
        return sections.item(at: section)?.numberOfTableItems ?? 0
    }
    
    /** @name Get properties of sections and items */
    
    /**
     Get the title of the section at the given index or nil, if showSection = false
     The difference is, that it can be directly used in tableView delegate's titleForHeaderInSection
     - parameter index: index of section
     - returns: the title of the section as string OR nil
     */
    open func sectionData(for section: Int) -> TableDataItemModel? {
        guard sections.count > section,
            sections[section].showSectionHeaders else {
                return nil
        }
        return sections[section].sectionData
    }
    
    /**
     Get the height for a given row item
     
     If the leaf model responds to selector 'height' that value will be used (defaults to 44.0)
     The selector 'height' must return a CGFloat
     
     - parameter indexPath: The path to the row item
     - returns: The height of the row item
     */
    open func itemHeight(at indexPath: IndexPath) -> CGFloat {
        guard sections.count > indexPath.section else { return CGFloat(0.0) }
        return sections[indexPath.section].itemHeight(at: indexPath.row)
    }
    
    /**
     Get the leaf node of the class TableDataSource.TableItem
     - parameter indexPath: The path to the item
     - returns: an object of class TableDataSource.TableItem
     */
    open func item(at indexPath: IndexPath) -> TableItem? {
        return section(at: indexPath.section)?.item(at: indexPath.row)
    }
    
    /**
     Remove the leaf node of the class TableDataSource.TableItem
     - parameter indexPath: The path to the item
     - returns: the removed object of class TableDataSource.TableItem or nil, if not found
     */
    @discardableResult
    open func removeItem(at indexPath: IndexPath) -> TableItem? {
        return section(at: indexPath.section)?.removeItem(at: indexPath.row)
    }
    
    /**
     Get the model of the leaf node of the class TableDataSource.TableItem
     - parameter indexPath: The path to the item
     - returns: the arbitrary object which was assigned to the model property of leaf nodes (defaults to String)
     */
    open func model(at indexPath: IndexPath) -> TableDataItemModel? {
        return section(at: indexPath.section)?.model(at: indexPath.row)
    }
    
    /**
     Get all items of all sections
     - returns: array with all row items of all sections
     */
    open var allItems: [TableItem] {
        var itms = [TableItem]()
        for section in self.sections {
            itms += section.allItems
        }
        return itms
    }
    
    /**
     Get model by elementId
     - returns: array with all models with a given elementId
     */
    open func models(by elementId: String) -> [TableDataItemModel] {
        return allItems.compactMap {
            ($0.model.elementId == elementId) ?
                $0.model: nil
        }
    }
    
    /**
     Get table item by elementId of the model
     - returns: array with all table items with a model with the given elementId
     */
    open func tableItems(by elementId: String) -> [TableItem] {
        return allItems.filter {
            $0.model.elementId == elementId
        }
    }
    
    /**
     Items in section
     - parameter section: index of section
     - returns: array with all row items of a given section
     */
    open func items(in sect: Int) -> [TableItem]? {
        return section(at: sect)?.allItems
    }
    
    /**
     Execute the selection action which was registered for a given row item
     
     This can be used in the UITableView delegate method didSelectRowAtIndexPath like so:
     
     func tableView(tableView:UITableView, didSelectRowAt indexPath:NSIndexPath) {
     <TableDataSourceInstance>.selectItemAt(indexPath)
     }
     
     - parameter indexPath: The path to the row item
     */
    open func selectItem(at indexPath: IndexPath) {
        section(at: indexPath.section)?.doSelectionAction(at: indexPath.row)
    }
    
    /**
     Execute the deselection action which was registered for a given row item
     
     This can be used in the UITableView delegate method didDeselectRowAtIndexPath like so:
     
     func tableView(tableView:UITableView, didDeselectRowAt indexPath:NSIndexPath) {
     <TableDataSourceInstance>.deselectItem(indexPath)
     }
     
     - parameter indexPath: The path to the row item
     */
    open func deselectItem(at indexPath: IndexPath) {
        section(at: indexPath.section)?.doDeselectionAction(at: indexPath.row)
    }
    
    // MARK: - TableSection Class
    
    open class TableSection {
        open var showSectionHeaders = false
        open var showSectionFooters = false
        open var sectionData: TableDataItemModel
        open var index = 0
        
        private var tableItems = [TableItem]()
        
        deinit {
            sectionData = TableSection.defaultModel
            tableItems = [TableItem]()
        }
        
        public init(with sectionData: TableDataItemModel = defaultModel, at index: Int?=nil) {
            self.sectionData = sectionData
            if let index = index {
                self.index = index
            }
            else {
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
            
            for i in (newIndex + 1)..<tableItems.count {
                tableItems[i].index = i
            }
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
            
            var item = item
            item.updateIndexPath(row: newIndex, sec: self.index)
            tableItems.insert(item, at: newIndex)
            
            for i in (newIndex + 1)..<tableItems.count {
                tableItems[i].index = i
            }
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
        
        func reIndexItems() {
            for i in 0..<tableItems.count {
                tableItems[i].section = index
                tableItems[i].index = i
            }
        }
        
        open var numberOfTableItems: Int {
            return tableItems.count
        }
        
        open func itemHeight(at index: Int) -> CGFloat {
            return item(at: index)?.cellheight ?? CGFloat(0)
        }
        
        open func item(at index: Int) -> TableItem? {
            return tableItems.item(at: index)
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
        
        open static var defaultModel: TableDataItemModel {
            return CellSourceModel(cellIdentifier: "HeaderCell")
        }
        
        func doSelectionAction(at index: Int) {
            tableItems.item(at: index)?.doSelectionAction()
        }
        
        func doDeselectionAction(at index: Int) {
            tableItems.item(at: index)?.doDeselectionAction()
        }
    }
    
    // MARK: - TableItem Class
    
    public struct TableItem {
        public var model: TableDataItemModel
        public var index: Int = 0
        public var section: Int = 0
        public var cellheight: CGFloat = 0.0
        
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
        
        mutating func updateIndexPath(row: Int, sec: Int) {
            index = row
            section = sec
        }
    }
}
