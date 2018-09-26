//
//  DetailViewController.swift
//  Travel
//
//  Created by 李兴 on 4/22/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailViewController: UITabBarController {

    var place: JSON = JSON()
    let userDefault = UserDefaults()
    var favorite_place: [String] = [String]()
    var favorite_place_id: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFavorite()
        
//        let favorite_button_image = self.favorite_place_id.contains(place["id"].string!) ? "favorite-filled": "favorite-empty"
        
        self.title = place["name"].string ?? ""
        
        let shareButton = UIBarButtonItem(image: UIImage(named: "forward-arrow"), style: .plain, target: self, action: #selector(shareViaTwitter))
        
        let favoriteButton1 = UIBarButtonItem(image: UIImage(named: "favorite-filled"), style: .plain, target: self, action: #selector(addFavorite))
        let favoriteButton2 = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(addFavorite))
        
        var items: [UIBarButtonItem] = []
        items.append(self.favorite_place_id.contains(place["id"].string!) ? favoriteButton1: favoriteButton2)
        items.append(shareButton);
        
        self.navigationItem.rightBarButtonItems = items
        
        let infoViewController = self.viewControllers![0] as! InfoViewController
        let photoViewController = self.viewControllers![1] as! PhotoViewController
        let mapViewController = self.viewControllers![2] as! MapViewController
        let reviewViewController = self.viewControllers![3] as! ReviewViewController
        
        infoViewController.place = place
        photoViewController.place = place
        mapViewController.place = place
        reviewViewController.place = place
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveFavorite()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
    }
    
    /* Favorite */
    @objc func addFavorite() {
//        print(place["name"].string ?? "empty")
        
        guard let index = favorite_place_id.index(of: place["id"].string!) else {
            self.favorite_place.append(place.rawString()!)
            self.favorite_place_id.append(place["id"].string!)
            print("favorite added")
            self.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(image: UIImage(named: "favorite-filled"), style: .plain, target: self, action: #selector(addFavorite))
            
            self.view.showToast("\(place["name"].string!) was added to favorite", position: .bottom, popTime: 1.5, dismissOnTap: false)
            return
        }
        
        self.favorite_place_id.remove(at: index)
        self.favorite_place.remove(at: index)
        self.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(addFavorite))
        
        self.view.showToast("\(place["name"].string!) was removed in favorite", position: .bottom, popTime: 1.5, dismissOnTap: false)
    }
    
    func loadFavorite() {
        self.favorite_place = userDefault.object(forKey: "favorite") as? [String] ?? [String]()
        self.favorite_place_id = userDefault.object(forKey: "favorite_id") as? [String] ?? [String]()
    }
    
    func saveFavorite() {
        userDefault.set(self.favorite_place, forKey: "favorite")
        userDefault.set(self.favorite_place_id, forKey: "favorite_id")
    }
    
    /* Twitter */
    @objc func shareViaTwitter() {
        let text = "Check out \(self.place["name"].string ?? "USC") located at \(self.place["formatted_address"].string ?? "empty"). Website: \(self.place["website"].string ?? (self.place["url"].string ?? "empty"))&via=TravelAndEntertainmentSearch";
        let url_str = "https://twitter.com/intent/tweet?text=\(text.replacingOccurrences(of: " ", with: "+"))Tweet"
        
        if let url = URL(string: url_str) {
            UIApplication.shared.open(url, options: [:])
        }

    }

}
