//
//  ResultViewController.swift
//  Travel
//
//  Created by 李兴 on 4/21/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import EasyToast

class ResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SinglePlaceViewDelegate {
    
    let userDefault = UserDefaults()
    var current_page: Int = 0
    var search_results: [JSON] = [JSON]()
    var search_result: JSON = JSON()
    var display_content: [JSON] = [JSON]()
    var has_next_page: Bool = false
    var detail: JSON = JSON()
    var favorite_place: [String] = [String]()
    var favorite_place_id: [String] = [String]()
    
    @IBOutlet weak var ResultTable: UITableView!
    @IBOutlet weak var PrevButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ResultTable.dataSource = self
        ResultTable.delegate = self
        
        self.navigationItem.title = "Search Result"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        loadFavorite()
        
        print(search_result["status"])
        
        //Clear search result
        search_results.removeAll()
        
        self.search_results.append(search_result)
        
        self.display_content = search_result["results"].array!
        
        self.has_next_page = search_result["next_page_token"] != JSON.null

        // Check button status
        self.PrevButton.isEnabled = false
        self.NextButton.isEnabled = has_next_page
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFavorite()
        self.ResultTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveFavorite()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Table View */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return display_content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SinglePlaceView! = (ResultTable.dequeueReusableCell(withIdentifier: "single_place", for: indexPath)) as! SinglePlaceView
        
        cell.setValueForCell(place: display_content[indexPath.row])
        if favorite_place_id.contains(display_content[indexPath.row]["id"].string!) {
            cell.setFavoriteIcon(image: UIImage(named: "favorite-filled")!)
        } else {
            cell.setFavoriteIcon(image: UIImage(named: "favorite-empty")!)
        }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.ResultTable!.deselectRow(at: indexPath, animated: true)
        
        SwiftSpinner.show("Loading detail")
        
        let place = self.display_content[indexPath.row]
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_detail" {
            let controller = segue.destination as! DetailViewController
            controller.place = sender as! JSON
        }
    }
    
    /* Favorite */
    func addFavorite(place: JSON!) {
        print(place["name"].string ?? "empty")
        
        guard let index = favorite_place_id.index(of: place["id"].string!) else {
            self.favorite_place.append(place.rawString()!)
            self.favorite_place_id.append(place["id"].string!)
            print("favorite added")
            
            self.ResultTable.reloadData()
            saveFavorite()
            
            self.view.showToast("\(place["name"].string!) was added to favorite", position: .bottom, popTime: 1.5, dismissOnTap: false)
            saveFavorite()
            return
        }
        
        self.favorite_place_id.remove(at: index)
        self.favorite_place.remove(at: index)
        
        self.ResultTable.reloadData()
        
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
    
    /* Logic Controller */
    @IBAction func didRequestPrevPage(_ sender: Any) {
        self.current_page -= 1
        
        if current_page == 0 {
            self.PrevButton.isEnabled = false
        }
        
        self.NextButton.isEnabled = true
        self.has_next_page = true
        self.display_content = search_results[current_page]["results"].array!
        self.ResultTable.reloadData()
    }
    
    @IBAction func didRequestNextPage(_ sender: Any) {
        self.current_page += 1
        
        if search_results.count > current_page {
            
            self.display_content = self.search_results[current_page]["results"].array!
            
            self.has_next_page = self.search_results[current_page]["next_page_token"] != JSON.null
            
            self.PrevButton.isEnabled = true
            self.NextButton.isEnabled = self.has_next_page
            
            self.ResultTable.reloadData()
            
        } else {
            SwiftSpinner.show("Loading next page...")
            let next_page_token = search_results[current_page-1]["next_page_token"].string!
            
            let urlString = "http://travelxing-env.us-east-2.elasticbeanstalk.com/page?pageToken=\(next_page_token)"
            
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                
                self.search_result = JSON(data);
                
                self.search_results.append(self.search_result)
                
                self.display_content = self.search_result["results"].array!
                
                self.has_next_page = self.search_result["next_page_token"] != JSON.null
                
                DispatchQueue.main.sync() {
                    // Your code
                    self.PrevButton.isEnabled = true
                    self.NextButton.isEnabled = self.has_next_page
                    
                    self.ResultTable.reloadData()
                    SwiftSpinner.hide()
                }
                
                }.resume()
        }

    }
    

}
