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
    init(gameState: GameState) {
        startingGameState = gameState
        super.init()
    }
    // this should populate/create the endingState, which should start as a copy of the startingState
    func performAction() {
        if let action = optionalAction {
            switch action.type {
            case .Clue:
                println("give a clue")
                // at least remove a clue token for now
            case .Play:
                println("play a card")
                // remove card from hand
                // if valid, increase score
                // else, remove strike and put in discard
                // player draws new card
            case .Discard:
                println("discard a card")
                // remove card from hand
                // put card in discard pile
                // add a clue token (if not max; put a note here for later, too)
                // player draws new card
            }
        }
    }
}
