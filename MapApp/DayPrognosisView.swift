//
//  DayPrognosisView.swift
//  MapApp
//
//  Created by Erik Linder-Norén on 2014-12-30.
//  Copyright (c) 2014 Mina Appar. All rights reserved.
//

import UIKit

class DayPrognosisView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var image: UIImageView!
    @IBOutlet var date: UILabel!
    @IBOutlet var temp: UILabel!
    
    override func awakeFromNib() {
        NSBundle.mainBundle().loadNibNamed("DayPrognosisView", owner: self, options: nil)
        self.addSubview(contentView)
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 0.5
        self.clipsToBounds = true
    }

}
