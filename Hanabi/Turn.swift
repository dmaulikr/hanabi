//
//  Turn.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/7/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Turn: NSObject {
    var endingOptionalGameState: EndingGameState?
    // Score at end of turn.
    var endingScoreInt: Int {
        let endingGameState = endingOptionalGameState!
        return endingGameState.scoreInt
    }
    // Whether the game has ended (not necessarily won).
    var gameIsDone: Bool {
        let endingGameState = endingOptionalGameState!
        return endingGameState.isDone
    }
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
