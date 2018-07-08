//
//  TableDataSourceConnector.swift
//  FFSDataSource
//
//  Created by Alex da Franca on 03.04.18.
//  Copyright © 2018 Farbflash. All rights reserved.
//

import UIKit

public extension UITableView {
    public func connect(to connector: TableDataSourceConnector) {
        delegate = connector
        dataSource = connector
    }
}

public class TableDataSourceConnector: NSObject {
    private let dataSource: TableDataSource
    
    public init(with tableDataSource: TableDataSource) {
        self.dataSource = tableDataSource
    }
}

extension TableDataSourceConnector: UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource.model(at: indexPath) else {
            fatalError("TableDataSource: Datasource or model for table \(tableView) at indexPath \(indexPath) not found")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: indexPath)
        model.configureTableViewCell?(cell, model, indexPath)
        return cell
    }
}

extension TableDataSourceConnector: UITableViewDelegate {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // for some odd reason I need to make sure being in the main thread here
        // without this, there can be a noticeable delay until the event fires
        DispatchQueue.main.async(execute: { [unowned self] () -> Void in
            self.dataSource.selectItem(at: indexPath)
        })
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // ...and just to be sure: same here as in 'didSelectRowAt'
        DispatchQueue.main.async(execute: { [unowned self] () -> Void in
            self.dataSource.deselectItem(at: indexPath)
        })
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = Double(tableView.rowHeight)
        if let model = dataSource.model(at: indexPath) {
            rowHeight = model.cellHeight ?? Double(tableView.rowHeight)
        }
        return CGFloat(rowHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight = UITableViewAutomaticDimension
        
        if let model = dataSource.model(at: indexPath) {
            if let rowHeight = model.cellHeight {
                cellHeight = CGFloat(rowHeight)
            }
            if let model = model as? CollapsableTableDataItemModel,
                model.cellExpandHeightDifference > 0,
                !model.collapsed {
                return cellHeight + CGFloat(model.cellExpandHeightDifference)
            }
        }
        return cellHeight
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        var sectionHeaderHeight = 0.0
        if let section = dataSource.section(at: section),
            section.showSectionHeaders == true {
            sectionHeaderHeight = section.sectionData.cellHeight ?? Double(tableView.sectionHeaderHeight)
        }
        return CGFloat(sectionHeaderHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let sectionObj = dataSource.section(at: section),
            sectionObj.showSectionHeaders {
            let model = sectionObj.sectionData
            if let rheight = model.cellHeight {
                return CGFloat(rheight)
            }
            return tableView.sectionHeaderHeight
        }
        return CGFloat(0)
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionObj = dataSource.section(at: section),
            sectionObj.showSectionHeaders == true {
            let model = sectionObj.sectionData
            if let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier) {
                model.configureTableViewCell?(cell, model, IndexPath(row: 0, section: section))
                return cell.contentView
            }
        }
        return nil
    }
}
