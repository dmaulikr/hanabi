//
//  AlwaysDiscardElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/10/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

// Action is to always discard first card in hand.
class AlwaysDiscardElf: NSObject {
    // Return the best action for the given turn.
    func bestActionForTurn(turn: Turn) -> Action {
        let action = Action()
        // If can discard, do it. Else, give clue.
        let numberOfCluesLeftInt = turn.startingGameState.numberOfCluesLeftInt
        if numberOfCluesLeftInt < 8 {
            action.type = .Discard
        } else if numberOfCluesLeftInt > 0 {
            action.type = .Clue
        }
        return action
    }
}
