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
    weak var stepper: UIStepper!
    weak var slider: UISlider!
    weak var pageControl: UIPageControl!
    weak var progressView: UIProgressView!

    override func loadView() {
        view = LMViewBuilder.viewWithName("View", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        slider.minimumValue = Float(stepper.minimumValue)
        slider.maximumValue = Float(stepper.maximumValue)

        stepperValueChanged(stepper)
    }

    override func viewWillLayoutSubviews() {
        tableView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
    }

    func showGreeting() {
        let alertController = UIAlertController(title: "Greeting", message: "Hello!", preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func stepperValueChanged(sender: UIStepper) {
        slider.value = Float(sender.value)

        updateState()
    }

    func sliderValueChanged(sender: UISlider) {
        stepper.value = Double(sender.value)

        updateState()
    }

    func updateState() {
        let value = slider.value

        pageControl.currentPage = Int(round(value * 10))
        progressView.progress = value
    }
}
