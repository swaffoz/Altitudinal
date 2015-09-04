//
//  UIFont+ApplicationSpecific.swift
//  Altitudinal
//
//  Created by Zane Swafford on 9/3/15.
//  Copyright (c) 2015 Zane Swafford. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func applicationFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Norwester", size: size)!
    }
}