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
import WebRPC

class ViewController: UITableViewController, NSURLSessionDataDelegate {
    var onSwitch: UISwitch!
    var temperatureCell: UITableViewCell!
    var temperatureStepper: UIStepper!

    var service: WSWebRPCService!

    static let FanSpeedSectionName = "fanSpeed"

    override func loadView() {
        view = LMViewBuilder.viewWithName("View", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSBundle.mainBundle().localizedStringForKey("title", value: nil, table: nil)

        tableView.delegate = self

        // Initialize service
        let credential = NSURLCredential(user: "tomcat", password: "tomcat", persistence: NSURLCredentialPersistence.ForSession);
        let protectionSpace = NSURLProtectionSpace(host: "localhost", port: 8443, `protocol`: "https", realm: "tomcat",
            authenticationMethod: NSURLAuthenticationMethodHTTPBasic)

        NSURLCredentialStorage.sharedCredentialStorage().setDefaultCredential(credential, forProtectionSpace: protectionSpace)

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData

        let delegateQueue = NSOperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1

        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        let baseURL = NSURL(string: "https://localhost:8443/webrpc-test-server/ac/")

        service = WSWebRPCService(session: session, baseURL: baseURL!)
    }

    override func viewWillAppear(animated: Bool) {
        service.invoke("getStatus") {(result, error) in
            if (error == nil) {
                let status = result as! NSDictionary

                // Update power
                self.onSwitch.on = status["on"] as! Bool

                // Update temperature
                self.temperatureStepper.value = status["temperature"] as! Double

                self.updateTemperatureLabel()

                // Update fan speed
                let fanSpeed = status["fanSpeed"] as! Int
                let fanSpeedSection = self.tableView.sectionWithName(ViewController.FanSpeedSectionName)

                self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: fanSpeed - 1, inSection: fanSpeedSection))!.checked = true
            } else {
                self.handleServiceError(error);
            }
        }
    }

    func togglePower(sender: UISwitch) {
        service.invoke("setOn", withArguments: ["on": sender.on]) {(result, error) in
            if (error != nil) {
                self.handleServiceError(error);
            }
        }
    }

    func updateTemperature(sender: UIStepper) {
        let temperature = Int(sender.value)

        service.invoke("setTemperature", withArguments: ["temperature": temperature]) {(result, error) in
            if (error != nil) {
                self.handleServiceError(error);
            }
        }

        updateTemperatureLabel()
    }

    func updateTemperatureLabel() {
        temperatureCell.textLabel!.text = "\(Int(temperatureStepper.value))° F"
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let sectionName = tableView.nameForSection(indexPath.section) {
            if (sectionName == ViewController.FanSpeedSectionName) {
                let fanSpeed = indexPath.row + 1

                service.invoke("setFanSpeed", withArguments: ["fanSpeed": fanSpeed]) {(result, error) in
                    if (error != nil) {
                        self.handleServiceError(error);
                    }
                }
            }
        }
    }

    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge,
        completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        // Allow self-signed certificate
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
        } else {
            completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling, nil)
        }
    }

    func handleServiceError(error: NSError) {
        let mainBundle = NSBundle.mainBundle()

        let alertController = UIAlertController(title: mainBundle.localizedStringForKey("serviceErrorTitle", value: nil, table: nil),
            message: mainBundle.localizedStringForKey("serviceErrorMessage", value: nil, table: nil),
            preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
