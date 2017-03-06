# FFSDataSource

![Overview](/images/json2swift.jpg)

DataSource object for UITableView and UICollectionView

Class, which can be used to create a datasource model for UITableViews and UICollectionViews. Together with the necessary datasource and delegate methods to use FFSDataSource as model for the contents of a Table-/CollectionView in a ViewCOntroller.

Written in Swift 3.

## Features

- Create the datasource, define the configuration of the corresponding cell and the selection and deselection action as closures in the same place in code.

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

    sec.addTableItem(with: CellSourceModel(
      cellIdentifier: "Standard",
      configureTableViewCell: { (cell, model, indexPath) in
        cell.textLabel?.text = "Cell content"
    },
      onSelect: { [unowned self] (indexPath) in
        print("Tap on cell \(indexPath.row) of section \(indexPath.section).")
    }))
    return dataSource
  }
}
```
Add a UITableView to your ViewCobtroller and connect it to the outlet tableView, which is defined in the base class "TDSVC".

"TDSVC" provides all necessary dataSource and delegate methods to connect `FFSDataSource` with you ViewController. Of course you can use your own ViewController (or baseclass) which complies to protocol "FFSDataSourceStorageVC".

"CellSourceModel" is a class which can be used as starting point to represent a cell model. You can either subclass it to customize or you can use your own class OR struct, which complies to protocol "TableDataItemModel"
