//
//  Turn.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/7/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Turn: NSObject {
    // Max plays left at end of turn.
    var endingMaxPlaysLeftInt: Int {
        let endingGameState = endingOptionalGameState!
        return endingGameState.maxNumberOfPlaysLeftInt
    }
    // Number of bad plays by end of turn.
    var endingNumberOfBadPlaysInt: Int {
        let endingGameState = endingOptionalGameState!
            return endingGameState.numberOfBadPlaysInt
    }
    // Number of clues given by end of turn.
    var endingNumberOfCluesGivenInt: Int {
        let endingGameState = endingOptionalGameState!
            return endingGameState.numberOfCluesGivenInt
    }
    // Number of discards by end of turn.
    var endingNumberOfDiscardsInt: Int {
        let endingGameState = endingOptionalGameState!
            return endingGameState.numberOfDiscardsInt
    }
    var endingOptionalGameState: EndingGameState?
    // Score at end of turn.
    var endingScoreInt: Int {
        let endingGameState = endingOptionalGameState!
        return endingGameState.scoreInt
    }
    // Whether the game has ended (not necessarily won).
    var gameIsDone: Bool {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.isDone
        } else {
            return false
        }
    }
    var optionalAction: Action?
    var startingGameState: StartingGameState
    // Data for turn. If turn end, the data is for the end of the turn (vs start).
    func data(#turnEndBool: Bool, showCurrentHandBool: Bool) -> (actionString: String, deckString: String, discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreString: String, visibleHandsAttributedString: NSAttributedString) {
        var gameState: AbstractGameState = startingGameState
        if turnEndBool {
            gameState = endingOptionalGameState!
        }
        let data = gameState.data(showCurrentHandBool: showCurrentHandBool)
        let actionString = startingGameState.stringForAction(optionalAction!)
        let deckString = startingGameState.deck.string
        let discardsString = data.discardsString
        let maxNumberOfPlaysLeftInt = data.maxNumberOfPlaysLeftInt
        let numberOfCardsLeftInt = data.numberOfCardsLeftInt
        let numberOfCluesLeftInt = data.numberOfCluesLeftInt
        let numberOfPointsNeededInt = data.numberOfPointsNeededInt
        let numberOfStrikesLeftInt = data.numberOfStrikesLeftInt
        let scoreString = data.scoreString
        let visibleHandsAttributedString = data.visibleHandsAttributedString
        return (actionString, deckString, discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreString, visibleHandsAttributedString)
    }
    // Make new, deal hands to given players.
    init(deck: Deck, playerArray: [Player]) {
        startingGameState = StartingGameState(deck: deck, playerArray: playerArray)
        super.init()
    }
    // Make from previous turn.
    init(previousTurn: Turn) {
        startingGameState = StartingGameState(endingGameState: previousTurn.endingOptionalGameState!)
        super.init()
    }
    // I.e., make the ending state.
    func performAction() {
        if let action = optionalAction {
            endingOptionalGameState = EndingGameState(startingGameState: startingGameState, action: action)
        }
    }
}
