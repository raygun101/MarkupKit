//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import UIKit
import MarkupKit

class ___FILEBASENAMEASIDENTIFIER___: LMTableViewCell {
    // TODO: Define outlets for view elements

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        LMViewBuilder.viewWithName("___FILEBASENAMEASIDENTIFIER___", owner: self, root: self)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}
