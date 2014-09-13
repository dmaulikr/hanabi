//
//  ScorePile.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/26/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//
// Cards that have been scored. Only the value on top of each color (i.e., highest) counts. Total score is the sum.
import Foundation
class ScorePile {
    // Current score = sum for each color.
    var currentInt: Int {
        var currentInt = 0
            for (color, score) in topDictionary {
                currentInt += score
            }
            return currentInt
    }
    // String showing the score for each color, in order.
    var string: String {
        // Score is kept in a dictionary, which does not guarantee order. We'll put each color's score in an array, then join the elements.
        var stringArray = [String](count: 5, repeatedValue: "")
            for (color, score) in topDictionary {
                switch color {
                case .Blue:
                    stringArray[0] = String(score)
                case .Green:
                    stringArray[1] = String(score)
                case .Red:
                    stringArray[2] = String(score)
                case .White:
                    stringArray[3] = String(score)
                case .Yellow:
                    stringArray[4] = String(score)
                }
            }
            let scoreString = "".join(stringArray)
            return scoreString
    }
    // The value on top of each color pile.
    var topDictionary: [Card.Color: Int] = [:]
    // Add given card to score pile. Assume playable.
    func addCard(card: Card) {
        topDictionary[card.color] = card.num
    }
    // Whether given card is a valid play.
    func canScore(card: Card) -> Bool {
        // It's playable if the card's number is 1 more than its color's current score.
        let currentValue = topDictionary[card.color]
        return card.num == currentValue! + 1
    }
    // Whether player knows the given card back is playable.
    func cardBackIsKnownPlayableBool(cardBack: CardBack) -> Bool {
        // If all remaining options are playable, card is playable.
        for card in cardBack.optionsCardArray {
            if !canScore(card) {
                return false
            }
        }
        return true
    }
    func copy() -> ScorePile {
        var scorePile = ScorePile()
        scorePile.topDictionary = topDictionary
        return scorePile
    }
    // Whether given card has been scored.
    func has(card: Card) -> Bool {
        let colorScore = topDictionary[card.color]!
        return card.num <= colorScore
    }
    init() {
        // Start with 0 cards scored.
        var int = 1
        while let color = Card.Color.fromRaw(int) {
            topDictionary[color] = 0
            int++
        }
    }
    // The highest-scored value for the given color.
    func value(#color: Card.Color) -> Int {
        return topDictionary[color]!
    }
}
