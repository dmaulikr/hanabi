//
//  Utilities.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/13/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import Foundation
    
// Round value to the given number of decimal places.
// works better with Double than Float?
func round(value: Double, #numberOfDecimalsInt: Int) -> Double {
    let powerOfTenInt = pow(10, Double(numberOfDecimalsInt))
    let roundedValue = round(value * powerOfTenInt) / powerOfTenInt
    return roundedValue
}
