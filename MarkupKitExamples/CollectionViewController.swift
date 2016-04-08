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

class CollectionViewController: UICollectionViewController {
    let colors = [
        "#ffffff", "#c0c0c0", "#808080", "#000000",
        "#ff0000", "#800000", "#ffff00", "#808080",
        "#00ff00", "#008000", "#00ffff", "#008080",
        "#0000ff", "#000080", "#ff00ff", "#800080"
    ];

    override func loadView() {
        let collectionViewLayout = UICollectionViewFlowLayout();

        collectionViewLayout.itemSize = CGSize(width: 80, height: 120)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)

        collectionView?.backgroundColor = UIColor.whiteColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Collection View"

        edgesForExtendedLayout = UIRectEdge.None

        collectionView?.registerClass(ColorCell.self, forCellWithReuseIdentifier: ColorCell.self.description())
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ColorCell.self.description(), forIndexPath: indexPath) as! ColorCell

        let index = indexPath.item
        let color = colors[index]

        cell.indexLabel.text = String(index)
        cell.colorView.backgroundColor = LMViewBuilder.colorValue(color)
        cell.valueLabel.text = color

        return cell;
    }
}
