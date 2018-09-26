//
//  InfoViewController.swift
//  Travel
//
//  Created by 李兴 on 4/22/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON
import Cosmos

class InfoViewController: UIViewController {

    var place: JSON = JSON()
    
    
    @IBOutlet weak var address_label: UILabel!
    @IBOutlet weak var phone_number_field: UITextView!
    @IBOutlet weak var price_level_label: UILabel!
    @IBOutlet weak var rating_view: CosmosView!
    @IBOutlet weak var website_field: UITextView!
    @IBOutlet weak var google_page_field: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        address_label.text = place["formatted_address"].string ?? "N/A"
        phone_number_field.text = place["international_phone_number"].string ?? "N/A"
        price_level_label.text = generatePriceLevel(price_level: place["price_level"].int)
        rating_view.rating = place["rating"].doubleValue
        website_field.text = place["website"].string ?? "N/A"
        google_page_field.text = place["url"].string ?? "N/A"
        
        // Do any additional setup after loading the view.
    }
    
    

    func generatePriceLevel(price_level: Int?) -> String {
        if let p = price_level {
            var price_level_str = ""
            for _ in 1 ... p {
                price_level_str += "$"
            }
            return price_level_str
        } else {
            return "N/A"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
