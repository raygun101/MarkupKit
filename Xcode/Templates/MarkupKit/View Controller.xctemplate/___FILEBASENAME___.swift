//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import UIKit
import MarkupKit

class ___FILEBASENAMEASIDENTIFIER___: UIViewController {
    deinit {
        unbindAll()
    }

    override func loadView() {
        view = LMViewBuilder.view(withName: "___FILEBASENAMEASIDENTIFIER___", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Perform any post-load configuration
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let rootView = view as! LMRootView

        rootView.topSpacing = topLayoutGuide.length
        rootView.bottomSpacing = bottomLayoutGuide.length
    }
}
