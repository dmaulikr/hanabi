//
//  Game.swift
//  Hanabi
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
    var numberOfPlayersInt: Int
    // Number for srandom(). Determines card order.
    var seedInt: Int
    // Make deck. Shuffle. Deal hands.
    init(seedOptionalInt: Int?, numberOfPlayersInt: Int) {
        // If no seed given, choose a random one.
        if let theSeedInt = seedOptionalInt {
            seedInt = theSeedInt
        } else {
            seedInt = random()
        }
        self.numberOfPlayersInt = numberOfPlayersInt
        super.init()
        // change to deckCardArray = makeDeck()
        makeDeck()
        shuffleDeck()
        // just log deck to check
        // change to printDeck(deckCardArray)
        printDeck()
        //
        // deal starting hands
        
    }
    // Make an unshuffled deck.
    func makeDeck() {
        // For each color, add 3/2/2/2/1.
        deckCardArray = []
        var aCard: Card
        for anInt in 1...5 {
            if let anOptionalColor = Card.Color.fromRaw(anInt) {
                for _ in 1...3 {
                    aCard = Card(color: anOptionalColor, numberInt: 1)
                    deckCardArray.append(aCard)
                }
                for _ in 1...2 {
                    aCard = Card(color: anOptionalColor, numberInt: 2)
                    deckCardArray.append(aCard)
                    aCard = Card(color: anOptionalColor, numberInt: 3)
                    deckCardArray.append(aCard)
                    aCard = Card(color: anOptionalColor, numberInt: 4)
                    deckCardArray.append(aCard)
                }
                aCard = Card(color: anOptionalColor, numberInt: 5)
                deckCardArray.append(aCard)
            }
        }
    }
    // User/coder can see cards in deck.
    func printDeck() {
        print("Deck:")
        for aCard in deckCardArray {
            print(" \(aCard.string())")
        }
        print("\n")
    }
    // Deck is randomized in a reproducible order.
    func shuffleDeck() {
        // how does one shuffle a deck via code; this is probably on google
        println("shuffle deck now")
        // pull randomly to form a new deck
        // remember want pseudo-random (reproducible)
        
    }
}
