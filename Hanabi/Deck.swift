//
//  Deck.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/13/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Deck: NSObject {
    var cardArray: [Card] = []
    var isEmpty: Bool {
        return cardArray.isEmpty
    }
    var numberOfCardsLeftInt: Int {
        return cardArray.count
    }
    // Number for srandom(). Determines card order.
    var seedUInt32: UInt32!
    // String showing cards in deck.
    var string: String {
        return Card.stringForArray(cardArray)
    }
    override func copy() -> AnyObject! {
        var deck = Deck()
        deck.cardArray = cardArray
        deck.seedUInt32 = seedUInt32
        return deck
    }
    // Take top card from the deck and return it. Assumes not empty.
    func drawCard() -> Card {
        let card = cardArray.removeAtIndex(0)
        return card
    }
    // Take top N cards and return them. Assumes won't be empty.
    func drawCards(numberInt: Int) -> [Card] {
        var tempCardArray: [Card] = []
        for _ in 1...numberInt {
            tempCardArray.append(drawCard())
        }
        return tempCardArray
    }
    // Unshuffled deck.
    override init() {
        super.init()
        // For each color, add 3/2/2/2/1 of 1/2/3/4/5.
        var card: Card
        for int in 1...5 {
            if let color = Card.Color.fromRaw(int) {
                for _ in 1...3 {
                    card = Card(color: color, numberInt: 1)
                    cardArray.append(card)
                }
                for _ in 1...2 {
                    card = Card(color: color, numberInt: 2)
                    cardArray.append(card)
                    card = Card(color: color, numberInt: 3)
                    cardArray.append(card)
                    card = Card(color: color, numberInt: 4)
                    cardArray.append(card)
                }
                card = Card(color: color, numberInt: 5)
                cardArray.append(card)
            }
        }
    }
    // Shuffle deck. A seed is used to shuffle reproducibly. If no seed, use a random one.
    func shuffleWithSeed(seedOptionalUInt32: UInt32?) {
        if seedOptionalUInt32 == nil {
            seedUInt32 = arc4random()
        } else {
            seedUInt32 = seedOptionalUInt32!
        }
        // Shuffle: Pull a random card and put in new array. Repeat.
        srandom(seedUInt32)
        var tempCardArray: [Card] = []
        // Number of cards in deck will decrease each time.
        for pullTurnInt in 1...cardArray.count {
            let indexInt = random() % cardArray.count
            let card = cardArray.removeAtIndex(indexInt)
            tempCardArray.append(card)
        }
        cardArray = tempCardArray
    }
}
