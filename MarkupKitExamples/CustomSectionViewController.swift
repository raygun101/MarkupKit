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

class CustomSectionViewController: UITableViewController {
    static let DynamicSectionName = "dynamic"
    static let CellIdentifier = "cell"

    override func loadView() {
        view = LMViewBuilder.view(withName: "CustomSectionViewController", owner: self, root: nil)

        tableView.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Custom Section View"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CustomSectionViewController.CellIdentifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n: Int
        if (tableView.name(forSection: section) == CustomSectionViewController.DynamicSectionName) {
            n = 3
        } else {
            n = tableView.numberOfRows(inSection: section)
        }

        return n
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if (tableView.name(forSection: (indexPath as NSIndexPath).section) == CustomSectionViewController.DynamicSectionName) {
            cell = tableView.dequeueReusableCell(withIdentifier: CustomSectionViewController.CellIdentifier)!
            
            cell.textLabel!.text = String((indexPath as NSIndexPath).row + 1)
        } else {
            cell = tableView.cellForRow(at: indexPath)!
        }

        return cell
    }
}
