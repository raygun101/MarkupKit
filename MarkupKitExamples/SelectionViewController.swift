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

class SelectionViewController: UIViewController, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    let colorPickerViewController = ColorPickerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        title = "Color Picker"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Color", style: UIBarButtonItemStyle.Plain, target: self, action: "showColorPicker")

        colorPickerViewController.modalPresentationStyle = .Popover
        colorPickerViewController.tableView.delegate = self
    }

    func showColorPicker() {
        let colorPickerPresentationController = colorPickerViewController.presentationController as! UIPopoverPresentationController

        colorPickerPresentationController.barButtonItem = navigationItem.rightBarButtonItem
        colorPickerPresentationController.backgroundColor = UIColor.whiteColor()
        colorPickerPresentationController.delegate = self

        presentViewController(colorPickerViewController, animated: true, completion: nil)
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        view.backgroundColor = LMViewBuilder.colorValue(cell!.value as! String)

        dismissViewControllerAnimated(true, completion: nil)
    }
}
