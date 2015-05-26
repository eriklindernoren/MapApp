//
//  BottomInfo.swift
//  MapApp
//
//  Created by Erik Linder-Norén on 2014-12-26.
//  Copyright (c) 2014 Mina Appar. All rights reserved.
//

import UIKit

class BottomInfo: UIView {

    @IBOutlet var address:UILabel!
    @IBOutlet var city:UILabel!
    @IBOutlet var country:UILabel!

    @IBOutlet var temp:UILabel!
    @IBOutlet var wind:UILabel!
    
    @IBOutlet var date:UILabel!
    
    @IBOutlet var coordinates:UILabel!
    
    @IBOutlet var weatherImg:UIImageView!
    
    func setUpLook(){
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 1
    }
    
    func clearInfo(){
        address.text = nil
        city.text = nil
        country.text = nil
        temp.text = nil
        wind.text = nil
        date.text = nil
        coordinates.text = nil
        weatherImg.image = nil
    }

}
