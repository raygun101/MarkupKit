//
//  BarsViewController.swift
//  MarkupKit-iOS
//
//  Created by Greg Brown on 5/19/17.
//
//

import UIKit
import MarkupKit

class BarsViewController: UIViewController {
    override func loadView() {
        view = LMViewBuilder.view(withName:"BarsViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Bars"

        edgesForExtendedLayout = UIRectEdge()
    }
}
