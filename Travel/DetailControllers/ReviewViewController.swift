//
//  ReviewViewController.swift
//  Travel
//
//  Created by 李兴 on 4/22/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON
import Cosmos

class ReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var ReviewTableView: UITableView!
    @IBOutlet weak var ReviewSourceSegment: UISegmentedControl!
    @IBOutlet weak var SortBySegment: UISegmentedControl!
    @IBOutlet weak var OrderSegment: UISegmentedControl!
    
    var place: JSON = JSON()
    var google_reviews: [JSON] = [JSON]()
    var yelp_reviews: [JSON] = [JSON]()
    var google_reviews_sorted: [JSON] = [JSON]()
    var yelp_reviews_sorted: [JSON] = [JSON]()
    
    let review_source_options: [String] = ["google", "yelp"]
    let sort_by_options: [String] = ["default", "rating", "date"]
    let order_options: [String] = ["inc", "dec"]
    
    var review_source = "google"
    var sort_by = "default"
    var order = "inc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReviewTableView.delegate = self
        ReviewTableView.dataSource = self
        
        self.google_reviews = place["reviews"].array ?? []
        self.google_reviews_sorted = self.google_reviews
        self.yelp_reviews = place["yelp_reviews"].array ?? []
        self.yelp_reviews_sorted = self.yelp_reviews
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /* Table View */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(review_source == "google") {
            if(self.google_reviews.count == 0) {
                emptyMessage(message: "No Review")
                return 0
            } else {
                ReviewTableView.backgroundView = nil
                ReviewTableView.separatorStyle = .singleLine
                return self.google_reviews_sorted.count
            }
        } else {
            if(self.yelp_reviews.count == 0) {
                emptyMessage(message: "No Review")
                return 0
            } else {
                ReviewTableView.backgroundView = nil
                ReviewTableView.separatorStyle = .singleLine
                return self.yelp_reviews.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell :ReviewTableViewCell! = (ReviewTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)) as! ReviewTableViewCell
        if self.review_source == "google" {
            cell.setGoogleReviewForCell(review: self.google_reviews_sorted[indexPath.row])
        } else {
            cell.setYelpReviewForCell(review: self.yelp_reviews_sorted[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url_str = self.review_source == "google" ? (google_reviews_sorted[indexPath.row]["author_url"].string ?? "") : (yelp_reviews_sorted[indexPath.row]["url"].string ?? "")
        if let url = URL(string: url_str) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func didReviewSourceChanged(_ sender: Any) {
        self.review_source = review_source_options[ReviewSourceSegment.selectedSegmentIndex]
        self.ReviewTableView.reloadData()
    }
    
    @IBAction func didSortByChanged(_ sender: Any) {
        self.sort_by = sort_by_options[SortBySegment.selectedSegmentIndex]
        
        sortReviews()
        self.ReviewTableView.reloadData()
    }
    
    @IBAction func didOrderChanged(_ sender: Any) {
        self.order = order_options[OrderSegment.selectedSegmentIndex]
        
        sortReviews()
        self.ReviewTableView.reloadData()
    }
    
    func sortReviews() {
        switch SortBySegment.selectedSegmentIndex {
        case 0:
            if self.order == "inc" {
                self.google_reviews_sorted = self.google_reviews
                self.yelp_reviews_sorted = self.yelp_reviews
            } else {
                self.google_reviews_sorted = self.google_reviews.reversed()
                self.yelp_reviews_sorted = self.yelp_reviews.reversed()
            }
        case 1:
            if self.order == "inc" {
                self.google_reviews_sorted = self.google_reviews.sorted(by: { $0["rating"].doubleValue < $1["rating"].doubleValue })
                self.yelp_reviews_sorted = self.yelp_reviews.sorted(by: { $0["rating"].doubleValue < $1["rating"].doubleValue })
            } else {
                self.google_reviews_sorted = self.google_reviews.sorted(by: { $0["rating"].doubleValue > $1["rating"].doubleValue })
                self.yelp_reviews_sorted = self.yelp_reviews.sorted(by: { $0["rating"].doubleValue > $1["rating"].doubleValue })
            }
        case 2:
            if self.order == "inc" {
                self.google_reviews_sorted = self.google_reviews.sorted(by: { $0["time"].doubleValue < $1["time"].doubleValue })
                self.yelp_reviews_sorted = self.yelp_reviews.sorted(by: { $0["time_created"].string! < $1["time_created"].string! })
            } else {
                self.google_reviews_sorted = self.google_reviews.sorted(by: { $0["time"].doubleValue > $1["time"].doubleValue })
                self.yelp_reviews_sorted = self.yelp_reviews.sorted(by: { $0["time_created"].string! > $1["time_created"].string! })
            }
        default:
            break
        }
    }
    
    
    
    func emptyMessage(message: String) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.ReviewTableView.bounds.size.width, height: self.ReviewTableView.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
//        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        ReviewTableView.backgroundView = messageLabel;
        ReviewTableView.separatorStyle = .none;
    }
}
