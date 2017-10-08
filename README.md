# FFSDataSource

![Overview](/images/json2swift.jpg)

DataSource object for UITableView and UICollectionView

The FFSDataSource class can be used to create a datasource model for UITableViews and UICollectionViews.
The idea is to define, configure and handle events for a cell in one single place in code. This single object is stored as instance variable for each different UITableView/UICollectionView of the UIViewController subclass and can then be used to respond to the different TableView-/CollectionView- datasource/delegate calls. In fact those dataSource und delegate methods become mostly boilerplate and can be shared between all controllers, which control an UITableView or UICollectionView.

For convenience the package contains _TDSVC_, an UIViewController baseclass, which can be used as baseclass for your UIViewController subclasses. _TDSVC_ defines outlets for a UITableView and for a UICollectionView. _TDSVC_ implements the required datasource and delegate methods. Override them in your subclass to replace _TDSVC_'s implementation. In that case you must either handle the corresponding _FFSDataSource_ or call the implementation of the superclass in your implementation.
_TDSVC_ is also a good place to examine how _FFSDataSource_ is used.

Written in Swift 3.

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

In any of your class, where you want to use `FFSDataSource`

```
import UIKit
import FFSDataSource

class ViewController: TDSVC {

  override func viewDidLoad() {
    super.viewDidLoad()

    setupTable()
  }

  private func setupTable() {
    guard let tableView = tableView else { return }
    setDataSource(testDataSource(), forView: tableView)
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
Add a UITableView to your ViewCobtroller and connect it to the outlet tableView, which is defined in the base class "TDSVC".

"TDSVC" provides all necessary dataSource and delegate methods to connect `FFSDataSource` with your ViewController. Of course you can use your own ViewController (or baseclass) which complies to protocol "FFSDataSourceStorageVC".

"CellSourceModel" is a class which can be used as starting point to represent a cell model. You can either subclass it to customize or you can use your own class OR struct, which complies to protocol "TableDataItemModel"
