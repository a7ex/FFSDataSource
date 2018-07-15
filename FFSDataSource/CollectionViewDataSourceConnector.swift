//
//  CollectionViewDataSourceConnector.swift
//  TableViewDataSourceTest
//
//  Created by Alex da Franca on 08.07.18.
//  Copyright © 2018 Farbflash. All rights reserved.
//

import UIKit

public class CollectionViewDataSourceConnector: NSObject {
    private let dataSource: TableDataSource
    
    public init(with tableDataSource: TableDataSource, in collectionView: UICollectionView) {
        self.dataSource = tableDataSource
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension CollectionViewDataSourceConnector: UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
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

extension CollectionViewDataSourceConnector: UICollectionViewDelegate {
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.selectItem(at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        dataSource.deselectItem(at: indexPath)
    }
}

