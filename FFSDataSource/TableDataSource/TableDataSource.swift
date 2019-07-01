//
//  TableDataSource.swift
//  FFSDataSource
//
//  Created by Alex da Franca
//  Copyright (c) 2015 Farbflash. All rights reserved.
//

import UIKit

extension Array {
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

/// An error type for errors, which are thrown when validating all items
/// and which store an array of failed items in an associated value
///
/// - failed: array with TableItem objects, which failed the validation
public enum ValidationError: Error {
    case unknown
    case failed(items: [TableDataSource.TableItem])
}

/// An element which implements updateVisibility()
/// Typically this is a subclass of this class which provides Form support
public protocol CanUpdateItemVisibility {

    /// Compute which indexPaths to add/remove from the tableView
    /// Typically by examining the item visibility
    ///
    /// - Returns: One array with indexPaths to add to the table and one array with indexPaths to remove from the tableView
    func updateVisibility() -> (add: [IndexPath], remove: [IndexPath])
}

/// This Protocol is just used as a Metatype for UITableViewCell and UICollectionViewCell
public protocol TableOrCollectionViewCell { }
extension UITableViewCell: TableOrCollectionViewCell { }
extension UICollectionViewCell: TableOrCollectionViewCell { }

public typealias CellAction = (IndexPath, TableDataItemModel) -> Void
public typealias CellConfiguration = (TableOrCollectionViewCell, TableDataItemModel, IndexPath) -> Void

/**
 TableDataSource is a class to provide an object for UITableView datasources and delegates
 It can be used as model for UITableViews and UICollectionViews, providing cell actions as closures
 
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
    open func addSection(with headerData: TableDataItemModel?=nil, footerData: TableDataItemModel?=nil, atIndex index: Int?=nil) -> TableSection {
        let cnt = sections.count
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
        
        let newSection = TableSection(with: headerData, footerData: footerData, at: newIndex)
        sections.insert(newSection, at: newIndex)
        
        newSection.showSectionHeaders = showSectionHeaders
        
        reindexSections()
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
        
        reindexSections()
    }
    
    /**
     Remove an existing section from the datasource model
     - parameter itemTitle: title of section to remove
     */
    open func remove(_ section: TableSection) {
        sections.remove(at: section.index)
        
        reindexSections()
    }
    
    /**
     Remove an existing section from the datasource model by title
     - parameter itemTitle: title of section to remove
     */
    open func removeSection(with elementId: String) -> TableSection? {
        for i in stride(from: (sections.count - 1), through: 0, by: -1) {
            let thisItem = sections[i]
            if thisItem.headerData?.elementId == elementId {
                sections.remove(at: i)
                reindexSections()
                return thisItem
            }
            if thisItem.footerData?.elementId == elementId {
                sections.remove(at: i)
                reindexSections()
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
        let visibleSections = sections.filter { $0.visible }
        return visibleSections.item(at: index)
    }
    
    /**
     Get a section by title
     - parameter sectionTitle: A NSString to be used as the title of the section.
     - returns: section object of class TableDataSource.TableSection with title 'title' or nil
     */
    open func section(with elementId: String) -> TableSection? {
        if let matchingHeader = sections.first(where: { $0.headerData?.elementId == elementId }) {
            return matchingHeader
        }
        return sections.first(where: { $0.footerData?.elementId == elementId })
    }
    
    /**
     reindex items
     */
    open func reIndexItems() {
        let visibleSections = sections.filter { $0.visible }
        for i in 0..<visibleSections.count {
            visibleSections[i].index = i
            visibleSections[i].reIndexItems()
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
        return sections.filter({ $0.visible }).count
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
        let visibleSections = sections.filter { $0.visible }
        return visibleSections.item(at: section)?.numberOfTableItems ?? 0
    }
    
    /** @name Get properties of sections and items */
    
    /**
     Get the title of the section at the given index or nil, if showSection = false
     The difference is, that it can be directly used in tableView delegate's titleForHeaderInSection
     - parameter index: index of section
     - returns: the title of the section as string OR nil
     */
    open func sectionData(for section: Int) -> TableDataItemModel? {
        let visibleSections = sections.filter { $0.visible }
        guard visibleSections.count > section,
            visibleSections[section].showSectionHeaders else {
                return nil
        }
        return visibleSections[section].headerData
    }
    
    /**
     Get the height for a given row item
     
     If the leaf model responds to selector 'height' that value will be used (defaults to 44.0)
     The selector 'height' must return a CGFloat
     
     - parameter indexPath: The path to the row item
     - returns: The height of the row item
     */
    open func itemHeight(at indexPath: IndexPath) -> CGFloat {
        let visibleSections = sections.filter { $0.visible }
        guard visibleSections.count > indexPath.section else { return CGFloat(0.0) }
        return visibleSections[indexPath.section].itemHeight(at: indexPath.row)
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
        return sections.flatMap { $0.allItems }
    }
    
    /**
     Get all items of all sections
     - returns: array with all row items of all sections
     */
    open var allVisibleItems: [TableItem] {
        let visibleSections = sections.filter { $0.visible }
        return visibleSections.flatMap { $0.allItems }
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
    
    /// Execute evaluation closure on all items
    /// Throws an error with an error of failed items
    ///
    /// - Throws: ValidationError.failed([TableDataItemModel])
    open func validateAll() throws {
        let failed = allVisibleItems.filter { (item) -> Bool in
            guard item.visible == true,
                let model = item.model as? ValidatableTableDataItemModel,
                model.evaluate() != nil else {
                return false
            }
            return true
        }
        if !failed.isEmpty {
            throw ValidationError.failed(items: failed)
        }
    }
    
    /// Execute evaluation closure on all items, until the first fails
    /// Throws an error with an error with the first failed item
    ///
    /// - Throws: ValidationError.failed([TableDataItemModel])
    open func validate() throws {
        for item in allVisibleItems {
            guard item.visible == true,
                let model = item.model as? ValidatableTableDataItemModel,
                model.evaluate() != nil else {
                    continue
            }
            throw ValidationError.failed(items: [item])
        }
    }
    
    
    private final func reindexSections() {
        let visibleSections = sections.filter { $0.visible }
        for i in 0..<visibleSections.count {
            sections[i].index = i
        }
    }
}
