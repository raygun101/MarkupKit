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

class MapViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var latitudeTextField: UITextField!
    @IBOutlet var longitudeTextField: UITextField!
    
    let radius = 250.0
    
    override func loadView() {
        view = LMViewBuilder.view(withName: "MapViewController", owner: self, root: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Map View"

        edgesForExtendedLayout = UIRectEdge()

        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        latitudeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        showLocation()

        return false
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

        let rootView = view as! LMRootView

        rootView.bottomPadding = frame.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let rootView = view as! LMRootView
        
        rootView.bottomPadding = 0
    }
    
    @IBAction func showLocation() {
        let latitude = Double(latitudeTextField.text ?? "") ?? 0
        let longitude = Double(longitudeTextField.text ?? "") ?? 0
        
        if (latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180) {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                latitudinalMeters: radius * 1000, longitudinalMeters: radius * 1000)

            if (region.center.latitude + region.span.latitudeDelta <= 90
                && region.center.latitude - region.span.latitudeDelta >= -90) {
                mapView.setRegion(region, animated: true)
            }
        }
    }
}
