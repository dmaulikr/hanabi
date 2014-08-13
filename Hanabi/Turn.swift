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
    var optionalAction: Action?
    var startingGameState: StartingGameState
    // String describing the turn's action and its result.
    func actionResultString() -> String {
        return startingGameState.resultStringForAction(optionalAction!)
    }
    init(startingGameState: StartingGameState) {
        self.startingGameState = startingGameState
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
