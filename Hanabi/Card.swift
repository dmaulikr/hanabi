//
//  Card.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import Foundation

// Each card has a color and a number.
class Card: NSObject {
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
    // Whether given card is in given array, value-wise.
    class func cardValueIsInArrayBool(card: Card, cardArray: [Card]) -> Bool {
        for card2 in cardArray {
            if card2.isEqualColorAndNumber(card) {
                return true
            }
        }
        return false
    }
    // Index of the given card in the given array, value-wise. Returns first match.
    class func indexOptionalIntOfCardValueInArray(card: Card, cardArray: [Card]) -> Int? {
        for indexInt in 0...(cardArray.count - 1) {
            let card2 = cardArray[indexInt]
            if card2.isEqualColorAndNumber(card) {
                return indexInt
            }
        }
        return nil
    }
    // String showing cards in the given array.
    class func stringForArray(cardArray: [Card]) -> String {
        var string = ""
        if !cardArray.isEmpty {
            for index in 0...(cardArray.count - 1) {
                let cardString = cardArray[index].string
                if index == 0 {
                    string += "\(cardString)"
                } else {
                    string += " \(cardString)"
                }
            }
        }
        return string
    }
    var color: Color
    // The card next in sequence. (Max value is 5.)
    var nextValueOptionalCard: Card? {
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
    init(color: Color, numberInt: Int) {
        self.color = color
        self.numberInt = numberInt
    }
    // To tell duplicate cards, vs cards with the same reference.
    func isEqualColorAndNumber(card: Card) -> Bool {
        return (card.color == self.color) && (card.numberInt == self.numberInt)
    }
}