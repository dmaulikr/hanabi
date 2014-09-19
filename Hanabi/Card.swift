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
    // deprecate; use card.isInArray()
//    class func cardValueIsInArrayBool(card: Card, cardArray: [Card]) -> Bool {
//        for card2 in cardArray {
//            if card2.isEqualColorAndNumber(card) {
//                return true
//            }
//        }
//        return false
//    }
    // The color for the given int. If invalid, return nil.
    class func color(#int: Int) -> Color? {
        return Color.fromRaw(int)
    }
    // Index of the given card in the given array, value-wise. Returns first match.
//    class func indexOptionalIntOfCardValueInArray(card: Card, cardArray: [Card]) -> Int? {
//        for indexInt in 0...(cardArray.count - 1) {
//            let card2 = cardArray[indexInt]
//            if card2.isEqualColorAndNumber(card) {
//                return indexInt
//            }
//        }
//        return nil
//    }
    // Lowest of given cards.
    class func lowest(cards: [Card]) -> [Card] {
        var lowestCards: [Card] = []
        var min = 6
        for card in cards {
            let num = card.num
            if num < min {
                min = num
                lowestCards = [card]
            } else if num == min {
                lowestCards.append(card)
            }
        }
        return lowestCards
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
    var next: Card? {
        var card: Card?
        if num < 5 {
            card = Card(color: color, num: num + 1)
        }
        return card
    }
    var num: Int!
    var optionalCardBack: CardBack?
    // String representing card (e.g., "B4," "Y1").
    var string: String {
        return "\(color.letterString())\(num)"
    }
    // Previous card in sequence. (Min value is 1.)
    var previous: Card? {
        var card: Card?
        if num > 1 {
            card = Card(color: color, num: num - 1)
        }
        return card
    }
    init(color: Color, num: Int) {
        self.color = color
        self.num = num
        super.init()
    }
    // Index of this card in given cards. Check by value. If not found, return nil.
    func indexIn(cards: [Card]) -> Int? {
        for index in 0...(cards.count - 1) {
            let card = cards[index]
            if self.isSameAs(card) {
                return index
            }
        }
        return nil
    }
    // Whether this card is in given cards. Check by value.
    func isIn(cards: [Card]) -> Bool {
        for card in cards {
            if self.isSameAs(card) {
                return true
            }
        }
        return false
    }
    // Whether this card is same, by value, as given card. I.e., same color and number.
    func isSameAs(card: Card) -> Bool {
        return (card.color == self.color) && (card.num == self.num)
    }
    // Whether this card is in given cards at least twice. Check by value.
    func isTwiceIn(cards: [Card]) -> Bool {
        var count = 0
        for card in cards {
            if self.isSameAs(card) {
                ++count
            }
        }
        return count >= 2
    }
}