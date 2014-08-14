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
        return color.toRaw() * 10 + numberInt
    }
    // The card next in sequence. (Max value is 5.)
    var nextValueCard: Card? {
        var optionalCard: Card?
        if numberInt <= 5 {
            optionalCard = Card(color: color, numberInt: numberInt + 1)
        }
        return optionalCard
    }
    var numberInt: Int!
    // String representing card (e.g., "B4," "Y1").
    var string: String {
        return "\(color.letterString())\(numberInt)"
    }
    // String showing cards in the given array.
    static func stringForArray(cardArray: [Card]) -> String {
        var string = ""
        for index in 0...cardArray.count {
            let cardString = cardArray[index].string
            if index == 0 {
                string += "\(cardString)"
            } else {
                string += " \(cardString)"
            }
        }
        return string
    }
}