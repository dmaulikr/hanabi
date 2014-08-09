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
    // this should populate the endingState
    func performAction() {
        if let action = optionalAction {
            switch action.type {
            case .Clue:
                println("give a clue")
            case .Play:
                println("play a card")
            case .Discard:
                println("discard a card")
            }
        }
    }
}
