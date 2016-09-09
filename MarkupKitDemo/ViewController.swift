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

class ViewController: UITableViewController, UICollectionViewDataSource {
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateTextField: UITextField!

    @IBOutlet var sizeTextField: UITextField!
    @IBOutlet var sizePickerView: LMPickerView!

    @IBOutlet var collectionView: LMCollectionView!

    @IBOutlet var stepper: UIStepper!
    @IBOutlet var slider: UISlider!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var progressView: UIProgressView!

    let icons = [
        "AccessTimeIcon",
        "BluetoothIcon",
        "CheckCircleIcon",
        "DoneIcon",
        "EventIcon",
        "FingerprintIcon",
        "GradeIcon"
    ]

    override func loadView() {
        view = LMViewBuilder.view(withName: "ViewController", owner: self, root: nil)

        tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MarkupKit Demo"

        collectionView.dataSource = self
        
        collectionView?.register(IconCell.self, forCellWithReuseIdentifier: IconCell.self.description())

        slider.minimumValue = Float(stepper.minimumValue)
        slider.maximumValue = Float(stepper.maximumValue)

        stepperValueChanged(stepper)
    }

    @IBAction func showGreeting() {
        let alertController = UIAlertController(title: "Greeting", message: "Hello!", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func cancelDateEdit() {
        dateTextField.resignFirstResponder()
    }

    @IBAction func updateDateText() {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd"

        dateTextField.text = dateFormatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
    }

    @IBAction func cancelSizeEdit() {
        sizeTextField.resignFirstResponder()
    }

    @IBAction func updateSizeText() {
        sizeTextField.text = sizePickerView.title(forRow: sizePickerView.selectedRow(inComponent: 0), forComponent: 0)!
        sizeTextField.resignFirstResponder()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCell.self.description(), for: indexPath) as! IconCell

        let index = (indexPath as NSIndexPath).item
        let icon = icons[index]

        cell.imageView.image = UIImage(named: icon)
        cell.label.text = icon

        return cell
    }

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        slider.value = Float(sender.value)

        updateState()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        stepper.value = Double(sender.value)

        updateState()
    }

    func updateState() {
        let value = slider.value

        pageControl.currentPage = Int(round(value * 10))
        progressView.progress = value
    }
}
