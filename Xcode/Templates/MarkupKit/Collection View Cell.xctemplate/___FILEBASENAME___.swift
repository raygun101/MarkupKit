//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import UIKit
import MarkupKit

class ___FILEBASENAMEASIDENTIFIER___: LMCollectionViewCell {
    // TODO: Define outlets for view elements

    override init(frame: CGRect) {
        super.init(frame: frame)

        LMViewBuilder.viewWithName("___FILEBASENAMEASIDENTIFIER___", owner: self, root: self)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder);
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // TODO: Clear contents
    }
}
