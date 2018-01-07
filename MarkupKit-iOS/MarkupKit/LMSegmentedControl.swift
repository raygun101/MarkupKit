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
 * Swift refinements to segmented control.
 */
extension LMSegmentedControl {
    open func insertSegment(withTitle title: String?, value: Any?, at segment: Int, animated: Bool) {
        __insertSegment(withTitle: title, value: value, at: UInt(segment), animated: animated)
    }

    open func insertSegment(with image: UIImage?, value: Any?, at segment: Int, animated: Bool) {
        __insertSegment(with: image, value: value, at: UInt(segment), animated: animated)
    }
}
