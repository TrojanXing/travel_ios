//
//  SinglePlaceViewDelegate.swift
//  Travel
//
//  Created by 李兴 on 4/22/18.
//  Copyright © 2018 Xing. All rights reserved.
//
import SwiftyJSON

protocol SinglePlaceViewDelegate {
    func addFavorite(place: JSON!)
}
