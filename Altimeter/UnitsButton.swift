//
//  UnitsButton.swift
//  Altimeter
//
//  Created by Zane Swafford on 8/24/15.
//  Copyright (c) 2015 Zane Swafford. All rights reserved.
//

import UIKit

class UnitsButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0.0, 2, self.frame.height);
        bottomBorder.backgroundColor = UIColor.applicationLightGrayColor().CGColor
        self.layer.addSublayer(bottomBorder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, 0.0, 2, self.frame.height);
        bottomBorder.backgroundColor = UIColor(white: 0.8, alpha: 1).CGColor
        self.layer.addSublayer(bottomBorder)
    }
}
