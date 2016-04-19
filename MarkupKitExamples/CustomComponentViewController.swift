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

class CustomComponentViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    static let DynamicComponentName = "dynamic"

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var label: UILabel!

    override func loadView() {
        view = LMViewBuilder.viewWithName("CustomComponentViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Custom Component View"

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateLabel()
    }

    override func viewWillLayoutSubviews() {
        let columnView = view as! LMColumnView

        columnView.topSpacing = topLayoutGuide.length
        columnView.bottomSpacing = bottomLayoutGuide.length
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerView.numberOfComponents
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let n: Int
        if (pickerView.nameForComponent(component) == CustomComponentViewController.DynamicComponentName) {
            n = 3
        } else {
            n = pickerView.numberOfRowsInComponent(component)
        }

        return n
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title: String
        if (pickerView.nameForComponent(component) == CustomComponentViewController.DynamicComponentName) {
            title = String(row + 1)
        } else {
            title = pickerView.titleForRow(row, forComponent:component)!
        }

        return title
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabel()
    }

    func updateLabel() {
        let title1 = pickerView(pickerView, titleForRow: pickerView.selectedRowInComponent(0), forComponent: 0)!
        let title2 = pickerView(pickerView, titleForRow: pickerView.selectedRowInComponent(1), forComponent: 1)!

        label.text = "\(title1), \(title2)"
    }
}
