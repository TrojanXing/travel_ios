//
//  SinglePlace.swift
//  Travel
//
//  Created by 李兴 on 4/21/18.
//  Copyright © 2018 Xing. All rights reserved.
//

import UIKit
import SwiftyJSON

class SinglePlaceView: UITableViewCell {
    
    @IBOutlet weak var FavoriteButton: UIButton!
    @IBOutlet weak var IconView: UIImageView!
    @IBOutlet weak var VicinityView: UILabel!
    @IBOutlet weak var NameView: UILabel!
    
    var place: JSON = JSON()
    
    var delegate: SinglePlaceViewDelegate!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setValueForCell(place: JSON) {
        self.place = place
        
        let url = URL(string: place["icon"].string!)
        let data = try? Data(contentsOf: url!)
        self.IconView?.image = UIImage(data: data!)
        self.NameView?.text = place["name"].string
        self.VicinityView?.text = place["vicinity"].string
    }
    
    func setFavoriteIcon(image: UIImage) {
        self.FavoriteButton.setImage(image, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /* Logic Controller */
    @IBAction func addFavorite(_ sender: Any) {
        
        delegate.addFavorite(place: place)
    }
    
}
