# FFSDataSource

DataSource object for UITableView and UICollectionView

The FFSDataSource class can be used to create a datasource model for UITableViews and UICollectionViews.
The idea is to define, configure and handle events for a cell in one single place in code. This single object is connected to a TableView/CollectionView using a specialized connector class, which sets itself as the dataSource and delegate and stores a reference to the dataSource object. The connector responds to the different TableView-/CollectionView- datasource/delegate calls with information from the dataSource object. In fact those dataSource und delegate methods become mostly boilerplate and can be shared between all controllers, which control an UITableView or UICollectionView. But in case you need custom overrides of the delegate and datasource calls, you can subclass the connector class and add your own implementation or extend it by calling super for this call.

For convenience the package contains _TableViewDataSourceConnector_ (and _CollectionViewDataSourceConnector_), a connector class, which can be used as is or as baseclass for your own connector subclasses in case you need to customize it. _TableViewDataSourceConnector_ (and _CollectionViewDataSourceConnector_) implements the required datasource and delegate methods. Override them in your subclass to replace _TDSVC_'s implementation. In that case you must either handle the corresponding _FFSDataSource_ or call the implementation of the superclass in your implementation.

Written in Swift 4.

## Features

Create a datasource for Table/CollectionView with a stored closure for:
 * the configuration of the corresponding cell
 * the selection action
 * the deselection action
 All in ONE place in the code.

## How to get it

- Download the `FFSDataSource` swift framework

## How to install it

- Copy `FFSDataSource` to your project folder
- In your project add the `FFSDataSource` project as a subproject ("File"-menu: -> "Add files to <Your project>...)
- From the folder "Products" drag "FFSDataSource.framework" to the "Embedded binaries" section of your targets "General" tab

You're ready to go! 🎉

## How to use it

Here is a very simple example of a viewController using _FFSDataSource_.

- Create a class *SimpleTableController* with the follwoing code:
```
import UIKit
import FFSDataSource

class SimpleTableController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var connector: TableViewDataSourceConnector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connector = TableViewDataSourceConnector(with: testDataSource(), in: tableView)
    }

    private func testDataSource() -> TableDataSource {
        let dataSource = TableDataSource()
        let section = dataSource.addSection()

        section.addTableItem(with: CellSourceModel(
            cellIdentifier: "StandardCell",
            configureTableViewCell: { (cell, model, indexPath) in
                cell.textLabel?.text = "Cell content"
        },
            onSelect: { (indexPath) in
                print("Tap on cell \(indexPath.row) of section \(indexPath.section).")
        }))

        for number in 0...10 {
            section.addTableItem(with: CellSourceModel(
                cellIdentifier: "NumberCell",
                configureTableViewCell: { (cell, model, indexPath) in
                    cell.textLabel?.text = String(number)
            },
                onSelect: { (indexPath) in
                    print("Tap on number \(number) in cell \(indexPath.row) of section \(indexPath.section).")
            }))
        }
        return dataSource
    }
}
```
Create a scene in InterfaceBuilder and set its _Custom Class_ in the Identity Inspector to _SimpleTableController_
Add a UITableView to your scene and connect it to the outlet _tableView_ (Control+Drag from ViewController Icon to UITableView element in scene).
Create two prototype cells in your UITableView object. Define the cell reuseIdentifiers for the two cell prototypes: "StandardCell" and "NumberCell".
Run the project. In your tableView you should now see at the top a cell with the text "Cell content" and 11 cells with the numbers 0 to 10. On tap of each cell you should see an output in Xcode's console.

_CellSourceModel_ is a class which can be used as starting point to represent a cell model. If necessary, you can either subclass it to customize or you can use your own class OR struct, which complies to protocol _TableDataItemModel_
