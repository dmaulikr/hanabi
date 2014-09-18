//
//  StartingGameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/12/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class StartingGameState: AbstractGameState {
    // Whether player knows the given card back is playable.
    func cardBackIsKnownPlayableBool(cardBack: CardBack) -> Bool {
        return scorePile.cardBackIsKnownPlayableBool(cardBack)
    }
    // Deal starting hands to players.
    func dealHands() {
        // In reality, we'd deal a card to a player at a time, because the cards may not be well-shuffled. Here, we'll deal each player completely. This makes games with the same deck but different numbers of players more comparable.
        var numberOfCardsPerPlayerInt: Int
        switch numberOfPlayersInt {
        case 2, 3:
            numberOfCardsPerPlayerInt = 5
        case 4, 5:
            numberOfCardsPerPlayerInt = 4
        default:
            numberOfCardsPerPlayerInt = 3
        }
        for player in playerArray {
            player.hand = deck.drawCards(numberOfCardsPerPlayerInt)
        }
    }
    // Make new, deal hands to given players.
    init(deck: Deck, playerArray: [Player]) {
        super.init()
        self.deck = deck
        self.playerArray = playerArray
        currentPlayerIndex = 0
        dealHands()
    }
    // Make from previous game state. Just change current player and increase turn number.
    init(endingGameState: EndingGameState) {
        super.init()
        currentPlayerIndex = endingGameState.currentPlayerIndex
        deck = endingGameState.deck.copy() as Deck
        discardsCardArray = endingGameState.discardsCardArray
        numCluesGiven = endingGameState.numCluesGiven
        numCluesLeft = endingGameState.numCluesLeft
        numberOfStrikesLeftInt = endingGameState.numberOfStrikesLeftInt
        numberOfTurnsPlayedWithEmptyDeckInt = endingGameState.numberOfTurnsPlayedWithEmptyDeckInt
        for player in endingGameState.playerArray {
            playerArray.append(player.copy() as Player)
        }
        scorePile = endingGameState.scorePile.copy()
        turnNum = endingGameState.turnNum + 1
        moveToNextPlayer()
    }
    // Change current player to next player.
    func moveToNextPlayer() {
        currentPlayerIndex = currentPlayerIndex + 1
        if currentPlayerIndex == numberOfPlayersInt {
            currentPlayerIndex = 0
        }
    }
    // String describing the given action and its result.
    func stringForAction(action: Action) -> String {
        var resultString = "\(currentPlayer.nameString)"
        let index = action.targetCardIndex
        let card = currentPlayer.hand[index]
        // Card position and abbreviation.
        let cardPositionString = "card \(index + 1): \(card.string)"
        switch action.type {
        case .Clue:
            resultString += " clues P_: You have _____ _______."
        case .Discard:
            resultString += " discards \(cardPositionString)."
            if numberOfCardsLeftInt >= 1 {
                resultString += " Draws."
            }
        case .Play:
            resultString += " plays \(cardPositionString)."
            // If invalid play, mention that.
            if !scorePile.canScore(card) {
                resultString += " Invalid play. Strike."
            }
            if numberOfCardsLeftInt >= 1 {
                resultString += " Draws."
            }
        }
        return resultString
    }
}
