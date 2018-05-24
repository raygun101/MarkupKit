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

final class Pharmacy: NSObject, Decodable {
    @objc let name: String

    @objc let street: String
    @objc let city: String
    @objc let state: String
    @objc let zipCode: String

    @objc var address: String {
        return String(format: "%@\n%@ %@ %@", street, city, state, zipCode)
    }

    @objc let phone: String
    @objc let fax: String
    @objc let email: String

    @objc let distance: Double

    enum CodingKeys: String, CodingKey {
        case name
        case street
        case city
        case state
        case zipCode
        case phone
        case fax
        case email
        case distance
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name = try values.decode(String.self, forKey: .name)

        street = try values.decode(String.self, forKey: .street)
        city = try values.decode(String.self, forKey: .city)
        state = try values.decode(String.self, forKey: .state)
        zipCode = try values.decode(String.self, forKey: .zipCode)

        phone = try values.decode(String.self, forKey: .phone)
        fax = try values.decode(String.self, forKey: .fax)
        email = try values.decode(String.self, forKey: .email)

        distance = try values.decode(Double.self, forKey: .distance)
    }
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
