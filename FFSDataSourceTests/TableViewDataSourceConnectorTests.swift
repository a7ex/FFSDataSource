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
        let coordinator = DataSourceConnector(with: tds, in: UITableView())
        XCTAssert(coordinator.dataSource.numberOfSections() == 1)
    }
    
}
