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
import WebKit
import MarkupKit

class WebViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var urlTextField: UITextField!

    override func loadView() {
        view = LMViewBuilder.view(withName: "WebViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Web View"

        edgesForExtendedLayout = UIRectEdge()

        urlTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaultNotificationCenter = NotificationCenter.default
        
        defaultNotificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        defaultNotificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        urlTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        loadURL()

        return false
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect

        let rootView = view as! LMRootView

        rootView.bottomPadding = frame.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let rootView = view as! LMRootView
        
        rootView.bottomPadding = 0
    }
    
    @IBAction func loadURL() {
        webView.load(URLRequest(url: URL(string: urlTextField.text!)!))
    }
}
