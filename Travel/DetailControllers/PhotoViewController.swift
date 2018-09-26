//
//  PhotoViewController.swift
//  Travel
//
//  Created by 李兴 on 4/22/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces

class PhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var place: JSON = JSON()
    var photos: [GMSPlacePhotoMetadata] = [GMSPlacePhotoMetadata]()
    
    @IBOutlet weak var ImageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageTableView.dataSource = self
        ImageTableView.delegate = self
        
        loadPhotoForPlace(placeID: place["place_id"].string!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if photos.count == 0 {
            emptyMessage(message: "No Photo")
            return 0
        } else {
            ImageTableView.backgroundView = nil
            ImageTableView.separatorStyle = .singleLine
            return photos.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (ImageTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)) as UITableViewCell
        
        loadImageForMetadata(photoMetadata: photos[indexPath.row], imageView: cell.imageView!)
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func loadPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.photos = photos?.results ?? []
                
                self.ImageTableView.reloadData()
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, imageView: UIImageView) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                imageView.image = photo;
            }
        })
    }
    
    func emptyMessage(message: String) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.ImageTableView.bounds.size.width, height: self.ImageTableView.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        //        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        ImageTableView.backgroundView = messageLabel;
        ImageTableView.separatorStyle = .none;
    }

}
