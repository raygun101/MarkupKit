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
    var temperatureCell: UITableViewCell!
    var temperatureStepper: UIStepper!

    var highSpeedCell: UITableViewCell!
    var mediumSpeedCell: UITableViewCell!
    var lowSpeedCell: UITableViewCell!

    var selectedSpeedCell: UITableViewCell?

    static let speedSectionName = "speed"

    override func loadView() {
        view = LMViewBuilder.viewWithName("View", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSBundle.mainBundle().localizedStringForKey("title", value: nil, table: nil)

        tableView.delegate = self

        // Set initial temperature
        temperatureStepper.value = 70

        updateTemperature(temperatureStepper)

        // Set initial fan speed
        selectSpeed(highSpeedCell)
    }

    func togglePower(sender: UISwitch) {
        // TODO Update unit power
    }

    func updateTemperature(sender: UIStepper) {
        temperatureCell.textLabel!.text = "\(Int(sender.value))° F"

        // TODO Update unit temperature
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // TODO Return nil if this is not the speed section
        return indexPath;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let sectionName = tableView.nameForSection(indexPath.section) {
            if (sectionName == ViewController.speedSectionName) {
                selectSpeed(tableView.cellForRowAtIndexPath(indexPath)!)
            }
        }
    }

    func selectSpeed(speedCell: UITableViewCell) {
        selectedSpeedCell?.accessoryType = UITableViewCellAccessoryType.None

        speedCell.accessoryType = UITableViewCellAccessoryType.Checkmark

        selectedSpeedCell = speedCell

        // TODO Update unit fan speed
    }
}

