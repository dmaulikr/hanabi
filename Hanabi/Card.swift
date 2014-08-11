//
//  Card.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import Foundation

// For Hashable protocol.
func ==(card1: Card, card2: Card) -> Bool {
    println("card == card1: \(card1.string()) card2: \(card2.string())")
    if (card1.color == card2.color) && (card1.numberInt == card2.numberInt) {
        return true
    } else {
        return false
    }
}

// Each card has a color and a number.
struct Card: Hashable {
    enum Color: Int {
        case Blue = 1, Green, Red, White, Yellow
        func letterString() -> String {
            var aLetterString: String
            switch self {
            case Blue:
                aLetterString = "B"
            case Green:
                aLetterString = "G"
            case Red:
                aLetterString = "R"
            case White:
                aLetterString = "W"
            case Yellow:
                aLetterString = "Y"
            default:
                aLetterString = "M"
            }
            return aLetterString
        }
    }
    var color: Color
    // For Hashable protocol.
    var hashValue: Int {
        get {
            return color.toRaw() * 10 + numberInt
        }
    }
    var numberInt: Int!
    // Return the card next in sequence. (Max value is 5.)
    func nextValueCard() -> Card? {
        var optionalCard: Card?
        if numberInt <= 5 {
            optionalCard = Card(color: color, numberInt: numberInt + 1)
        }
        return optionalCard
    }
    // Each card can be represented by two letters (e.g., "B4," "Y1").
    func string() -> String {
        return "\(color.letterString())\(numberInt)"
    }
}