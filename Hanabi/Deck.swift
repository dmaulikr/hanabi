//
//  Deck.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/13/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Deck: NSObject {
    var cards: [Card] = []
    var isEmpty: Bool {
        return cards.isEmpty
    }
    var numCardsLeft: Int {
        return cards.count
    }
    // Number for srandom(). Determines card order.
    var seedUInt32: UInt32!
    // String showing cards in deck.
    var string: String {
        return Card.stringForArray(cards)
    }
    override func copy() -> AnyObject {
        var deck = Deck()
        deck.cards = cards
        deck.seedUInt32 = seedUInt32
        return deck
    }
    // Take top card from the deck and return it. Assumes not empty.
    func drawCard() -> Card {
        let card = cards.removeAtIndex(0)
        card.optionalCardBack = CardBack()
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
                    card = Card(color: color, num: 1)
                    cards.append(card)
                }
                for _ in 1...2 {
                    card = Card(color: color, num: 2)
                    cards.append(card)
                    card = Card(color: color, num: 3)
                    cards.append(card)
                    card = Card(color: color, num: 4)
                    cards.append(card)
                }
                card = Card(color: color, num: 5)
                cards.append(card)
            }
        }
    }
    // Shuffle deck. A seed is used to shuffle reproducibly. If no seed, use a random one.
    func shuffleWithSeed(seedOptionalUInt32: UInt32?) {
        if seedOptionalUInt32 == nil {
            // Want seed that fits in Int so we can use string.toInt() elsewhere.
            seedUInt32 = arc4random_uniform(UInt32(Int32.max))
        } else {
            seedUInt32 = seedOptionalUInt32!
        }
        // Shuffle: Pull a random card and put in new array. Repeat.
//        println("Seed: \(seedUInt32)")
        srandom(seedUInt32)
        var tempCardArray: [Card] = []
        // Number of cards in deck will decrease each time.
        for pullTurnInt in 1...cards.count {
            let indexInt = random() % cards.count
            let card = cards.removeAtIndex(indexInt)
            tempCardArray.append(card)
        }
        cards = tempCardArray
    }
}
