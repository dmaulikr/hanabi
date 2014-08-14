//
//  EndingGameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/12/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class EndingGameState: AbstractGameState {
    // Whether the game has ended (not necessarily won).
    var isDone: Bool {
        // Game ends if score maxed, if out of strikes or if out of turns. The last case: when the deck is empty, each player gets one more turn.
        if scoreInt == 25 || numberOfStrikesLeftInt == 0 {
            return true
        }
        if deck.isEmpty && (numberOfTurnsPlayedWithEmptyDeckInt == numberOfPlayersInt) {
            return true
        }
        return false
    }
    // If deck not empty, draw new card.
    func drawCard() {
        if !deck.isEmpty {
            let newCard = deck.drawCard()
            currentPlayer.handCardArray.append(newCard)
        }
    }
    // Ending state = starting state + results of action.
    init(startingGameState: StartingGameState, action: Action) {
        super.init()
        currentPlayer = startingGameState.currentPlayer.copy() as Player
        deck = startingGameState.deck.copy() as Deck
        discardsCardArray = startingGameState.discardsCardArray
        numberOfCluesLeftInt = startingGameState.numberOfCluesLeftInt
        numberOfStrikesLeftInt = startingGameState.numberOfStrikesLeftInt
        numberOfTurnsPlayedWithEmptyDeckInt = startingGameState.numberOfTurnsPlayedWithEmptyDeckInt
        for player in startingGameState.playerArray {
            playerArray.append(player.copy() as Player)
        }
        scoreDictionary = startingGameState.scoreDictionary
        performAction(action)
    }
    // Determine state resulting from given action.
    func performAction(action: Action) {
        // If deck already empty, then note turn.
        if deck.isEmpty {
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
            // Remove card from hand. Play it. If okay, increase score. Else, lose strike and put in discard pile. Draw card.
            let playCard = currentPlayer.handCardArray.removeAtIndex(action.targetCardIndexInt)
            if cardIsPlayable(playCard) {
                var scoreInt = scoreDictionary[playCard.color]!
                scoreInt++
                scoreDictionary[playCard.color] = scoreInt
            } else {
                numberOfStrikesLeftInt--
                discardsCardArray.append(playCard)
            }
            drawCard()
        case .Discard:
            // If clues not less than max, trigger an assertion. (AI shouldn't have chosen this, and player shouldn't have been able to.)
            assert(numberOfCluesLeftInt < 8, "Error: tried to discard with max clue tokens.")
            // Remove card from hand. Put in discard pile. Gain clue token. Draw card.
            let discardCard = currentPlayer.handCardArray.removeAtIndex(action.targetCardIndexInt)
            discardsCardArray.append(discardCard)
            numberOfCluesLeftInt++
            drawCard()
        }
    }
}
