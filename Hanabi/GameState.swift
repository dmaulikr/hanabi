//
//  GameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class GameState: NSObject {
    var currentPlayerNumberInt = 1
    var deckCardArray: [Card] = []
    var discardsCardArray: [Card] = []
    var numberOfCluesLeftInt = 8
    var numberOfStrikesLeftInt = 3
    // Number of turns played after the deck became empty. To determine game end.
    var numberOfTurnsPlayedWithEmptyDeckInt = 0
    var playerArray: [Player] = []
    // The score is a number associated with each color. Total score is the sum.
    var scoreDictionary: [Card.Color: Int] = [:]
    override func copy() -> AnyObject! {
        var gameState = GameState()
        gameState.currentPlayerNumberInt = currentPlayerNumberInt
        gameState.deckCardArray = deckCardArray
        gameState.discardsCardArray = discardsCardArray
        gameState.numberOfCluesLeftInt = numberOfCluesLeftInt
        gameState.numberOfStrikesLeftInt = numberOfStrikesLeftInt
        gameState.numberOfTurnsPlayedWithEmptyDeckInt = numberOfTurnsPlayedWithEmptyDeckInt
        // Deep copy.
        for player in playerArray {
            gameState.playerArray.append(player.copy() as Player)
        }
        gameState.scoreDictionary = scoreDictionary
        return gameState
    }
    override init() {
        // Initialize score.
        for int in 1...5 {
            if let color = Card.Color.fromRaw(int) {
                scoreDictionary[color] = 0
            }
        }
        super.init()
    }
    // Return whether the game has ended (not necessarily won).
    func isDone() -> Bool {
        // Game ends if score maxed, if out of strikes or if out of turns. The last case: when the deck is empty, each player gets one more turn.
        if totalScore() == 25 || numberOfStrikesLeftInt == 0 {
            return true
        }
        if deckCardArray.isEmpty && numberOfTurnsPlayedWithEmptyDeckInt == playerArray.count {
            return true
        }
        return false
    }
    // Change current player to next player. Rotates in a clockwise circle.
    func moveToNextPlayer() {
        currentPlayerNumberInt++
        if currentPlayerNumberInt > playerArray.count {
            currentPlayerNumberInt = 1
        }
    }
    func performAction(action: Action) {
        // If deck already empty, then note turn.
        if deckCardArray.isEmpty {
            numberOfTurnsPlayedWithEmptyDeckInt++
        }
        switch action.type {
        case .Clue:
            println("give a clue")
            // If clues not left, trigger an assertion. (AI shouldn't have chosen this, and player shouldn't have been able to.)
            assert(numberOfCluesLeftInt > 0, "Error: tried to give clue with 0 clue tokens.")
            numberOfCluesLeftInt--
        case .Play:
            println("play a card")
            // remove card from hand
            // if valid, increase score
            // else, remove strike and put in discard
            // player draws new card
        case .Discard:
            // If clues not less than max, trigger an assertion. (AI shouldn't have chosen this, and player shouldn't have been able to.)
            assert(numberOfCluesLeftInt < 8, "Error: tried to discard with max clue tokens.")
            // Remove card from hand. Put in discard pile. Gain clue token. If deck not empty, draw new card.
            let currentPlayer = playerArray[currentPlayerNumberInt - 1]
            let discardCard = currentPlayer.handCardArray.removeAtIndex(action.targetCardIndexInt)
            discardsCardArray.append(discardCard)
            numberOfCluesLeftInt++
            if !deckCardArray.isEmpty {
                let newCard = deckCardArray.removeLast()
                currentPlayer.handCardArray.append(newCard)
            }
        }
    }
    // Sum of score for each color.
    func totalScore() -> Int {
        var scoreInt = 0
        for (color, score) in scoreDictionary {
            scoreInt += score
        }
        return scoreInt
    }
}
