//
//  Utilities.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/13/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import Foundation

// For round() to accept a Float or Double.
protocol FloatingPoint {}
extension Double: FloatingPoint {}
extension Float: FloatingPoint {}

// The average value of X in the given Ys. If no Ys, return 0. Note that the closure must return an Int. E.g., { $0.score }
func avgXInYs<T>(#ys: [T], #xInY: (y: T) -> Int) -> Float {
    // Get Xs. Sum. Average.
    let listOfXInEachY = ys.map(xInY)
    let totalXInYs = listOfXInEachY.reduce(0, +)
    let numYs = ys.count
    if numYs == 0 {
        return 0
    } else {
        return Float(totalXInYs) / Float(numYs)
    }
}
// Round value to the given number of decimal places. Seems to work better returning Double than Float.
func round(value: FloatingPoint, #decimals: Int) -> Double {
    let powerOfTen = pow(10, Double(decimals))
    var valueDouble: Double
    if value is Float {
        valueDouble = Double(value as Float)
    } else {
        valueDouble = value as Double
    }
    let roundedValue = round(valueDouble * powerOfTen) / powerOfTen
    return roundedValue
}
// String for the round and subround for the given turn and number of players. (E.g., in a 3-player game, turn 4 = round "2.1.")
func roundSubroundStringForTurn(turnNumberInt: Int, #numberOfPlayersInt: Int) -> String {
    // 3 players: turns 1, 2, 3, 4 = rounds 1, 1, 1, 2
    let roundInt = (turnNumberInt + 2) / numberOfPlayersInt
    // 3 players: turns 1, 2, 3, 4 = subrounds 1, 2, 3, 1
    let subroundInt = ((turnNumberInt + 2) % numberOfPlayersInt) + 1
    let string = "\(roundInt).\(subroundInt)"
    return string
}
// Round each element of given array to given number of decimals.
func roundTheValues(rawValues: [Float], #decimals: Int) -> [Double] {
    return rawValues.map( { round($0, decimals: decimals) } )
}

