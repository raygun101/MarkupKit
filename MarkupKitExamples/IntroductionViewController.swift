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

class IntroductionViewController: UIViewController {
    @IBOutlet var nameField: UITextField!
    @IBOutlet var greetingLabel: UILabel!

    override func loadView() {
        view = LMViewBuilder.viewWithName("IntroductionView", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Introduction"

        edgesForExtendedLayout = UIRectEdge.None
    }

    @IBAction func showGreeting() {
        let name = nameField.text!
        let mainBundle = NSBundle.mainBundle()

        let greeting: String;
        if (name.isEmpty) {
            greeting = mainBundle.localizedStringForKey("unknownName", value: nil, table: nil)
        } else {
            greeting = String(format: mainBundle.localizedStringForKey("greetingFormat", value: nil, table: nil), name)
        }

        greetingLabel.text = greeting
    }
}
