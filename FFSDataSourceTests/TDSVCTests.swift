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
    var vcToTest: TDSVC?
    
    override func setUp() {
        super.setUp()

        vcToTest = TDSVC()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewDidLoad() {
        setUpTableView()
        setupCollectionView()
        vcToTest?.viewDidLoad()
        XCTAssert(vcToTest?.tableView?.delegate === vcToTest)
        XCTAssert(vcToTest?.tableView?.dataSource === vcToTest)
        XCTAssert(vcToTest?.collectionView?.delegate === vcToTest)
        XCTAssert(vcToTest?.collectionView?.delegate === vcToTest)
        XCTAssert(vcToTest?.geometrieAlreadySetup == false)
        XCTAssert(vcToTest?.tableDataSources.count == 0)
    }

    func testViewWillLayoutSubviews() {
        vcToTest?.viewDidLoad()
        vcToTest?.viewWillLayoutSubviews()
        XCTAssert(vcToTest?.geometrieAlreadySetup == true)
    }

    func testNumberOfSections() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let output = Output()
        let tabView = vc.tableView!
        XCTAssert(vcToTest?.numberOfSections(in: tabView) == 0)
        vc.setDataSource(dataSourceDummy(with: output), forView: tabView)
        XCTAssert(vcToTest?.numberOfSections(in: tabView) == 1)
    }

    func testNumberOfRows() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let output = Output()
        let tabView = vc.tableView!
        XCTAssert(vcToTest?.tableView(tabView, numberOfRowsInSection: 0) == 0)
        vc.setDataSource(dataSourceDummy(with: output), forView: tabView)
        XCTAssert(vcToTest?.tableView(tabView, numberOfRowsInSection: 0) == 12)
    }

    func testCellForRow() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let output = Output()
        let tabView = vc.tableView!
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "StandardCell")
        vc.setDataSource(dataSourceDummy(with: output), forView: tabView)
        XCTAssert(vcToTest?.tableView(tabView, cellForRowAt: IndexPath(row: 0, section: 0)) != nil)
    }

    func testDidSelectRow() {
        let testExpectation = expectation(description: "testDidSelectRowExpectation")
        guard let vc = vcToTest else {
            testExpectation.fulfill()
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!

        let dataSource = TableDataSource()
        dataSource.addSection()
            .addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            onSelect: { (indexPath) in
                testExpectation.fulfill()
        }))

        vc.setDataSource(dataSource, forView: tabView)
        vc.tableView(tabView, didSelectRowAt: IndexPath(row: 0, section: 0))

        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(String(describing: error?.localizedDescription))
            }
        }
    }

    func testDidDeSelectRow() {
        let testExpectation = expectation(description: "testDidDeSelectRowExpectation")
        guard let vc = vcToTest else {
            testExpectation.fulfill()
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!

        let dataSource = TableDataSource()
        dataSource.addSection()
            .addTableItem(with: CellSourceModel(
                cellIdentifier: "StandardCell",
                onDeselect: { (indexPath) in
                    testExpectation.fulfill()
            }))

        vc.setDataSource(dataSource, forView: tabView)
        vc.tableView(tabView, didDeselectRowAt: IndexPath(row: 0, section: 0))

        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(String(describing: error?.localizedDescription))
            }
        }
    }

    func testEstimatedRowHeight() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!
        tabView.rowHeight = 44

        let dataSource = TableDataSource()
        let section = dataSource.addSection()

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell"))

        // without dataSource it is tableView.rowHeight
        XCTAssert(vcToTest?.tableView(tabView, estimatedHeightForRowAt: IndexPath(row: 1, section: 0)) == 44)

        vcToTest?.setDataSource(dataSource, forView: tabView)

        XCTAssert(vcToTest?.tableView(tabView, estimatedHeightForRowAt: IndexPath(row: 0, section: 0)) == 60)
        XCTAssert(vcToTest?.tableView(tabView, estimatedHeightForRowAt: IndexPath(row: 1, section: 0)) == 44)
    }

    func testRowHeight() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()

        // before viewWillLayoutSubviews geometrieAlreadySetup == false, return UITableViewAutomaticDimension
        XCTAssert(vc.tableView(vc.tableView!, heightForRowAt: IndexPath(row: 0, section: 0)) == UITableViewAutomaticDimension)

        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!
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
        XCTAssert(vc.tableView(tabView, heightForRowAt: IndexPath(row: 0, section: 0)) == UITableViewAutomaticDimension)

        vc.setDataSource(dataSource, forView: tabView)

        XCTAssert(vc.tableView(tabView, heightForRowAt: IndexPath(row: 0, section: 0)) == 60)
        XCTAssert(vc.tableView(tabView, heightForRowAt: IndexPath(row: 1, section: 0)) == UITableViewAutomaticDimension)

        XCTAssert(vc.tableView(tabView, heightForRowAt: IndexPath(row: 2, section: 0)) == 60)
        mo.collapsed = false
        XCTAssert(vc.tableView(tabView, heightForRowAt: IndexPath(row: 2, section: 0)) == 160)
    }

    func testEstimatedHeaderHeight() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!
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
        XCTAssert(vc.tableView(tabView, estimatedHeightForHeaderInSection: 0) == 0)

        vc.setDataSource(dataSource, forView: tabView)

        XCTAssert(vc.tableView(tabView, estimatedHeightForHeaderInSection: 0) == 80)
        XCTAssert(vc.tableView(tabView, estimatedHeightForHeaderInSection: 1) == 60)
        XCTAssert(vc.tableView(tabView, estimatedHeightForHeaderInSection: 2) == 0)
    }

    func testHeaderHeight() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!
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
        XCTAssert(vc.tableView(tabView, heightForHeaderInSection: 0) == 0)

        vc.setDataSource(dataSource, forView: tabView)

        XCTAssert(vc.tableView(tabView, heightForHeaderInSection: 0) == 80)
        XCTAssert(vc.tableView(tabView, heightForHeaderInSection: 1) == 60)
        XCTAssert(vc.tableView(tabView, heightForHeaderInSection: 2) == 0)
    }

    func testViewForHeader() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "StandardCell")
        let dataSource = TableDataSource()
        let section = dataSource.addSection(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            cellHeight: 60))

        section.showSectionHeaders = true

        // without dataSource it is tableView.rowHeight
        XCTAssert(vc.tableView(tabView, viewForHeaderInSection: 0) == nil)

        vc.setDataSource(dataSource, forView: tabView)

        XCTAssert(vc.tableView(tabView, viewForHeaderInSection: 0) != nil)
    }

    func testClearSelection() {
        guard let vc = vcToTest else {
            XCTFail()
            return
        }
        setUpTableView()
        vc.viewDidLoad()
        vc.viewWillLayoutSubviews()
        let tabView = vc.tableView!
        tabView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        guard let indPaths = tabView.indexPathsForVisibleRows else {
            XCTFail()
            return
        }
        XCTAssert(indPaths.count > 0)
    }

    private func dataSourceDummy(with testOutput: TestOutput) -> TableDataSource {
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

    private func setUpTableView() {
        let tv = UITableView()
        vcToTest?.tableView = tv
        vcToTest?.view.addSubview(tv)
    }
    private func setupCollectionView() {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        vcToTest?.collectionView = cv
        vcToTest?.view.addSubview(cv)
    }
}
