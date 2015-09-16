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

class CustomCellViewController: UITableViewController {
    var pharmacies: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Custom Cell View"
        
        // Configure table view
        tableView.registerClass(PharmacyCell.self, forCellReuseIdentifier: PharmacyCell.self.description())
        tableView.estimatedRowHeight = 2

        // Load pharmacy list from JSON
        let path = NSBundle.mainBundle().pathForResource("pharmacies", ofType: "json")
        let data = NSData(contentsOfFile: path!)

        pharmacies = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())) as! [[String: AnyObject]]
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pharmacies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Get pharmacy data
        let index = indexPath.row
        var pharmacy = pharmacies.objectAtIndex(index) as! [String: AnyObject]

        // Configure cell with pharmacy data
        let cell = tableView.dequeueReusableCellWithIdentifier(PharmacyCell.self.description()) as! PharmacyCell

        cell.nameLabel.text = String(format: "%d. %@", index + 1, pharmacy["name"] as! String)
        cell.distanceLabel.text = String(format: "%.2f miles", pharmacy["distance"] as! Double)

        cell.addressLabel.text = String(format: "%@\n%@ %@ %@",
            pharmacy["address1"] as! String,
            pharmacy["city"] as! String, pharmacy["state"] as! String,
            pharmacy["zipCode"] as! String)

        let phoneNumberFormatter = PhoneNumberFormatter()

        let phone = pharmacy["phone"] as? NSString
        cell.phoneLabel.text = (phone == nil) ? nil : phoneNumberFormatter.stringForObjectValue(phone!)

        let fax = pharmacy["fax"] as? NSString
        cell.faxLabel.text = (fax == nil) ? nil : phoneNumberFormatter.stringForObjectValue(fax!)

        cell.emailLabel.text = pharmacy["email"] as? String

        return cell
    }
}

class PhoneNumberFormatter: NSFormatter {
    override func stringForObjectValue(obj: AnyObject) -> String? {
        let val = obj as! NSString

        return String(format:"(%@) %@-%@",
            val.substringWithRange(NSMakeRange(0, 3)),
            val.substringWithRange(NSMakeRange(3, 3)),
            val.substringWithRange(NSMakeRange(6, 4))
        )
    }
}
