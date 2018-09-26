//
//  ViewController.swift
//  Travel
//
//  Created by 李兴 on 4/9/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import SwiftyJSON
import EasyToast
import SwiftSpinner

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    let locManager = CLLocationManager()
    let userDefault = UserDefaults()
    var current_location: CLLocation = CLLocation(latitude: 37.78583400,
                                                             longitude: -122.40641700)
    
    var favorite_place: [String] = [String]()
    var favorite_place_id: [String] = [String]()
    var search_result: JSON = JSON()
    var travel_mode: String = "DRIVING"
    var detail: JSON = JSON()
//    UITapGusture
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var favoriteView: UITableView!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var start_loc: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    var picker: UIPickerView?
    
    /* Init View */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        
        favoriteView.dataSource = self
        favoriteView.delegate = self
//        favoriteView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        picker = UIPickerView()
        picker?.delegate = self
        category.inputView = picker
        
        loadFavorite()
        
        self.inputAccessoryView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.segment.selectedSegmentIndex = 0
        loadFavorite()
        self.favoriteView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* Picker View */
    let myPickerData = ["accounting", "airport", "amusement_park", "aquarium", "art_gallery", "atm", "bakery", "bank", "bar", "beauty_salon", "bicycle_store", "book_store", "bowling_alley", "bus_station", "cafe", "campground", "car_dealer", "car_rental", "car_repair", "car_wash", "casino", "cemetery", "church", "city_hall", "clothing_store", "convenience_store", "courthouse", "dentist", "department_store", "doctor", "electrician", "electronics_store", "embassy", "fire_station", "florist", "funeral_home", "furniture_store", "gas_station", "gym", "hair_care", "hardware_store", "hindu_temple", "home_goods_store", "hospital", "insurance_agency", "jewelry_store", "laundry", "lawyer", "library", "liquor_store", "local_government_office", "locksmith", "lodging", "meal_delivery", "meal_takeaway", "mosque", "movie_rental", "movie_theater", "moving_company", "museum", "night_club", "painter", "park", "parking", "pet_store", "pharmacy", "physiotherapist", "plumber", "police", "post_office", "real_estate_agency", "restaurant", "roofing_contractor", "rv_park", "school", "shoe_store", "shopping_mall", "spa", "stadium", "storage", "store", "subway_station", "supermarket", "synagogue", "taxi_stand", "train_station", "transit_station", "travel_agency", "veterinary_care", "zoo"];
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row].capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category.text = myPickerData[row].capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    func inputAccessoryView() {
        let inputAccessoryView = UIToolbar()
        inputAccessoryView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40)
        
        
        let flexible = UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target: self, action: nil)
        let cancelBtn = UIBarButtonItem(barButtonSystemItem:.cancel, target: self, action: #selector(didCategoryCanceled))
        let doneBtn = UIBarButtonItem(barButtonSystemItem:.done, target: self, action: #selector(didCategorySelected))
        let arr = [cancelBtn,flexible,doneBtn]
        
        
        inputAccessoryView.setItems(arr, animated: true)
        category.inputAccessoryView = inputAccessoryView
    }
    
    @objc func didCategoryCanceled() {
        category.text = "Default"
        category.resignFirstResponder()
    }
    
    @objc func didCategorySelected() {
        if(category.text == "") {
            category.text = "Default"
        }
        
        category.resignFirstResponder()
    }

    /* Location Manager */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.submitButton.isEnabled = true
        current_location = locations.last!
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    /* Segment Control */
    @IBAction func segmentDidChanged(_ sender: Any) {
        if(segment.selectedSegmentIndex == 0) {
            scrollView?.contentOffset = CGPoint(x: 0, y: 0);
        }
        else {
            scrollView?.contentOffset = CGPoint(x: formView.frame.size.width, y: 0);
        }
    }
    
    /* Table View */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favorite_place.count == 0 {
            emptyMessage(message: "No favorite")
            return 0
        } else {
            favoriteView.backgroundView = nil
            favoriteView.separatorStyle = .singleLine
            return favorite_place.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SinglePlaceView! = (favoriteView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)) as! SinglePlaceView

        let place = JSON.init(parseJSON: favorite_place[indexPath.row])
//        let place = JSON(stringLiteral: favorite_place[indexPath.row])
//        let place = JSON.init(rawValue: favorite_place[indexPath.row])
        
        cell.setValueForCell(place: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        self.favorite_place_id.remove(at: indexPath.row)
        self.favorite_place.remove(at: indexPath.row)
        saveFavorite()
        
        self.favoriteView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.favoriteView!.deselectRow(at: indexPath, animated: true)
        
        SwiftSpinner.show("Loading detail")
        
        let place = JSON.init(parseJSON: favorite_place[indexPath.row])
        
        let urlString = "http://travelxing-env.us-east-2.elasticbeanstalk.com/detail?id=\(place["place_id"].string!)"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            self.detail = JSON(data);
            
            DispatchQueue.main.sync() {
                self.performSegue(withIdentifier: "show_detail", sender: self.detail["result"])
                SwiftSpinner.hide()
            }
            
            }.resume()
    }
    
    
    /* Hide keyboard */
    @IBAction func didDismissKeyboard(_ sender: Any) {
        self.distance.resignFirstResponder()
        self.keyword.resignFirstResponder()
    }
    /* Logic Controller */
    @IBAction func startLocBeginEditing(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_result" {
            let controller = segue.destination as! ResultViewController
            controller.search_result = search_result
        }
        if segue.identifier == "show_detail" {
            let controller = segue.destination as! DetailViewController
            controller.place = sender as! JSON
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "show_result" {
            return self.search_result["status"].string == "OK"
        } else {
            return true
        }
        
    }
    

    func loadFavorite() {
        self.favorite_place = userDefault.object(forKey: "favorite") as? [String] ?? [String]()
        self.favorite_place_id = userDefault.object(forKey: "favorite_id") as? [String] ?? [String]()
    }
    
    func saveFavorite() {
        userDefault.set(self.favorite_place, forKey: "favorite")
        userDefault.set(self.favorite_place_id, forKey: "favorite_id")
    }
    
    @IBAction func didClearForm(_ sender: Any) {
        self.keyword.text = ""
        self.category.text = "Default"
        self.distance.text = ""
        self.start_loc.text = "Your Location"
        
//        userDefault.set([], forKey: "favorite")
//        userDefault.set([], forKey: "favorite_id")
    }
    
    @IBAction func didSubmitForm(_ sender: Any) {
        print("form submitted")
        if (self.keyword.text?.isEmpty)! {
            //Show error message
            print("keyword is empty")
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: 1.5, dismissOnTap: false)
        } else {
            SwiftSpinner.show("Searching...")
            
            // Get user input
            let keyword = (self.keyword.text ?? "empty").replacingOccurrences(of: " ", with: "+")
            let category = self.category.text?.replacingOccurrences(of: " ", with: "_").lowercased() ?? ""
            let distance = self.distance.text!.isEmpty ? "10" : self.distance.text!
            let start_loc = self.start_loc.text ?? "Your Location"
            let start_here = start_loc == "Your Location"
            let cur_loc = start_here ? "\(self.current_location.coordinate.latitude),\(self.current_location.coordinate.longitude)" : start_loc.replacingOccurrences(of: " ", with: "_")
            
            let urlString = "http://travelxing-env.us-east-2.elasticbeanstalk.com/search?keyword=\(keyword)&category=\(String(describing: category))&start_loc=\(cur_loc)&start_here=\(start_here)&distance=\(distance)"
            
            print(urlString)
            
            guard let url = URL(string: urlString) else {
                SwiftSpinner.hide()
                self.view.showToast("Invalid url", position: .bottom, popTime: 1.5, dismissOnTap: false)
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                self.search_result = JSON(data);
                
                DispatchQueue.main.sync() {
                    if self.search_result["status"] == "OK" {
                        self.performSegue(withIdentifier: "show_result", sender: self.search_result)
                    } else {
                        self.view.showToast("No result", position: .bottom, popTime: 1.5, dismissOnTap: false)
                    }
                    
                    SwiftSpinner.hide()
                }
        
            }.resume()
        }
    }
    
    func emptyMessage(message: String) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.favoriteView.bounds.size.width, height: self.favoriteView.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        favoriteView.backgroundView = messageLabel;
        favoriteView.separatorStyle = .none;
    }
    
    
}

//Autocomplete
extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        start_loc.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


