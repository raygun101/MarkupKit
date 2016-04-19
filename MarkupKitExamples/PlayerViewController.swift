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
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var playerView: LMPlayerView!
    @IBOutlet var playButton: UIButton!

    override func loadView() {
        view = LMViewBuilder.viewWithName("PlayerViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Player View"

        tableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        activityIndicatorView.startAnimating()

        playButton.enabled = false

        playerView.delegate = self

        playerView.layer.player = AVPlayer(URL: NSBundle.mainBundle().URLForResource("sample", withExtension: "mp4")!)
        playerView.layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }

    override func viewWillDisappear(animated: Bool) {
        playButton.enabled = false

        playerView.layer.player?.pause()

        playerView.delegate = nil
    }

    func playerView(playerView: LMPlayerView, isReadyForDisplay readyForDisplay: Bool) {
        activityIndicatorView.stopAnimating()

        tableView.reloadData()
        
        togglePlay()

        playButton.enabled = true
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (playerView.layer.player?.status == .ReadyToPlay) ? tableView.numberOfSections : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (playerView.layer.player?.status == .ReadyToPlay) ? tableView.numberOfRowsInSection(section) : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.cellForRowAtIndexPath(indexPath)!
    }

    @IBAction func togglePlay() {
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
