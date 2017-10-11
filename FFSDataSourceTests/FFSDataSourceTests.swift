//
//  FFSDataSourceTests.swift
//  FFSDataSourceTests
//
//  Created by Alex da Franca on 04/03/2017.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import XCTest
@testable import FFSDataSource

class FFSDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTableDataSource() {
        
        let tds = TableDataSource()
        let sec = tds.addSection()
        sec.addTableItem(with: CellSourceModel(
            cellIdentifier: "",
            elementId: "testId",
            configureTableViewCell: { (cell, model, indexPath) in
                
        },
            onSelect: { (indexPath) in
                
        }))
        
        XCTAssert(tds.allItems.count == 1, "allItems.count must be 1")
        XCTAssert(tds.numberOfSections() == 1, "Number of sections must be 1")
        XCTAssert(!tds.models(by: "testId").isEmpty, "DataSource must contain cell with elementId 'testId'")
        XCTAssert(tds.model(at: IndexPath(row: 0, section: 0)) != nil, "model at index 0 of 0 must exist")
        
        let tableItem = sec.addTableItem(with: CellSourceModel(cellIdentifier: "Cell2"))
        XCTAssert(tableItem.getIndexPath().row == 1, "model must be at row 1")
        XCTAssert(tds.allItems.count == 2, "allItems.count must be 2")
        
        tds.insert(tableItem: tableItem, atIndex: 0, inSection: 3)
        guard let tableItem2 = tds.item(at: IndexPath(row: 0, section: 3)) else {
            XCTAssert(false, "model at index 3 / 0 must exist")
            return
        }
        XCTAssert(tds.numberOfSections() == 4, "Number of sections must be 4")
        XCTAssert(tds.allItems.count == 3, "allItems.count must be 3")
        
        XCTAssert(tableItem2.getIndexPath().row == 0, "model must be at row 0 of section 3")
        XCTAssert(tableItem2.getIndexPath().section == 3, "model must be at row 0 of section 3")
        
        XCTAssert(tds.model(at: IndexPath(row: 1, section: 0)) != nil, "model at index 3 of 0 must exist")
        XCTAssert(tds.item(at: IndexPath(row: 0, section: 3)) != nil, "item at index 0 of 3 must exist")
        
        if let section = tds.section(at: 2) {
            tds.remove(section)
            XCTAssert(tds.numberOfSections() == 3, "Number of sections must be 3")
        }
        let sectionToRemove = tds.section(at: 1)
        let removed = tds.removeSection(with: sectionToRemove?.sectionData.elementId ?? "")
        XCTAssert(tds.numberOfSections() == 2, "Number of sections must be 2")
        XCTAssert(sectionToRemove?.sectionData.elementId == removed?.sectionData.elementId, "ElementID of deleted item must match the one of returned item")
        
        tds.showSectionHeaders = true
        XCTAssert(tds.section(at: 0)?.showSectionHeaders == true, "When setting showSectionHeaders on a table all sections are set to showSectionHeaders")
    }
    
    func testAddTableItem() {
        let tds = TableDataSource()
        let sec = tds.addSection()
        sec.addTableItem(with: CellSourceModel(cellIdentifier: ""))
        
        tds.addTableItem(with: CellSourceModel(
            cellIdentifier: "",
            elementId: "testId",
            configureTableViewCell: { (cell, model, indexPath) in
                
        }, onSelect: { (indexPath) in
            
        }))
        
        XCTAssert(tds.numberOfSections() == 1, "Number of sections must be 1")
        XCTAssert(tds.numberOfItems(in: 0) == 2, "Number of items must be 2")
        
        tds.addTableItem(with: CellSourceModel(
            cellIdentifier: "",
            elementId: "testId",
            configureTableViewCell: { (cell, model, indexPath) in
                
        }, onSelect: { (indexPath) in
            
        }), toSection: 0)
        XCTAssert(tds.numberOfSections() == 1, "Number of sections must be 1")
        XCTAssert(tds.numberOfItems(in: 0) == 3, "Number of items must be 3")
        
        tds.addTableItem(with: CellSourceModel(
            cellIdentifier: "",
            elementId: "testId",
            configureTableViewCell: { (cell, model, indexPath) in
                
        }, onSelect: { (indexPath) in
            
        }), toSection: 2)
        XCTAssert(tds.numberOfSections() == 3, "Number of sections must be 3")
        XCTAssert(tds.numberOfItems(in: 0) == 3, "Number of items must still be 3 in section 0")
        XCTAssert(tds.numberOfItems(in: 1) == 0, "Number of items must be 0 in automatically added section 2")
        XCTAssert(tds.numberOfItems(in: 2) == 1, "Number of items must be 1 in new section 3")
    }
    
    func testAddTableItemWithoutIndex() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tds = TableDataSource()
        
        tds.addTableItem(with: CellSourceModel(
            cellIdentifier: "",
            elementId: "testId",
            configureTableViewCell: { (cell, model, indexPath) in
                
        }, onSelect: { (indexPath) in
            
        }))
        
        XCTAssert(tds.numberOfSections() == 1, "Number of sections must be 1")
        XCTAssert(tds.numberOfItems(in: 0) == 1, "Number of items must be 1")
    }
    
    func testSelectionCallBack() {
        let output = Output()
        let tds = dataSourceDummy(with: output)
        XCTAssert(tds.numberOfSections() == 1, "Number of sections must be 1")
        XCTAssert(tds.allItems.count == 12, "All items of dataSourceDummy should be 12")
        
        guard let item = tds.section(at: 0) else {
            XCTFail()
            return
        }
        item.doSelectionAction(at: 2)
        XCTAssert(output.lastMessage == "Tap on number 1 in cell 2 of section 0.", "All items of dataSourceDummy should be 12")
    }

    func testDeSelectionCallBack() {
        let output = Output()
        let tds = dataSourceDummy(with: output)
        guard let item = tds.section(at: 0) else {
            XCTFail()
            return
        }
        item.doDeselectionAction(at: 2)
        XCTAssert(output.lastMessage == "Deselect cell 2 of section 0.")
    }
    
    func testConfigurationCallBack() {
        let output = Output()
        let tds = dataSourceDummy(with: output)
        let indexPath = IndexPath(row: 2, section: 0)
        guard let item = tds.item(at: indexPath) else {
            XCTFail()
            return
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "NumberCell")
        item.model.configureTableViewCell?(cell, item.model, indexPath)
        XCTAssert(cell.textLabel?.text == "1")
    }
    
    func testTableDataSourcePerformance() {
        // This is an example of a performance test case.
        self.measure {
            let output = Output()
            let tds = dataSourceDummy(with: output)
            let item = tds.item(at: IndexPath(row: 2, section: 0))
            item?.doSelectionAction()
        }
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
    
}

protocol TestOutput {
    func print(_ msg: String)
}

class Output: TestOutput {
    var messages = [String]()
    var lastMessage: String {
        return messages.last ?? ""
    }
    func print(_ msg: String) {
        messages.append(msg)
    }
}
