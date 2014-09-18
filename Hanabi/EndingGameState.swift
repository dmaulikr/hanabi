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
        if scorePile.currentInt == 25 || numberOfStrikesLeftInt == 0 {
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
            currentPlayer.hand.append(newCard)
        }
    }
    // Ending state = starting state + results of action.
    init(startingGameState: StartingGameState, action: Action) {
        super.init()
        currentPlayerIndex = startingGameState.currentPlayerIndex
        deck = startingGameState.deck.copy() as Deck
        discardsCardArray = startingGameState.discardsCardArray
        numCluesGiven = startingGameState.numCluesGiven
        numCluesLeft = startingGameState.numCluesLeft
        numberOfStrikesLeftInt = startingGameState.numberOfStrikesLeftInt
        numberOfTurnsPlayedWithEmptyDeckInt = startingGameState.numberOfTurnsPlayedWithEmptyDeckInt
        for player in startingGameState.playerArray {
            playerArray.append(player.copy() as Player)
        }
        scorePile = startingGameState.scorePile.copy()
        turnNum = startingGameState.turnNum
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
//            println("give a clue")
            // If clues not left, trigger an assertion. (AI shouldn't have chosen this, and player shouldn't have been able to.)
            assert(numCluesLeft > 0, "Error: tried to give clue with 0 clue tokens.")
            --numCluesLeft
            ++numCluesGiven
        case .Play:
//            println("play a card")
            // Remove card from hand. Play it. If okay, increase score. Else, lose strike and put in discard pile. Draw card.
            let card = currentPlayer.hand.removeAtIndex(action.targetCardIndex)
            if scorePile.canScore(card) {
                scorePile.addCard(card)
                // If a 5 and not max clues, gain a clue.
                if card.num == 5 && numCluesLeft < 8 {
                    ++numCluesLeft
                }
            } else {
                --numberOfStrikesLeftInt
                discardsCardArray.append(card)
            }
            drawCard()
        case .Discard:
            // If clues not less than max, trigger an assertion. (AI shouldn't have chosen this, and player shouldn't have been able to.)
            assert(numCluesLeft < 8, "Error: tried to discard with max clue tokens.")
            // Remove card from hand. Put in discard pile. Gain clue token. Draw card.
            let discardCard = currentPlayer.hand.removeAtIndex(action.targetCardIndex)
            discardsCardArray.append(discardCard)
            ++numCluesLeft
            drawCard()
        }
    }
}
