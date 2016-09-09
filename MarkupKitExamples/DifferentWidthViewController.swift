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

class DifferentWidthViewController: UIViewController {
    override func loadView() {
        view = LMViewBuilder.view(withName: "DifferentWidthViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Different Width Views"

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain,
            target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain,
            target: self, action: #selector(getter: DifferentWidthViewController.next))

        edgesForExtendedLayout = UIRectEdge()
    }

    func next() {
        navigationController!.pushViewController(ComplexWidthViewController(), animated: true)
    }
}
