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
// String for the round and subround for the given turn and number of players. (E.g., in a 3-player game, turn 4 = round "2.1.")
func roundSubroundStringForTurn(turnNumberInt: Int, #numberOfPlayersInt: Int) -> String {
    // 3 players: turns 1, 2, 3, 4 = rounds 1, 1, 1, 2
    let roundInt = (turnNumberInt + 2) / numberOfPlayersInt
    // 3 players: turns 1, 2, 3, 4 = subrounds 1, 2, 3, 1
    let subroundInt = ((turnNumberInt + 2) % numberOfPlayersInt) + 1
    let string = "\(roundInt).\(subroundInt)"
    return string
}
