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

class RadioButtonViewController: UITableViewController {
    override func loadView() {
        view = loadViewFromMarkup()
    }

    func loadViewFromMarkup() -> UIView? {
        return LMViewBuilder.viewWithName("RadioButtonViewController", owner: self, root: nil)
    }

    func loadViewProgrammatically() -> UIView? {
        let tableView = LMTableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: UITableViewStyle.Grouped)

        tableView.setSelectionMode(LMTableViewSelectionMode.SingleCheckmark, forSection: 0)

        let smallCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        smallCell.textLabel!.text = "Small"

        tableView.insertCell(smallCell, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

        let mediumCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        mediumCell.textLabel!.text = "Medium"

        tableView.insertCell(mediumCell, forRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        let largeCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        largeCell.textLabel!.text = "Large"

        largeCell.checked = true

        tableView.insertCell(largeCell, forRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))

        let extraLargeCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        extraLargeCell.textLabel!.text = "Extra-Large"

        tableView.insertCell(extraLargeCell, forRowAtIndexPath: NSIndexPath(forRow: 3, inSection: 0))

        return tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Radio Buttons"

        tableView.delegate = self
    }
}
