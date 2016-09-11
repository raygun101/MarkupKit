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

class ComplexWidthViewController: UIViewController {
    @IBOutlet var blueView: UIView!
    @IBOutlet var redView: UIView!

    override func loadView() {
        view = LMViewBuilder.view(withName: "ComplexWidthViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Complex Width Views"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain,
            target: self, action: #selector(done))

        edgesForExtendedLayout = UIRectEdge()

        // 2x width constraint
        let widthConstraint = NSLayoutConstraint(item: redView, attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal, toItem: blueView, attribute: NSLayoutAttribute.width,
            multiplier: 2.0, constant: 0)

        widthConstraint.priority = UILayoutPriorityDefaultHigh

        widthConstraint.isActive = true
    }

    func done() {
        navigationController!.popToRootViewController(animated: true)
    }
}
