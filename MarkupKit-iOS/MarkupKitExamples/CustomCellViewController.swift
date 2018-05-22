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

class Pharmacy: NSObject, Decodable {
    @objc var name: String?

    @objc var distance: Double = 0

    @objc var street: String?
    @objc var city: String?
    @objc var state: String?
    @objc var zipCode: String?

    @objc var address: String {
        return String(format: "%@\n%@ %@ %@", street!, city!, state!, zipCode!)
    }

    @objc var phone: String?
    @objc var fax: String?
    @objc var email: String?
}

class CustomCellViewController: UITableViewController {
    var pharmacies: [Pharmacy]!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Custom Cell View"
        
        tableView.estimatedRowHeight = 2

        tableView.register(PharmacyCell.self, forCellReuseIdentifier: PharmacyCell.description())

        let jsonDecoder = JSONDecoder()

        pharmacies = try! jsonDecoder.decode([Pharmacy].self, from: try! Data(contentsOf: Bundle.main.url(forResource: "pharmacies", withExtension: "json")!))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pharmacies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pharmacyCell = tableView.dequeueReusableCell(withIdentifier: PharmacyCell.description(), for: indexPath) as! PharmacyCell

        pharmacyCell.pharmacy = pharmacies[indexPath.row]

        return pharmacyCell
    }
}
