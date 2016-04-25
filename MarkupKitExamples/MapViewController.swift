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
import MapKit
import MarkupKit

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var latitudeTextField: UITextField!
    @IBOutlet var longitudeTextField: UITextField!
    
    static let Radius = 250.0
    
    override func loadView() {
        view = LMViewBuilder.viewWithName("MapViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Map View"

        edgesForExtendedLayout = UIRectEdge.None
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        
        defaultNotificationCenter.addObserver(self,
            selector: #selector(MapViewController.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)

        defaultNotificationCenter.addObserver(self,
            selector: #selector(MapViewController.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        latitudeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        
        defaultNotificationCenter.removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        defaultNotificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        (view as! LMColumnView).bottomSpacing = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size.height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        (view as! LMColumnView).bottomSpacing = 0
    }
    
    @IBAction func showLocation() {
        let latitude = Double(latitudeTextField.text!)
        let longitude = Double(longitudeTextField.text!)
        
        if (latitude != nil && longitude != nil) {
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                MapViewController.Radius * 1000, MapViewController.Radius * 1000), animated: true)
        }
    }
}
