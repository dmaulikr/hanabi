//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Game: NSObject {
    // Each card has a color and a number.
    struct Card {
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
        var numberInt: Int!
        // Each card can be represented by two letters (e.g., "B4," "Y1").
        func string() -> String {
            return "\(color.letterString())\(numberInt)"
        }
    }
    // The draw pile.
    var deckCardArray: [Card] = []
    var numberOfPlayersInt: Int = 2
    // Number for srandom(). Determines card order.
//    var seedInt: Int
    // Make deck. Shuffle. Deal hands.
    init(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        super.init()
        self.numberOfPlayersInt = numberOfPlayersInt
        deckCardArray = makeADeck()
        // don't need to store seed yet
        // could make the seed an inout var; wait until I figure out where/how to user wants to know seed
        shuffleDeck(&deckCardArray, seedOptionalUInt32: seedOptionalUInt32)
        // debugging
        printDeck(deckCardArray)
        //
        // deal starting hands
        
    }
    // Return an unshuffled deck.
    func makeADeck() -> [Card] {
        var cardArray: [Card] = []
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
        return cardArray
    }
    // User/coder can see cards in deck.
    func printDeck(deckCardArray: [Card]) {
        print("Deck:")
        for card in deckCardArray {
            print(" \(card.string())")
        }
        print("\n")
    }
    // Deck is randomized in a reproducible order.
    func shuffleDeck(inout deckCardArray: [Card], seedOptionalUInt32: UInt32?) {
        // Shuffle deck: Pull a random card and put in new deck. Repeat.
        // If no seed, choose a random one.
        var seedUInt32: UInt32
        if seedOptionalUInt32 == nil {
            seedUInt32 = arc4random()
        } else {
            seedUInt32 = seedOptionalUInt32!
        }
        println("Seed: \(seedUInt32)")
        srandom(seedUInt32)
        var tempCardArray: [Card] = []
        // Number of cards in deck will decrease each time.
        for pullTurnInt in 1...deckCardArray.count {
            let indexInt = random() % deckCardArray.count
            let card = deckCardArray.removeAtIndex(indexInt)
            tempCardArray.append(card)
        }
        deckCardArray = tempCardArray
    }
}
