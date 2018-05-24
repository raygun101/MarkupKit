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

/**
 * Model class representing a table row.
 */
final class Row: NSObject, Decodable {
    @objc let icon: UIImage?

    @objc let heading: String
    @objc let detail: String

    enum CodingKeys: String, CodingKey {
        case icon
        case heading
        case detail
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        icon = UIImage(named: try values.decode(String.self, forKey: .icon))
        
        heading = try values.decode(String.self, forKey: .heading)
        detail = try values.decode(String.self, forKey: .detail)
    }
}
