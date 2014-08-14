//
//  Turn.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/7/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Turn: NSObject {
    // Make the first turn, given the deck and players.
    class func firstTurn(deck: Deck, playerArray: [Player]) -> Turn {
        var turn = Turn(gameState: nil)
        // set up state
        // deal hands
    }
    // String describing the turn's action and its result.
    // could package this in data
//    var actionString: String {
//        return startingGameState.stringForAction(optionalAction!)
//    }
    var endingOptionalGameState: EndingGameState?
    var optionalAction: Action?
    var startingGameState: StartingGameState
    // Data for turn. If turn end, the data is for the end of the turn (vs start).
    func data(#turnEndBool: Bool) -> (actionString: String, discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreString: String, visibleHandsString: String) {
        var data = startingGameState.data
        if turnEndBool {
            data = endingOptionalGameState!.data
        }
        let actionString = startingGameState.stringForAction(optionalAction!)
        let discardsString = data.discardsString
        let maxNumberOfPlaysLeftInt = data.maxNumberOfPlaysLeftInt
        let numberOfCardsLeftInt = data.numberOfCardsLeftInt
        let numberOfCluesLeftInt = data.numberOfCluesLeftInt
        let numberOfPointsNeededInt = data.numberOfPointsNeededInt
        let numberOfStrikesLeftInt = data.numberOfStrikesLeftInt
        let scoreString = data.scoreString
        let visibleHandsString = data.visibleHandsString
        return (actionString, discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreString, visibleHandsString)
    }
    // Make turn: use previous game state and move to next player. If no game state, create new game state.
    init(endingOptionalGameState: EndingGameState?) {
        startingGameState = StartingGameState(endingOptionalGameState: endingOptionalGameState)
        super.init()
    }
    // Turn following this one.
    func makeNextTurn() -> Turn {
        return Turn(endingOptionalGameState: endingOptionalGameState)
    }
    // I.e., make the ending state.
    func performAction() {
        if let action = optionalAction {
            endingOptionalGameState = EndingGameState(startingGameState: startingGameState, action: action)
        }
    }
}
