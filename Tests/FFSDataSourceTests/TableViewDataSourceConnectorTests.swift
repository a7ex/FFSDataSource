//
//  TableViewDataSourceConnectorTests.swift
//  FFSDataSourceTests
//
//  Created by Alex da Franca on 13.07.18.
//  Copyright © 2018 Farbflash. All rights reserved.
//

import XCTest
@testable import FFSDataSource

class TableViewDataSourceConnectorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreation() {
        let output = Output()
        let tds = TestData.dataSourceDummy(with: output)
        let tableView = UITableView()
        tableView.register(StandardCell.self, forCellReuseIdentifier: StandardCell.reuseIdentifier)
        tableView.register(NumberCell.self, forCellReuseIdentifier: NumberCell.reuseIdentifier)
        let coordinator = DataSourceConnector(with: tds, in: tableView)
        XCTAssert(coordinator.numberOfSections(in: tableView) == 1, "The number of sections should be 1")
        XCTAssert(coordinator.tableView(tableView, numberOfRowsInSection: 0) == 12, "The number of items should be 12")
        let cell = coordinator.tableView(tableView, cellForRowAt: IndexPath(item: 0, section: 0))
        XCTAssert(cell.textLabel?.text == "5", "The text of cell 1 should be '5'")
    }
    
}
