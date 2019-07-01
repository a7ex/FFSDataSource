//
//  DataSourceConnector.swift
//  FFSDataSource
//
//  Created by Alex da Franca
//  Copyright (c) 2018 Farbflash. All rights reserved.
//

import UIKit

open class DataSourceConnector: NSObject {
    public let dataSource: TableDataSource
    
    public init(with tableDataSource: TableDataSource, in tableView: UITableView?) {
        self.dataSource = tableDataSource
        super.init()
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    public init(with tableDataSource: TableDataSource, in collectionView: UICollectionView?) {
        self.dataSource = tableDataSource
        super.init()
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
}

public extension DataSourceConnector {
    func validateAll() throws {
        try dataSource.validateAll()
    }
}

extension DataSourceConnector: UITableViewDataSource {
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
        model.configureCell?(cell, model, indexPath)
        return cell
    }
}

extension DataSourceConnector: UITableViewDelegate {
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
        guard let model = dataSource.model(at: indexPath),
            let rowHeight = model.cellHeight else {
                return tableView.rowHeight
        }
        return CGFloat(rowHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = dataSource.model(at: indexPath) else {
            return UITableView.automaticDimension
        }
        let cellHeight: CGFloat
        if let rowHeight = model.cellHeight {
            cellHeight = CGFloat(rowHeight)
        } else {
            cellHeight = UITableView.automaticDimension
        }
        if let model = model as? CollapsableTableDataItemModel,
            model.cellExpandHeightDifference > 0,
            !model.collapsed {
            return cellHeight + CGFloat(model.cellExpandHeightDifference)
        }
        return cellHeight
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight(for: dataSource.section(at: section), fallbackHeight: tableView.sectionHeaderHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight(for: dataSource.section(at: section), fallbackHeight: tableView.sectionHeaderHeight)
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionObj = dataSource.section(at: section),
            sectionObj.showSectionHeaders == true,
            let model = sectionObj.headerData,
            let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier) else {
                return nil
        }
        model.configureCell?(cell, model, IndexPath(row: 0, section: section))
        return cell.contentView
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return footerHeight(for: dataSource.section(at: section), fallbackHeight: tableView.sectionFooterHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight(for: dataSource.section(at: section), fallbackHeight: tableView.sectionFooterHeight)
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let sectionObj = dataSource.section(at: section),
            sectionObj.showSectionHeaders == true,
            let model = sectionObj.footerData,
            let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier) else {
                return nil
        }
        model.configureCell?(cell, model, IndexPath(row: 0, section: section))
        return cell.contentView
    }
    
    //MARK: - Private interface
    
    private func headerHeight(for section: TableDataSource.TableSection?, fallbackHeight: CGFloat) -> CGFloat {
        guard let section = section,
            section.showSectionHeaders else {
                return CGFloat(0)
        }
        guard let headerHeight = section.headerData?.cellHeight else {
            return fallbackHeight
        }
        return CGFloat(headerHeight)
    }
    
    private func footerHeight(for section: TableDataSource.TableSection?, fallbackHeight: CGFloat) -> CGFloat {
        guard let section = section,
            section.showSectionFooters else {
                return CGFloat(0)
        }
        guard let footerHeight = section.footerData?.cellHeight else {
            return fallbackHeight
        }
        return CGFloat(footerHeight)
    }
}

extension DataSourceConnector: UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("In Baseclass received numberOfSections")
        return dataSource.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = dataSource.model(at: indexPath) else {
            fatalError("TableDataSource: Datasource or model for collectionView \(collectionView) at indexPath \(indexPath) not found")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.cellIdentifier, for: indexPath)
        model.configureCell?(cell, model, indexPath)
        return cell
    }
}

extension DataSourceConnector: UICollectionViewDelegate {
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.selectItem(at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        dataSource.deselectItem(at: indexPath)
    }
}
