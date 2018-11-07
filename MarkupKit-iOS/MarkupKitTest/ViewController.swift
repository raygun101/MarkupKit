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

class ViewController: UIViewController {
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var imageView: UIImageView!

    @IBOutlet var segmentedControl: LMSegmentedControl!

    @objc let number = 12345
    @objc let values = [1, 2, 3, 4, 5, 6]

    @objc let one = "One"
    @objc let two = "Two"
    @objc dynamic var three = "Three"

    @objc let prompt = NSAttributedString(string: "Press Me!")

    @objc let date = Date()

    @objc let personNameComponents: PersonNameComponents = {
        var personNameComponents = PersonNameComponents()

        personNameComponents.givenName = "James"
        personNameComponents.middleName = "Tiberius"
        personNameComponents.familyName = "Kirk"

        return personNameComponents
    }()

    @objc let byteCount = 3 * 1024 * 1024

    override func loadView() {
        view = LMViewBuilder.view(withName: "ViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.value = "2"

        segmentedControl.insertSegment(withTitle: "Four", value: "4", at: 3, animated: false)
    }

    @IBAction func handlePrimaryActionTriggered(_ sender: UIButton) {
        NSLog("Button pressed.")

        three = "Five"

        unbindAll()
    }

    @IBAction func handleSegmentedControlValueChanged(_ sender: LMSegmentedControl) {
        NSLog("Segment selected: \(sender.value ?? "none")")
    }

    @IBAction func handleSwitchValueChanged(_ sender: UISwitch) {
        imageView.isDisplayable = sender.isOn
    }
}
