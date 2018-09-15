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
        view = LMViewBuilder.view(withName: "ViewController", owner: self, root: nil)

        tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MarkupKit Examples"

        #if os(iOS)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        #endif
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        let value = cell!.value as? String

        switch value {
        case "horizontalAlignment":
            navigationController!.pushViewController(HorizontalAlignmentViewController(), animated: true)

        case "verticalAlignment":
            navigationController!.pushViewController(VerticalAlignmentViewController(), animated: true)

        case "anchorView":
            navigationController!.pushViewController(AnchorViewController(), animated: true)

        case "gridView":
            navigationController!.pushViewController(GridViewController(), animated: true)

        case "periodicTable":
            navigationController!.pushViewController(PeriodicTableViewController(), animated: true)

        case "scrollView":
            #if os(iOS)
            navigationController!.pushViewController(ScrollViewController(), animated: true)
            #endif

        case "pageView":
            #if os(iOS)
            navigationController!.pushViewController(PageViewController(), animated: true)
            #endif

        case "customCellView":
            navigationController!.pushViewController(CustomCellViewController(), animated: true)

        case "customSectionView":
            navigationController!.pushViewController(CustomSectionViewController(), animated: true)

        case "customComponentView":
            #if os(iOS)
            navigationController!.pushViewController(CustomComponentViewController(), animated: true)
            #endif

        case "collectionView":
            navigationController!.pushViewController(CollectionViewController(), animated: true)

        case "webView":
            #if os(iOS)
            navigationController!.pushViewController(WebViewController(), animated: true)
            #endif

        case "mapView":
            #if os(iOS)
            navigationController!.pushViewController(MapViewController(), animated: true)
            #endif

        case "radioButtons":
            navigationController!.pushViewController(RadioButtonViewController(), animated: true)

        case "checkboxes":
            navigationController!.pushViewController(CheckboxViewController(), animated: true)

        case "effectView":
            navigationController!.pushViewController(EffectViewController(), animated: true)

        case "animation":
            #if os(iOS)
            navigationController!.pushViewController(AnimationViewController(), animated: true)
            #endif

        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
