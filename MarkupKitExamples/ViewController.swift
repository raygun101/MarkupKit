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

class ViewController: UITableViewController {
    override func loadView() {
        view = LMViewBuilder.viewWithName("View", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MarkupKit Examples"

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        tableView.delegate = self
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let value = cell!.value as! String

        if (value == "introduction") {
            navigationController!.pushViewController(IntroductionViewController(), animated: true)
        } else if (value == "radioButtons") {
            navigationController!.pushViewController(RadioButtonViewController(), animated: true)
        } else if (value == "checkboxes") {
            navigationController!.pushViewController(CheckboxViewController(), animated: true)
        } else if (value == "colorPicker") {
            navigationController!.pushViewController(SelectionViewController(), animated: true)
        } else if (value == "customCellView") {
            navigationController!.pushViewController(CustomCellViewController(), animated: true)
        } else if (value == "layoutView") {
            navigationController!.pushViewController(LayoutViewController(), animated: true)
        } else if (value == "stackView") {
            navigationController!.pushViewController(StackViewController(), animated: true)
        } else if (value == "effectView") {
            navigationController!.pushViewController(EffectViewController(), animated: true)
        } else if (value == "scrollView") {
            navigationController!.pushViewController(ScrollViewController(), animated: true)
        } else if (value == "gridView") {
            navigationController!.pushViewController(GridViewController(), animated: true)
        } else if (value == "customSectionView") {
            navigationController!.pushViewController(CustomSectionViewController(), animated: true)
        } else if (value == "customComponentView") {
            navigationController!.pushViewController(CustomComponentViewController(), animated: true)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

