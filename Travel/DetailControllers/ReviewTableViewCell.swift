//
//  ReviewTableViewCell.swift
//  Travel
//
//  Created by 李兴 on 4/23/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var RatingView: CosmosView!
    @IBOutlet weak var CreateAtLabel: UILabel!
    @IBOutlet weak var ReviewContentView: UITextView!
    
    func setGoogleReviewForCell(review: JSON) {
        
        if let image_url = review["profile_photo_url"].string {
            let url = URL(string: image_url)
            let data = try? Data(contentsOf: url!)
            self.ProfileImageView?.image = UIImage(data: data!)
        }
        self.UsernameLabel?.text = review["author_name"].string
        self.RatingView.rating = review["rating"].doubleValue
        self.CreateAtLabel?.text =  formatGoogleTime(time: review["time"].double)
        self.ReviewContentView.text = review["text"].string
    }
    
    func setYelpReviewForCell(review: JSON) {
        
        if let image_url = review["user"]["image_url"].string {
            let url = URL(string: image_url)
            let data = try? Data(contentsOf: url!)
            self.ProfileImageView?.image = UIImage(data: data!)
        }
        self.UsernameLabel?.text = review["user"]["name"].string
        self.RatingView.rating = review["rating"].double ?? 0
        self.CreateAtLabel?.text = review["time_created"].string
        self.ReviewContentView.text = review["text"].string
    }
    
    func formatGoogleTime(time: Double?) -> String {
        if let t = time {
            let date: NSDate! = NSDate(timeIntervalSince1970: t)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
            
            return dateFormatter.string(from: date as Date)
        } else {
            return "Time not provided"
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
