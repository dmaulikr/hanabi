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
        let action = Action(.Clue)
        // If can discard, do it. Else, give clue.
        let numCluesLeft = turn.startingGameState.numCluesLeft
        if numCluesLeft < 8 {
            action.type = .Discard
        } else if numCluesLeft > 0 {
            action.type = .Clue
        }
        return action
    }
}
