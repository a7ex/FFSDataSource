//
//  FFSDataSourceStorageVCTests.swift
//  FFSDataSourceTests
//
//  Created by Alex da Franca on 02.04.18.
//  Copyright © 2018 Farbflash. All rights reserved.
//

import XCTest
@testable import FFSDataSource


class FFSDataSourceStorageVCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNearestView() {
        class MockView: UIView { }
        let mockView = MockView(frame: .zero)
        let view = UIView()
        mockView.addSubview(view)
        let foundView = view.nearestSuperview(ofType: MockView.self)
        XCTAssertNotNil(foundView, "View of type MockView not found in view hierarchy")
    }
    
    func testIndexPathForCell() {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 200, height: 300), style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StandardCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NumberCell")
        let output = Output()
        let dataSource = TestFactory.dataSourceDummy(with: output)
        let dataSourceConnector = TableDataSourceConnector(with: dataSource)
        tableView.connect(to: dataSourceConnector)
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath)
        XCTAssert(cell?.indexPath == indexPath)
    }
}
