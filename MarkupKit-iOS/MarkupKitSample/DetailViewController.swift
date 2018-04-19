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
 * Detail view controller.
 */
class DetailViewController: UIViewController {
    // Outlets
    @IBOutlet var iconImageView: UIImageView!

    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!

    // Row data
    var row: Row!

    // View management
    override func loadView() {
        view = LMViewBuilder.view(withName: "DetailViewController", owner: self, root: LMRootView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        iconImageView.image = row.icon

        headingLabel.text = row.heading
        detailLabel.text = row.detail
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let rootView = view as! LMRootView

        rootView.topSpacing = topLayoutGuide.length
        rootView.bottomSpacing = bottomLayoutGuide.length
    }

    // Done button press handler
    @IBAction func doneButtonPressed() {
        dismiss(animated: true)
    }
}

/**
 * Detail view controller preview.
 */
@IBDesignable
class DetailViewControllerPreview: LMRootView {
    override func prepareForInterfaceBuilder() {
        let owner = DetailViewController(nibName: nil, bundle: nil)

        LMViewBuilder.view(withName: "DetailViewController", owner: owner, root: self)

        owner.iconImageView.image = UIImage(named: "BeachIcon", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        owner.headingLabel.text = "Heading Text"
        owner.detailLabel.text = "Detail Message"
    }
}

