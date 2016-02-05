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
import AVFoundation
import MarkupKit

class PlayerViewController: UITableViewController, LMPlayerViewDelegate {
    weak var playerView: LMPlayerView!
    weak var playButton: UIButton!

    override func loadView() {
        view = LMViewBuilder.viewWithName("PlayerView", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Player View"

        edgesForExtendedLayout = UIRectEdge.None

        playerView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        playerView.layer.player = AVPlayer(URL: NSBundle.mainBundle().URLForResource("sample", withExtension: "mp4")!)

        playButton.enabled = false
    }

    override func viewWillDisappear(animated: Bool) {
        playerView.layer.player?.pause()

        playButton.enabled = false
    }

    func playerView(playerView: LMPlayerView, isReadyForDisplay readyForDisplay: Bool) {
        togglePlay()

        playButton.enabled = true
    }

    func togglePlay() {
        let player = playerView.layer.player!

        if (player.rate > 0) {
            player.pause()

            playButton.normalTitle = "Play"
        } else {
            player.play()

            playButton.normalTitle = "Pause"
        }
    }
}
