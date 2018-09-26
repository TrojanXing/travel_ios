//
//  MapViewController.swift
//  Travel
//
//  Created by 李兴 on 4/22/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces
import GoogleMaps

let GEOCODE_KEY = "AIzaSyDgalPY8YqVeMuuDwziK4iOAra0QAXssbg"

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
//    let locManager = CLLocationManager()
//    var current_location: CLLocation = CLLocation(latitude: 37.78583400, longitude: -122.40641700)

    @IBOutlet weak var travelModeSelection: UISegmentedControl!
    @IBOutlet weak var start_loc: UITextField!
    @IBOutlet weak var mapContainer: GMSMapView!
    
    var place: JSON = JSON()
    let travel_modes: [String] = ["driving", "bicycling", "transit", "walking"]
    var travel_mode = "driving"
    var source: String = ""
    var destination: String = ""
    var route = GMSPolyline()
    let sourceMarker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        locManager.delegate = self
//        locManager.requestAlwaysAuthorization()
//        locManager.startUpdatingLocation()
        
        let lat = place["geometry"]["location"]["lat"].doubleValue
        let lng = place["geometry"]["location"]["lng"].doubleValue
        destination = "\(lat),\(lng)"
        
        mapContainer.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14.0)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        marker.map = mapContainer
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Location Manager */
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let current_location = locations.last!
//        self.source = "\(current_location.coordinate.latitude),\(current_location.coordinate.longitude)"
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Error \(error)")
//    }

    /* Auto-complete */
    @IBAction func startLocBeginEditing(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    /* Select travel mode */
    @IBAction func didTravelModeSelected(_ sender: Any) {
        self.travel_mode = self.travel_modes[travelModeSelection.selectedSegmentIndex]
        
        updateRoutes()
        
    }
    
    func updateRoutes() {
        if !source.isEmpty && !destination.isEmpty {
            let url_str = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.source)&destination=\(self.destination)&mode=\(self.travel_mode)&key=AIzaSyBA1rSgQnXJkO1mD_qyUzKMxX6I4eJg7So"
            
            guard let url = URL(string: url_str) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                //            var search_result:JSON = JSON.null
                
                guard let data = data else { return }
                let result = JSON(data);
                let points = result["routes"][0]["overview_polyline"]["points"].string!
//                let bounds = result["routes"][0]["bounds"].array as! GMSCoordinateBounds
                
                DispatchQueue.main.sync() {
                    let path = GMSPath(fromEncodedPath: points)
                    let bounds = GMSCoordinateBounds.init(path: path!)
                    self.route.map = nil
                    self.route = GMSPolyline(path: path)
                    self.route.strokeWidth = 4
                    self.route.strokeColor = UIColor.blue
                    self.route.map = self.mapContainer
                    
                    let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(20))
                    self.mapContainer.animate(with: update)
                }
                
                }.resume()
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//Autocomplete
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        start_loc.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
        let address = (place.formattedAddress?.replacingOccurrences(of: " ", with: "+"))!
//        self.source = (start_loc.text?.replacingOccurrences(of: " ", with: "+"))!
        let url_str = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&key=\(GEOCODE_KEY)"
        
        guard let url = URL(string: url_str) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            //            var search_result:JSON = JSON.null
            
            guard let data = data else { return }
            let result = JSON(data);
            let location = result["results"][0]["geometry"]["location"]
            let lat = location["lat"].doubleValue
            let lng = location["lng"].doubleValue
            
            DispatchQueue.main.sync() {
                
                self.sourceMarker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                self.sourceMarker.map = self.mapContainer
                
                self.source = "\(lat),\(lng)"
                self.updateRoutes()
            }
            
            }.resume()
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

