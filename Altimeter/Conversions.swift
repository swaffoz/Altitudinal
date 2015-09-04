//
//  Conversions.swift
//  Altimeter
//
//  Created by Zane Swafford on 8/23/15.
//  Copyright (c) 2015 Zane Swafford. All rights reserved.
//

import Foundation

class Conversions {
    static let FEET_IN_METER = 3.28084
    
    class func feetToMeters(feet: Double) -> Double {
        return feet / FEET_IN_METER
    }
    
    class func metersToFeet(meters: Double) -> Double {
        return meters * FEET_IN_METER
    }
}