//
//  Utilities.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/13/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import Foundation
    
// Round value to the given number of decimal places.
// Thanks to post: http://stackoverflow.com/questions/24791734/cgfloat-call-rintf-when-float-and-rint-when-double/24792640#24792640
// Couldn't figure out better way.
func round<T: FloatingPointType>(value: T, #numberOfDecimalsInt: Int) -> T {
    switch value {
    case let value as Float:
        let powerOfTenInt = pow(10, Float(numberOfDecimalsInt))
        let roundedValue = round(value * powerOfTenInt) / powerOfTenInt
        return roundedValue as T
    case let value as Double:
        let powerOfTenInt = pow(10, Double(numberOfDecimalsInt))
        let roundedValue = round(value * powerOfTenInt) / powerOfTenInt
        return roundedValue as T
    default:
        return 0.0 as T
    }
}
