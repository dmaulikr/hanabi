//
//  Turn.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/7/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Turn: NSObject {
    var endingOptionalGameState: GameState?
    var optionalAction: Action?
    var startingGameState: GameState
    // Return a string describing the turn's action and result.
    func actionResultString() -> String {
        var resultString = "\nP\(startingGameState.currentPlayerNumberInt)"
        if let action = optionalAction {
            switch action.type {
            case .Clue:
                resultString += " gave a clue: X."
            case .Discard:
                if let card = endingOptionalGameState?.discardsCardArray.last {
                    resultString += " discarded card \(action.targetCardIndexInt + 1): \(card.string())."
                    if !startingGameState.deckCardArray.isEmpty {
                        resultString += " Drew a card."
                    }
                }
            case .Play:
                resultString += " played X."
            }
        }
        return resultString
    }
    init(gameState: GameState) {
        startingGameState = gameState
        super.init()
    }
    // From the starting state, perform the action to make the ending state.
    func performAction() {
        if let action = optionalAction {
            if let endingGameState = startingGameState.copy() as? GameState {
                endingGameState.performAction(action)
                endingOptionalGameState = endingGameState
            }
        }
    }
}
