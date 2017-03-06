//
//  TDSVC.swift
//  TableDataSource
//
//  Created by Alex da Franca on 26/02/2017.
//  Copyright © 2017 Farbflash. All rights reserved.
//

open class TDSVC: UIViewController, FFSDataSourceStorageVC {
    
    @IBOutlet open weak var tableView: UITableView?
    @IBOutlet open weak var collectionView: UICollectionView?
    public var geometrieAlreadySetup = false
    
    public var tableDataSources = [String: TableDataSource]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        geometrieAlreadySetup = true
    }
}


// Minimal UITableViewDataSource conformance
extension TDSVC: UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource(for: tableView)?.numberOfSections() ?? 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource(for: tableView)?.numberOfItems(in: section) ?? 0
    }
    
    open func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource(for: tableView),
            let model = dataSource.model(at: indexPath) else {
                fatalError("TableDataSource: Datasource or model for table \(tableView) at indexPath \(indexPath) not found")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: indexPath)
        model.configureTableViewCell?(cell, model, indexPath)
        return cell
    }
}

// Minimal UITableViewDelegate conformance
extension TDSVC: UITableViewDelegate {
    
    open func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        dataSource(for: tableView)?.selectItem(at: indexPath)
    }
    
    open func tableView(_ tableView:UITableView, didDeselectRowAt indexPath:IndexPath) {
        dataSource(for: tableView)?.deselectItem(at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = Double(tableView.rowHeight)
        if let dataSource = dataSource(for: tableView),
            let model = dataSource.model(at: indexPath) {
            rowHeight = model.cellHeight ?? Double(tableView.sectionHeaderHeight)
        }
        return CGFloat(rowHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight = UITableViewAutomaticDimension
        
        if !geometrieAlreadySetup { return cellHeight }
        
        if let dataSrc = dataSource(for: tableView),
            let model = dataSrc.model(at: indexPath) {
            if let rowHeight = model.cellHeight {
                cellHeight = CGFloat(rowHeight)
            }
            if let model = model as? CollapsableTableDataItemModel {
                if model.cellExpandHeightDifference > 0 {
                    if !model.collapsed {
                        return cellHeight + CGFloat(model.cellExpandHeightDifference)
                    }
                }
            }
        }
        return cellHeight
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        var sectionHeaderHeight = 0.0
        if let dataSource = dataSource(for: tableView),
            let section = dataSource.section(at: section),
            section.showSectionHeaders == true {
            sectionHeaderHeight = section.sectionData?.cellHeight ?? Double(tableView.sectionHeaderHeight)
        }
        return CGFloat(sectionHeaderHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let dataSrc = dataSource(for: tableView),
            let sectionObj = dataSrc.section(at: section),
            sectionObj.showSectionHeaders {
            if let model = sectionObj.sectionData,
                let rheight = model.cellHeight {
                return CGFloat(rheight)
            }
            return tableView.sectionHeaderHeight
        }
        return CGFloat(0)
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let dataSrc = dataSource(for: tableView),
            let sectionObj = dataSrc.section(at: section),
            sectionObj.showSectionHeaders == true,
            let model = sectionObj.sectionData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier) {
                model.configureTableViewCell?(cell, model, IndexPath(row: 0, section: section))
                return cell.contentView
            }
        }
        return nil
    }
}

// Minimal UICollectionViewDataSource conformance
extension TDSVC: UICollectionViewDataSource {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource(for: collectionView)?.numberOfSections() ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource(for: collectionView)?.numberOfItems(in: section) ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource(for: collectionView),
            let model = dataSource.model(at: indexPath) else {
                fatalError("TableDataSource: Datasource or model for collectionView \(collectionView) at indexPath \(indexPath) not found")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.cellIdentifier, for: indexPath)
        model.configureCollectionViewCell?(cell, model, indexPath)
        return cell
    }
}

// Minimal UICollectionViewDelegate conformance
extension TDSVC: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource(for: collectionView)?.selectItem(at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath:IndexPath) {
        dataSource(for: collectionView)?.deselectItem(at: indexPath)
    }
}

