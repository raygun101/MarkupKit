//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import MarkupKit

/**
 * Table view controller.
 */
class ViewController: UITableViewController {
    // Outlets
    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var footerSwitch: UISwitch!

    // Properties
    var rows: [[String: AnyObject]]!

    let dynamicSectionName = "dynamic"

    // View initialization
    override func loadView() {
        view = LMViewBuilder.view(withName: "ViewController", owner: self, root: nil)

        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self

        // Load row list from JSON
        let rowListURL = Bundle.main.url(forResource: "rows", withExtension: "json")

        rows = (try! JSONSerialization.jsonObject(with: try! Data(contentsOf: rowListURL!))) as! [[String: AnyObject]]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Lorem Ipsum"

        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.self.description())
    }

    // Button press handler
    @IBAction func buttonPressed() {
        let mainBundle = Bundle.main

        let alertController = UIAlertController(title: mainBundle.localizedString(forKey: "alert", value: nil, table: nil),
            message: "Lorem ipsum dolor sit amet.", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: mainBundle.localizedString(forKey: "ok", value: nil, table: nil),
            style: .default))

        present(alertController, animated: true, completion: nil)
    }

    // Data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n: Int
        if (tableView.name(forSection: section) == dynamicSectionName) {
            n = rows.count
        } else {
            n = tableView.numberOfRows(inSection: section)
        }

        return n
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if (tableView.name(forSection: (indexPath as NSIndexPath).section) == dynamicSectionName) {
            let row = rows[(indexPath as NSIndexPath).row]

            let customCell = tableView.dequeueReusableCell(withIdentifier: CustomCell.self.description()) as! CustomCell

            customCell.headingLabel.text = row["heading"] as? String
            customCell.detailLabel.text = row["detail"] as? String

            cell = customCell
        } else {
            cell = tableView.cellForRow(at: indexPath)!
        }

        return cell
    }

    // Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.name(forSection: (indexPath as NSIndexPath).section) == dynamicSectionName) {
            let row = rows[(indexPath as NSIndexPath).row]

            let detailViewController = DetailViewController()

            detailViewController.loadView()

            detailViewController.headingLabel.text = row["heading"] as? String
            detailViewController.detailLabel.text = row["detail"] as? String

            present(detailViewController, animated: true, completion: nil)
        }
    }
}

