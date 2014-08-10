//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Game: NSObject {
    // Start of game is turn 1. At end of game, there's no current turn.
    var currentOptionalTurn: Turn?
    // The draw pile.
//    var deckCardArray: [Card] = []
//    var numberOfPlayersInt: Int = 2
    // Number for srandom(). Determines card order.
    var seedUInt32: UInt32
    var turnArray: [Turn] = []
    // Return the number of the current turn.
    func currentTurnNumberOptionalInt() -> Int? {
        if let turn = currentOptionalTurn {
            let optionalIndex = find(turnArray, turn)
            if let index = optionalIndex {
                return index + 1
            }
        }
        return nil
    }
    // Deal starting hands to the given players.
    func dealHandsFromDeck(inout deckCardArray: [Card], inout playerArray: [Player]) {
        // In reality, we'd deal a card to a player at a time, because the cards may not be well-shuffled. Here, we'll deal each player completely. This makes games with the same deck but different numbers of players more comparable.
        let numberOfPlayersInt = playerArray.count
        var numberOfCardsPerPlayerInt: Int
        switch numberOfPlayersInt {
        case 2, 3:
            numberOfCardsPerPlayerInt = 5
        case 4, 5:
            numberOfCardsPerPlayerInt = 4
        default:
            numberOfCardsPerPlayerInt = 5
        }
        for playerNumberInt in 1...numberOfPlayersInt {
            let player = playerArray[playerNumberInt - 1]
            for int2 in 1...numberOfCardsPerPlayerInt {
                // Pulling last card of deck because it should be easier/faster.
                let card = deckCardArray.removeLast()
                player.handCardArray.append(card)
            }
        }
    }
    // Sum of score for each color.
    func finalScore() -> Int {
        if let scoreInt = turnArray.last?.endingOptionalGameState?.totalScore() {
            scoreInt
        }
        var scoreInt = 0
        if let scoreDictionary = turnArray.last?.endingOptionalGameState?.scoreDictionary {
            // go through each color/item, sum stuff
            for (color, score) in scoreDictionary {
                scoreInt += score
            }
        }
        return scoreInt
    }
    // Do the current action. Make next turn or end game.
    func finishCurrentTurn() {
        if let turn = currentOptionalTurn {
            turn.performAction()
            if isDone() {
                currentOptionalTurn = nil
            } else {
                // Make next turn. Use previous turn, then change current player.
                if let gameState = turn.endingOptionalGameState?.copy() as? GameState {
                    gameState.moveToNextPlayer()
                    let nextTurn = Turn(gameState: gameState)
                    turnArray.append(nextTurn)
                    currentOptionalTurn = nextTurn
                }
            }
        }
    }
    // Make deck. Shuffle. Deal hands.
    init(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        // If no seed, use random.
        if seedOptionalUInt32 == nil {
            seedUInt32 = arc4random()
        } else {
            seedUInt32 = seedOptionalUInt32!
        }
        super.init()
//        self.numberOfPlayersInt = numberOfPlayersInt
        var deckCardArray = makeADeck()
        shuffleDeck(&deckCardArray, seedUInt32: seedUInt32)
        // debugging
        printDeck(deckCardArray)
        var playerArray: [Player] = []
        for _ in 1...numberOfPlayersInt {
            playerArray.append(Player())
        }
        dealHandsFromDeck(&deckCardArray, playerArray: &playerArray)
        let gameState = GameState()
        gameState.playerArray = playerArray
        gameState.deckCardArray = deckCardArray
        let turn = Turn(gameState: gameState)
        turnArray.append(turn)
        currentOptionalTurn = turn
    }
    // Return whether the game has ended (not necessarily won).
    func isDone() -> Bool {
        if let endingGameState = turnArray.last?.endingOptionalGameState {
            if endingGameState.isDone() {
                return true
            }
        }
        // Safety check to prevent infinite loop.
        if turnArray.count > 99 {
            println("Warning: > 99 turns.")
            return true
        }
        return false
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
    // Return the number of players in the game.
    func numberOfPlayersInt() -> Int {
        if let gameState = turnArray.first?.startingGameState {
            return gameState.playerArray.count
        }
        return 0
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
    func shuffleDeck(inout deckCardArray: [Card], seedUInt32: UInt32) {
        // Shuffle deck: Pull a random card and put in new deck. Repeat.
//        println("Seed: \(seedUInt32)")
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
    // Return whether the game had a winning score.
    func wasWon() -> Bool {
        if finalScore() == 25 {
            return true
        } else {
            return false
        }
    }
}
