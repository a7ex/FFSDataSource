//
//  TDSVCTests.swift
//  FFSDataSourceTests
//
//  Created by Alex Apprime on 14.10.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import XCTest
@testable import FFSDataSource

class TDSVCTests: XCTestCase {
    var vcToTest: TDSVC!
    
    override func setUp() {
        super.setUp()

        vcToTest = TDSVC()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewDidLoad() {
        let tv = UITableView()
        vcToTest.tableView = tv
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        vcToTest.collectionView = cv
        
        // access of the viewControllers view causes a viewDidLoad() event
        // so no need to call it explicitely
        vcToTest.view.addSubview(tv)
        vcToTest.view.addSubview(cv)
        
        XCTAssert(vcToTest.tableView?.delegate === vcToTest)
        XCTAssert(vcToTest.tableView?.dataSource === vcToTest)
        XCTAssert(vcToTest.collectionView?.delegate === vcToTest)
        XCTAssert(vcToTest.collectionView?.delegate === vcToTest)
        XCTAssert(vcToTest.geometrieAlreadySetup == false)
        XCTAssert(vcToTest.tableDataSources.count == 0)
    }

    func testViewWillLayoutSubviews() {
        vcToTest.view.layoutIfNeeded()
        XCTAssert(vcToTest.geometrieAlreadySetup == true)
    }

    func testNumberOfSections() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let output = Output()
        let tabView = vcToTest.tableView!
        XCTAssert(vcToTest.numberOfSections(in: tabView) == 0)
        vcToTest.setDataSource(dataSourceDummy(with: output), forView: tabView)
        XCTAssert(vcToTest.numberOfSections(in: tabView) == 1)
    }
    
    func testNumberOfSectionsOfCollectionView() {
        setupCollectionView()
        vcToTest.view.layoutIfNeeded()
        let output = Output()
        let collectionView = vcToTest.collectionView!
        XCTAssert(vcToTest.numberOfSections(in: collectionView) == 0)
        vcToTest.setDataSource(dataSourceDummy(with: output), forView: collectionView)
        XCTAssert(vcToTest.numberOfSections(in: collectionView) == 1)
    }

    func testNumberOfRows() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let output = Output()
        let tabView = vcToTest.tableView!
        XCTAssert(vcToTest.tableView(tabView, numberOfRowsInSection: 0) == 0)
        vcToTest.setDataSource(dataSourceDummy(with: output), forView: tabView)
        XCTAssert(vcToTest.tableView(tabView, numberOfRowsInSection: 0) == 12)
    }
    
    func testNumberOfItems() {
        setupCollectionView()
        vcToTest.view.layoutIfNeeded()
        let output = Output()
        let collectionView = vcToTest.collectionView!
        XCTAssert(vcToTest.collectionView(collectionView, numberOfItemsInSection: 0) == 0)
        vcToTest.setDataSource(dataSourceDummy(with: output), forView: collectionView)
        XCTAssert(vcToTest.collectionView(collectionView, numberOfItemsInSection: 0) == 12)
    }

    func testCellForRow() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let output = Output()
        let tabView = vcToTest.tableView!
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "StandardCell")
        vcToTest.setDataSource(dataSourceDummy(with: output), forView: tabView)
        XCTAssert(vcToTest.tableView(tabView, cellForRowAt: IndexPath(row: 0, section: 0)) != nil)
    }
    
    func dis_testCellForItem() {
        setupCollectionView()
        vcToTest.view.layoutIfNeeded()
        let collectionView = vcToTest.collectionView!
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "StandardCell")
        let dataSource = TableDataSource()
        dataSource.addSection()
            .addTableItem(with: CellSourceModel(
                cellIdentifier: "StandardCell",
                onSelect: { (indexPath) in
            }))
        
        vcToTest.setDataSource(dataSource, forView: collectionView)
        XCTAssert(vcToTest.collectionView(collectionView, cellForItemAt: IndexPath(row: 0, section: 0)) != nil)
    }

    func testDidSelectRow() {
        let testExpectation = expectation(description: "testDidSelectRowExpectation")
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let tabView = vcToTest.tableView!

        let dataSource = TableDataSource()
        dataSource.addSection()
            .addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            onSelect: { (indexPath) in
                testExpectation.fulfill()
        }))

        vcToTest.setDataSource(dataSource, forView: tabView)
        vcToTest.tableView(tabView, didSelectRowAt: IndexPath(row: 0, section: 0))

        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(String(describing: error?.localizedDescription))
            }
        }
    }
    
    func testDidSelectItem() {
        let testExpectation = expectation(description: "testDidSelectItemExpectation")
        setupCollectionView()
        vcToTest.view.layoutIfNeeded()
        let collectionView = vcToTest.collectionView!
        
        let dataSource = TableDataSource()
        dataSource.addSection()
            .addTableItem(with: CellSourceModel(
                cellIdentifier: "StandardCell",
                onSelect: { (indexPath) in
                    testExpectation.fulfill()
            }))
        
        vcToTest.setDataSource(dataSource, forView: collectionView)
        vcToTest.collectionView(collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        
        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(String(describing: error?.localizedDescription))
            }
        }
    }

    func testDidDeSelectRow() {
        let testExpectation = expectation(description: "testDidDeSelectRowExpectation")
        
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let tabView = vcToTest.tableView!

        let dataSource = TableDataSource()
        dataSource.addSection()
            .addTableItem(with: CellSourceModel(
                cellIdentifier: "StandardCell",
                onDeselect: { (indexPath) in
                    testExpectation.fulfill()
            }))

        vcToTest.setDataSource(dataSource, forView: tabView)
        vcToTest.tableView(tabView, didDeselectRowAt: IndexPath(row: 0, section: 0))

        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(String(describing: error?.localizedDescription))
            }
        }
    }
    
    func testDidDeSelectItem() {
        let testExpectation = expectation(description: "testDidDeSelectItemExpectation")
        
        setupCollectionView()
        vcToTest.view.layoutIfNeeded()
        let collectionView = vcToTest.collectionView!
        
        let dataSource = TableDataSource()
        dataSource.addSection()
            .addTableItem(with: CellSourceModel(
                cellIdentifier: "StandardCell",
                onDeselect: { (indexPath) in
                    testExpectation.fulfill()
            }))
        
        vcToTest.setDataSource(dataSource, forView: collectionView)
        vcToTest.collectionView(collectionView, didDeselectItemAt: IndexPath(row: 0, section: 0))
        
        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(String(describing: error?.localizedDescription))
            }
        }
    }

    func testEstimatedRowHeight() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let tabView = vcToTest.tableView!
        tabView.rowHeight = 44

        let dataSource = TableDataSource()
        let section = dataSource.addSection()

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell"))

        // without dataSource it is tableView.rowHeight
        XCTAssert(vcToTest.tableView(tabView, estimatedHeightForRowAt: IndexPath(row: 1, section: 0)) == 44)

        vcToTest.setDataSource(dataSource, forView: tabView)

        XCTAssert(vcToTest.tableView(tabView, estimatedHeightForRowAt: IndexPath(row: 0, section: 0)) == 60)
        XCTAssert(vcToTest.tableView(tabView, estimatedHeightForRowAt: IndexPath(row: 1, section: 0)) == 44)
    }

    func testRowHeight() {
        setUpTableView()
        vcToTest.loadViewIfNeeded()

        // before viewWillLayoutSubviews geometrieAlreadySetup == false, return UITableViewAutomaticDimension
        XCTAssert(vcToTest.tableView(vcToTest.tableView!, heightForRowAt: IndexPath(row: 0, section: 0)) == UITableViewAutomaticDimension)

        vcToTest.viewWillLayoutSubviews()
        let tabView = vcToTest.tableView!
        tabView.rowHeight = 44

        let dataSource = TableDataSource()
        let section = dataSource.addSection()

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell"))

        let mo = CellSourceModel(cellIdentifier: "StandardCell",
                                 cellHeight: 60)
        mo.cellExpandHeightDifference = 100
        mo.collapsed = true
        section.addTableItem(with: mo)

        // without dataSource it is tableView.rowHeight
        XCTAssert(vcToTest.tableView(tabView, heightForRowAt: IndexPath(row: 0, section: 0)) == UITableViewAutomaticDimension)

        vcToTest.setDataSource(dataSource, forView: tabView)

        XCTAssert(vcToTest.tableView(tabView, heightForRowAt: IndexPath(row: 0, section: 0)) == 60)
        XCTAssert(vcToTest.tableView(tabView, heightForRowAt: IndexPath(row: 1, section: 0)) == UITableViewAutomaticDimension)

        XCTAssert(vcToTest.tableView(tabView, heightForRowAt: IndexPath(row: 2, section: 0)) == 60)
        mo.collapsed = false
        XCTAssert(vcToTest.tableView(tabView, heightForRowAt: IndexPath(row: 2, section: 0)) == 160)
    }

    func testEstimatedHeaderHeight() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let tabView = vcToTest.tableView!
        tabView.rowHeight = 44
        tabView.sectionHeaderHeight = 80

        let dataSource = TableDataSource()
        var section = dataSource.addSection()

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))

        section.showSectionHeaders = true

        section = dataSource.addSection(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))
section.showSectionHeaders = true

        section = dataSource.addSection(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))
        section.showSectionHeaders = false

        // without dataSource it is tableView.rowHeight
        XCTAssert(vcToTest.tableView(tabView, estimatedHeightForHeaderInSection: 0) == 0)

        vcToTest.setDataSource(dataSource, forView: tabView)

        XCTAssert(vcToTest.tableView(tabView, estimatedHeightForHeaderInSection: 0) == 80)
        XCTAssert(vcToTest.tableView(tabView, estimatedHeightForHeaderInSection: 1) == 60)
        XCTAssert(vcToTest.tableView(tabView, estimatedHeightForHeaderInSection: 2) == 0)
    }

    func testHeaderHeight() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let tabView = vcToTest.tableView!
        tabView.rowHeight = 44
        tabView.sectionHeaderHeight = 80

        let dataSource = TableDataSource()
        var section = dataSource.addSection()

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))

        section.showSectionHeaders = true

        section = dataSource.addSection(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))
        section.showSectionHeaders = true

        section = dataSource.addSection(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))
        section.showSectionHeaders = false

        // without dataSource it is tableView.rowHeight
        XCTAssert(vcToTest.tableView(tabView, heightForHeaderInSection: 0) == 0)

        vcToTest.setDataSource(dataSource, forView: tabView)

        XCTAssert(vcToTest.tableView(tabView, heightForHeaderInSection: 0) == 80)
        XCTAssert(vcToTest.tableView(tabView, heightForHeaderInSection: 1) == 60)
        XCTAssert(vcToTest.tableView(tabView, heightForHeaderInSection: 2) == 0)
    }

    func testViewForHeader() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let tabView = vcToTest.tableView!
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "StandardCell")
        let dataSource = TableDataSource()
        let section = dataSource.addSection(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))

        section.showSectionHeaders = true

        // without dataSource it is tableView.rowHeight
        XCTAssert(vcToTest.tableView(tabView, viewForHeaderInSection: 0) == nil)

        vcToTest.setDataSource(dataSource, forView: tabView)

        XCTAssert(vcToTest.tableView(tabView, viewForHeaderInSection: 0) != nil)
    }

    func testClearSelection() {
        setUpTableView()
        vcToTest.view.layoutIfNeeded()
        let tabView = vcToTest.tableView!
        tabView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        guard let indPaths = tabView.indexPathsForSelectedRows else {
            XCTFail()
            return
        }
        XCTAssert(indPaths.count > 0)
        vcToTest.clearSelections(of: tabView)
        guard let indPathsAfterDeselect = tabView.indexPathsForSelectedRows else {
            return
        }
        XCTAssert(indPathsAfterDeselect.count == 0)
    }

    func dataSourceDummy(with testOutput: TestOutput) -> TableDataSource {
        return TestFactory.dataSourceDummy(with:testOutput)
    }

    private func setUpTableView() {
        let tv = UITableView()
        vcToTest.tableView = tv
        vcToTest.view.addSubview(tv)
    }
    private func setupCollectionView() {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        vcToTest.collectionView = cv
        vcToTest.view.addSubview(cv)
    }
}

struct TestFactory {
    static func dataSourceDummy(with testOutput: TestOutput) -> TableDataSource {
        let dataSource = TableDataSource()
        let section = dataSource.addSection()
        
        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            configureTableViewCell: { (cell, model, indexPath) in
                cell.textLabel?.text = "Cell content"
        },
            onSelect: { (indexPath) in
                testOutput.print("Tap on cell \(indexPath.row) of section \(indexPath.section).")
        }))
        
        for number in 0...10 {
            section.addTableItem(with: CellSourceModel(
                cellIdentifier: "NumberCell",
                configureTableViewCell: { (cell, model, indexPath) in
                    cell.textLabel?.text = String(number)
            }, onSelect: { (indexPath) in
                testOutput.print("Tap on number \(number) in cell \(indexPath.row) of section \(indexPath.section).")
            }, onDeselect: { (indexPath) in
                testOutput.print("Deselect cell \(indexPath.row) of section \(indexPath.section).")
            }))
        }
        return dataSource
    }
}
