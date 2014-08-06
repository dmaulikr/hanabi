//
//  SolverElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/5/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

protocol SolverElfDelegate {
    func solverElfDidChangeMode()
}

private var myContext = 0

class SolverElf: NSObject {
    struct Card {
        var color: Color
        var numberInt: Int!
    }
    // Card colors.
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
    enum Mode: Int {
        case Planning, Solving, Solved
    }
    // Ordered set of Hanabi cards.
    // so this is an array of Hanabi cards; can be empty
    var deckCardArray: [Card] = []
    var delegate: SolverElfDelegate? = nil
    var mode: Mode = Mode.Planning {
    didSet {
        if self.mode != oldValue {
            self.delegate?.solverElfDidChangeMode()
        }
    }
    }
    var numberOfGamesPlayedInt = 0
    var numberOfGamesToPlayInt = 1
    var numberOfGamesWonInt = 0
    var numberOfSecondsSpentFloat = 0.0
    // Number for srandom().
    var seedNumberOptionalInt: Int? = nil
    override init() {
        super.init()
    }
    // Make a starting deck, in order.
    func makeDeck() {
        // For each color, add 3/2/2/2/1.
        self.deckCardArray = []
        var aCard: Card
        for anInt in 1...5 {
            if let anOptionalColor = Color.fromRaw(anInt) {
                for _ in 1...3 {
                    aCard = Card(color: anOptionalColor, numberInt: 1)
                    self.deckCardArray.append(aCard)
                }
                for _ in 1...2 {
                    aCard = Card(color: anOptionalColor, numberInt: 2)
                    self.deckCardArray.append(aCard)
                }
                for _ in 1...2 {
                    aCard = Card(color: anOptionalColor, numberInt: 3)
                    self.deckCardArray.append(aCard)
                }
                for _ in 1...2 {
                    aCard = Card(color: anOptionalColor, numberInt: 4)
                    self.deckCardArray.append(aCard)
                }
                aCard = Card(color: anOptionalColor, numberInt: 5)
                self.deckCardArray.append(aCard)
            }
        }
    }
    // Print cards, in order, to the console.
    func printDeck() {
        print("Deck:")
        for aCard in self.deckCardArray {
            print(" \(aCard.color.letterString())\(aCard.numberInt)")
        }
        print("\n")
    }
    // User sees results of solving.
    func showResults() {
        println("Games: \(self.numberOfGamesPlayedInt)")
        println("Games won: \(self.numberOfGamesWonInt)")
        println("Time spent: \(self.numberOfSecondsSpentFloat) seconds")
    }
    // Pseudo-randomly shuffle the deck.
    func shuffleDeck() {
        // how does one shuffle a deck via code; this is probably on google
        // probably have an array of cards
        self.makeDeck()
        println("shuffle deck now")
        // pull randomly to form a new deck
        // remember want pseudo-random (reproducible)
        // just log deck to check
        self.printDeck()
    }
    // Solve a random game.
    func solveAGame() {
        self.shuffleDeck()
    }
    func solveGames() {
        self.mode = Mode.Solving
        self.numberOfSecondsSpentFloat = 0.0
        // start timer
        self.numberOfGamesPlayedInt = 0
        self.numberOfGamesWonInt = 0
        // Solve one at a time.
        for var gameNumber = 1; gameNumber <= self.numberOfGamesToPlayInt; ++gameNumber {
//            println("Playing game \(gameNumber)")
//            self.shuffleDeck()
//            self.dealHands()
//            self.playToEnd()
//            self.scoreGame()
            self.numberOfGamesPlayedInt++
//            self.saveResults()
        }
        // end timer
//        self.numberOfSecondsSpentFloat = ??
        self.showResults()
        self.mode = Mode.Planning
    }
    func stopSolving() {
        self.mode = Mode.Planning
    }
}
