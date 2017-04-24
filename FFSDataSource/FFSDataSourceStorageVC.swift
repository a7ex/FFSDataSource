//
//  FFSDataSourceStorageVC.swift
//  FFSDataSource
//
//  Created by Alex da Franca on 05/03/2017.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import UIKit

fileprivate extension UIView {
    func nearestSuperview<T: UIView>(ofType type: T.Type) -> T? {
        return self as? T ?? superview?.nearestSuperview(ofType: type)
    }
}

public extension UITableViewCell {
    var indexPath: IndexPath? {
        return nearestSuperview(ofType: UITableView.self)?.indexPath(for: self)
    }
}

public extension UICollectionViewCell {
    var indexPath: IndexPath? {
        return nearestSuperview(ofType: UICollectionView.self)?.indexPath(for: self)
    }
}

public protocol FFSDataSourceStorageVC: class {
    var tableDataSources: [String: TableDataSource] { get set }
}

public extension FFSDataSourceStorageVC {
    
    /// Store the dataSource for a view
    ///
    /// - Parameters:
    ///   - datasource: An instance of TableDataSource
    ///   - targetView: typically an instance of either UITableView or UICollectionView
    func setDataSource(_ datasource: TableDataSource, forView targetView: UIView) {
        tableDataSources["\(targetView.hashValue)"] = datasource
    }
    
    /// Retrieve the dataSource associated to a view
    ///
    /// - Parameter targetView: typically an instance of either UITableView or UICollectionView
    /// - Returns: An instance of TableDataSource or nil
    func dataSource(for targetView: UIView?) -> TableDataSource? {
        guard let targetView = targetView else { return nil }
        return tableDataSources["\(targetView.hashValue)"]
    }
    
    /// From any view inside a UITableViewCell get the UITableViewCell object
    ///
    /// - Parameter viewInCell: any UIView subclass inside a UITableViewCell (or its subclass)
    /// - Returns: Instance of UITableViewCell or nil, if nothing suitable was found
    func enclosingTableViewCell(_ viewInCell: UIView) -> UITableViewCell? {
        return viewInCell.nearestSuperview(ofType: UITableViewCell.self)
    }
    
    /// From any view inside a UICollectionViewCell get the UICollectionViewCell object
    ///
    /// - Parameter viewInCell: any element inside a UICollectionViewCell (or its subclass)
    /// - Returns: Instance of UICollectionViewCell or nil, if nothing suitable was found
    func enclosingCollectionViewCell(_ viewInCell: UIView) -> UICollectionViewCell? {
        return viewInCell.nearestSuperview(ofType: UICollectionViewCell.self)
    }
    
    /// Get the model associated to a cell
    /// This is the model at the indexPath of the TableDataSource associated to
    /// the tableView or collectionView of the enclosed view
    ///
    /// - Parameter viewInCell: any UIView subclass inside a UITableViewCell (or its subclass)
    /// - Returns: the model corresponding to protocol 'TableDataItemModel'
    func modelForViewInCell(_ viewInCell: UIView) -> TableDataItemModel? {
        if let tableCell = enclosingTableViewCell(viewInCell),
            let dataSrc = dataSource(for: viewInCell.nearestSuperview(ofType: UITableView.self)),
            let indexPath = tableCell.indexPath,
            let model = dataSrc.model(at: indexPath) {
            return model
        }
        else if let tableCell = enclosingCollectionViewCell(viewInCell),
            let dataSrc = dataSource(for: viewInCell.nearestSuperview(ofType: UICollectionView.self)),
            let indexPath = tableCell.indexPath,
            let model = dataSrc.model(at: indexPath) {
            return model
        }
        return nil
    }
}
