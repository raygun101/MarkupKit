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
 * Table view controller template.
 */
class ViewController: UITableViewController {
    // Outlets
    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var footerSwitch: UISwitch!

    // Properties
    var rows: [[String: AnyObject]]!

    // Constants
    let dynamicSectionName = "dynamic"

    // View initialization
    override func loadView() {
        view = LMViewBuilder.viewWithName("View", owner: self, root: nil)

        tableView.dataSource = self
        tableView.delegate = self

        let path = NSBundle.mainBundle().pathForResource("rows", ofType: "json")
        let data = NSData(contentsOfFile: path!)

        rows = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! [[String: AnyObject]]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Lorem Ipsum"

        tableView.registerClass(CustomCell.self, forCellReuseIdentifier: CustomCell.self.description())
    }

    // Button press handler
    @IBAction func buttonPressed() {
        let mainBundle = NSBundle.mainBundle();

        let alertController = UIAlertController(title: mainBundle.localizedStringForKey("alert", value: nil, table: nil),
            message: "Lorem ipsum dolor sit amet.", preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: mainBundle.localizedStringForKey("ok", value: nil, table: nil),
            style: .Default, handler:nil))

        presentViewController(alertController, animated: true, completion: nil)
    }

    // Data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableView.numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n: Int
        if (tableView.nameForSection(section) == dynamicSectionName) {
            n = rows.count
        } else {
            n = tableView.numberOfRowsInSection(section)
        }

        return n
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if (tableView.nameForSection(indexPath.section) == dynamicSectionName) {
            let row = rows[indexPath.row]

            let customCell = tableView.dequeueReusableCellWithIdentifier(CustomCell.self.description()) as! CustomCell

            customCell.headingLabel.text = row["heading"] as? String
            customCell.detailLabel.text = row["detail"] as? String

            cell = customCell
        } else {
            cell = tableView.cellForRowAtIndexPath(indexPath)!
        }

        return cell
    }

    // Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView.nameForSection(indexPath.section) == dynamicSectionName) {
            let row = rows[indexPath.row]

            let detailViewController = DetailViewController()

            detailViewController.loadView()

            detailViewController.headingLabel.text = row["heading"] as? String
            detailViewController.detailLabel.text = row["detail"] as? String

            presentViewController(detailViewController, animated: true, completion: nil)
        }
    }
}

