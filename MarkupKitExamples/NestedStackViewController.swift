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

class NestedStackViewController: UIViewController {
    var imageView: UIImageView!

    var firstNameTextField: UITextField!
    var middleNameTextField: UITextField!
    var lastNameTextField: UITextField!

    override func loadView() {
        view = LMViewBuilder.viewWithName("NestedStackView", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Nested Stack Views"

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain,
            target: self, action: "next")

        edgesForExtendedLayout = UIRectEdge.None

        // Create custom constraints
        NSLayoutConstraint.activateConstraints([
            // Image view aspect ratio
            NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
                toItem: imageView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0),

            // Equal text field widths
            NSLayoutConstraint(item: middleNameTextField, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
                toItem: firstNameTextField, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: lastNameTextField, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
                toItem: middleNameTextField, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0)
        ])
    }

    func next() {
        // TODO
    }
}
