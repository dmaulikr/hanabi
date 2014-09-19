//
//  Turn.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/7/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Turn: NSObject {
//    var cheatingAnyGroupDuplicatesBool: Bool {
//        if let endingGameState = endingOptionalGameState {
//            return endingGameState.cheatingAnyGroupDuplicatesBool
//        } else {
//            return startingGameState.cheatingAnyGroupDuplicatesBool
//        }
//    }
//    var cheatingAnyPlaysOrSafeDiscardsBool: Bool {
//        if let endingGameState = endingOptionalGameState {
//            return endingGameState.cheatingAnyPlaysOrSafeDiscardsBool
//        } else {
//            return startingGameState.cheatingAnyPlaysOrSafeDiscardsBool
//        }
//    }
//    var cheatingCardsAlsoInDeckCardArray: [Card] {
//        if let endingGameState = endingOptionalGameState {
//            return endingGameState.cheatingCardsAlsoInDeckCardArray
//        } else {
//            return startingGameState.cheatingCardsAlsoInDeckCardArray
//        }
//    }
//    var cheatingGroupDuplicatesCardArray: [Card] {
//        if let endingGameState = endingOptionalGameState {
//            return endingGameState.cheatingGroupDuplicatesCardArray
//        } else {
//            return startingGameState.cheatingGroupDuplicatesCardArray
//        }
//    }
    var currentPlayer: Player {
        // Same in starting and ending states.
        return startingGameState.currentPlayer
    }
    var deck: Deck {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.deck
        } else {
            return startingGameState.deck
        }
    }
    var endingOptionalGameState: EndingGameState?
    // Whether the game has ended (not necessarily won).
    var gameIsDone: Bool {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.isDone
        } else {
            return false
        }
    }
    // Max plays left at end of turn.
    var maxPlaysLeftInt: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.maxNumberOfPlaysLeftInt
        } else {
            return startingGameState.maxNumberOfPlaysLeftInt
        }
    }
//    var mostTurnsForChainCardArray: [Card] {
//        if let endingGameState = endingOptionalGameState {
//            return endingGameState.mostTurnsForChainCardArray
//        } else {
//            return startingGameState.mostTurnsForChainCardArray
//        }
//    }
    // Number of bad plays by end of turn.
    var numberOfBadPlaysInt: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.numberOfBadPlaysInt
        } else {
            return startingGameState.numberOfBadPlaysInt
        }
    }
    var numCardsLeft: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.numberOfCardsLeftInt
        } else {
            return startingGameState.numberOfCardsLeftInt
        }
    }
    // Number of clues given by end of turn.
    var numberOfCluesGivenInt: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.numCluesGiven
        } else {
            return startingGameState.numCluesGiven
        }
    }
    var numCluesLeft: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.numCluesLeft
        } else {
            return startingGameState.numCluesLeft
        }
    }
    // Number of discards by end of turn.
    var numberOfDiscardsInt: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.numberOfDiscardsInt
        } else {
            return startingGameState.numberOfDiscardsInt
        }
    }
    var numberOfPlayersInt: Int {
        // Same in starting and ending states.
        return startingGameState.numberOfPlayersInt
    }
    var optionalAction: Action?
    var players: [Player] {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.playerArray
        } else {
            return startingGameState.playerArray
        }
    }
    var pointsNeeded: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.numberOfPointsNeededInt
        } else {
            return startingGameState.numberOfPointsNeededInt
        }
    }
    // String for the round and subround for this turn. (E.g., in a 3-player game, turn 6 = round "2.3.")
    var roundSubroundString: String {
        // Same in starting and ending states.
        return roundSubroundStringForTurn(turnNum, numberOfPlayersInt: numberOfPlayersInt)
    }
    var scoreInt: Int {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.scoreInt
        } else {
            return startingGameState.scoreInt
        }
    }
    var scorePile: ScorePile {
        if let endingGameState = endingOptionalGameState {
            return endingGameState.scorePile
        } else {
            return startingGameState.scorePile
        }
    }
    var startingGameState: StartingGameState
    var turnNum: Int {
        // Same in starting and ending states.
        return startingGameState.turnNum
    }
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
