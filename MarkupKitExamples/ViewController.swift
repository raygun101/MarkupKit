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

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let value = cell!.value as! String

        if (value == "radioButtons") {
            navigationController!.pushViewController(RadioButtonViewController(), animated: true)
        } else if (value == "checkboxes") {
            navigationController!.pushViewController(CheckboxViewController(), animated: true)
        } else if (value == "selectionView") {
            navigationController!.pushViewController(SelectionViewController(), animated: true)
        } else if (value == "customCellView") {
            navigationController!.pushViewController(CustomCellViewController(), animated: true)
        } else if (value == "layoutViews") {
            navigationController!.pushViewController(LayoutViewController(), animated: true)
        } else if (value == "stackViews") {
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
        } else if (value == "linearGradientView") {
            navigationController!.pushViewController(LinearGradientViewController(), animated: true)
        } else if (value == "radialGradientView") {
            navigationController!.pushViewController(RadialGradientViewController(), animated: true)
        } else if (value == "pageView") {
            navigationController!.pushViewController(PageViewController(), animated: true)
        } else if (value == "sizeClassView") {
            navigationController!.pushViewController(SizeClassViewController(), animated: true)
        } else if (value == "formView") {
            navigationController!.pushViewController(FormViewController(), animated: true)
        } else if (value == "autoLayoutCookbook") {
            navigationController!.pushViewController(SimpleStackViewController(), animated: true)
        } else if (value == "periodicTable") {
            navigationController!.pushViewController(PeriodicTableViewController(), animated: true)
        } else if (value == "collectionView") {
            navigationController!.pushViewController(CollectionViewController(), animated: true)
        } else if (value == "playerView") {
            navigationController!.pushViewController(PlayerViewController(), animated: true)
        } else if (value == "webView") {
            navigationController!.pushViewController(WebViewController(), animated: true)
        } else if (value == "mapView") {
            navigationController!.pushViewController(MapViewController(), animated: true)
        } else if (value == "includes") {
            navigationController!.pushViewController(IncludesViewController(), animated: true)
        } else if (value == "colorsAndFonts") {
            navigationController!.pushViewController(ColorsAndFontsViewController(), animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

