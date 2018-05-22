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

class PharmacyCell: LMTableViewCell {
    @objc dynamic var pharmacy: Pharmacy!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        LMViewBuilder.view(withName: "PharmacyCell", owner: self, root: self)
    }

    required init?(coder decoder: NSCoder) {
        return nil
    }

    deinit {
        unbindAll()
    }

    override func formatter(withName name: String, arguments: [String : Any]) -> Formatter? {
        let formatter: Formatter?
        switch name {
        case "phoneNumber":
            formatter = PhoneNumberFormatter()

        default:
            formatter = super.formatter(withName: name, arguments: arguments)
        }

        return formatter
    }
}

class PhoneNumberFormatter: Formatter {
    override func string(for object: Any?) -> String? {
        guard let value = object as? NSString else {
            return nil
        }

        return String(format: "(%@) %@-%@",
            value.substring(with: NSMakeRange(0, 3)),
            value.substring(with: NSMakeRange(3, 3)),
            value.substring(with: NSMakeRange(6, 4))
        )
    }
}
