//
//  TDSVC.swift
//  TableDataSource
//
//  Created by Alex da Franca on 26/02/2017.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import UIKit

public protocol FFSDataSourceController: class, FFSDataSourceStorageVC {
    var tableView: UITableView? { get }
    var collectionView: UICollectionView? { get }
    var geometrieAlreadySetup: Bool { get }
}

open class TDSVC: UIViewController, FFSDataSourceController {
    // swiftlint:disable:next private_outlet
    @IBOutlet open weak var tableView: UITableView?
    // swiftlint:disable:next private_outlet
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

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // for some odd reason I need to make sure being in the main thread here
        // without this, there can be a noticeable delay until the event fires
        DispatchQueue.main.async(execute: { [unowned self] () -> Void in
            self.dataSource(for: tableView)?.selectItem(at: indexPath)
        })
    }

    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // ...and just to be sure: same here as in 'didSelectRowAt'
        DispatchQueue.main.async(execute: { [unowned self] () -> Void in
            self.dataSource(for: tableView)?.deselectItem(at: indexPath)
        })
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
            sectionHeaderHeight = section.sectionData.cellHeight ?? Double(tableView.sectionHeaderHeight)
        }
        return CGFloat(sectionHeaderHeight)
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let dataSrc = dataSource(for: tableView),
            let sectionObj = dataSrc.section(at: section),
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
        if let dataSrc = dataSource(for: tableView),
            let sectionObj = dataSrc.section(at: section),
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

    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        dataSource(for: collectionView)?.deselectItem(at: indexPath)
    }
}

// UITableView helpers
public extension FFSDataSourceController {

    public func clearTableViewSelections() {
        guard let tableView = tableView else { return }
        clearTableViewSelections(of: tableView)
    }

    public func clearTableViewSelections(of targetTableView: UITableView) {
        if let selections = targetTableView.indexPathsForSelectedRows {
            for thisIndexPath in selections {
                targetTableView.deselectRow(at: thisIndexPath, animated: true)
            }
        }
    }

    public func clearCollectionViewSelections() {
        guard let collectionView = collectionView else { return }
        clearCollectionViewSelections(of: collectionView)
    }

    public func clearCollectionViewSelections(of targetCollectionView: UICollectionView) {
        if let selections = targetCollectionView.indexPathsForSelectedItems {
            for thisIndexPath in selections {
                targetCollectionView.deselectItem(at: thisIndexPath, animated: true)
            }
        }
    }

    public func modelForViewInCell(_ viewInCell: UIView) -> TableDataItemModel? {
        if let tableCell = enclosingTableViewCell(viewInCell) {
            return modelForViewInTableViewCell(tableCell)
        }
        else if let _ = enclosingTableViewCell(viewInCell) {
            return modelForViewInCollectionViewCell(viewInCell)
        }
        return nil
    }

    public func modelForViewInTableViewCell(_ tableCell: UITableViewCell) -> TableDataItemModel? {
        if let dataSrc = dataSource(for: tableView),
            let indexPath = tableCell.indexPath,
            let model = dataSrc.model(at: indexPath) {
            return model
        }
        return nil
    }

    public func modelForViewInCollectionViewCell(_ viewInCell: UIView) -> TableDataItemModel? {
        if let cell = enclosingCollectionViewCell(viewInCell),
            let dataSrc = dataSource(for: collectionView),
            let indexPath = cell.indexPath,
            let model = dataSrc.model(at: indexPath) {
            return model
        }
        return nil
    }

    public func tableItemForViewInCell(_ viewInCell: UIView) -> TableDataSource.TableItem? {
        if let tableCell = enclosingTableViewCell(viewInCell),
            let dataSrc = dataSource(for: tableView),
            let indexPath = tableCell.indexPath {
            return dataSrc.item(at: indexPath)
        }
        return nil
    }

    public func indexPathOfCellWithView(_ viewInCell: UIView) -> IndexPath? {
        if let tableCell = enclosingTableViewCell(viewInCell) {
            return tableCell.indexPath
        }
        return nil
    }
}
