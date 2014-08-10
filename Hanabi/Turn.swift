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
    // From the starting state, perform the action to make the ending state.
    func performAction() {
        if let action = optionalAction {
            if let endingGameState = startingGameState.copy() as? GameState {
                endingGameState.performAction(action)
                
//                switch action.type {
//                case .Clue:
//                    println("give a clue")
//                    //endingGameState.removeClue()
//                    endingGameState.numberOfCluesLeftInt--
//                case .Play:
//                    println("play a card")
//                    // remove card from hand
//                    // if valid, increase score
//                    // else, remove strike and put in discard
//                    // player draws new card
//                case .Discard:
//                    println("discard a card")
//                    // remove card from hand
//                    //endingGameState.discardCard()
//                    endingGameState.currentPlayerNumberInt
//                    endingGameState.playerArray[]
//                    // put card in discard pile
//                    // add a clue token (if not max; put a note here for later, too)
//                    //endingGameState.addClue()
//                    endingGameState.numberOfCluesLeftInt++
//                    // player draws new card
//                }
                
                endingOptionalGameState = endingGameState
            }
        }
    }
}
