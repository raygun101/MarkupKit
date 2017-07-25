//
//  VerticalAlignmentViewController.swift
//  MarkupKit-iOS
//
//  Created by Greg Brown on 7/25/17.
//
//

import UIKit
import MarkupKit

class VerticalAlignmentViewController: UIViewController {
    deinit {
        unbindAll()
    }

    override func loadView() {
        view = LMViewBuilder.view(withName:"VerticalAlignmentViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Vertical Alignment"
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let layoutView = view as! LMLayoutView

        layoutView.topSpacing = topLayoutGuide.length
        layoutView.bottomSpacing = bottomLayoutGuide.length
    }
}
