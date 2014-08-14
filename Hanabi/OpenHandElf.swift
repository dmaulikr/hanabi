//
//  OpenHandElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/11/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

// Looks at own hand. (Cheats.)
class OpenHandElf: NSObject {
    // Return the best action for the given turn.
    func bestActionForTurn(turn: Turn) -> Action {
        let action = Action()
        let gameState = turn.startingGameState
        let currentPlayerHandCardArray = gameState.currentPlayer.handCardArray
        // If can play, do. Play cards whose sequence will take the longest. (E.g., 132 before 123.)
        let mostTurnsForChainCardArray = gameState.mostTurnsForChainCardArray
        if !mostTurnsForChainCardArray.isEmpty {
            action.type = .Play
            // If multiple options, choose first card with lowest number.
            var thePlayCard: Card = mostTurnsForChainCardArray.first!
            var minCardNumberInt = 6
            for card in mostTurnsForChainCardArray {
                if card.numberInt < minCardNumberInt {
                    minCardNumberInt = card.numberInt
                    thePlayCard = card
                }
            }
            action.targetCardIndexInt = find(currentPlayerHandCardArray, thePlayCard)!
        } else {
            let numberOfCluesLeftInt = turn.startingGameState.numberOfCluesLeftInt
            if numberOfCluesLeftInt < 8 {
                // If a safe discard, do. Else, if no one can play or do a safe discard, then discard. Else, give clue. If no clues, discard.
                let cheatingSafeDiscardsCardArray = gameState.cheatingSafeDiscardsCardArray
                if !cheatingSafeDiscardsCardArray.isEmpty {
                    action.type = .Discard
                    let theDiscardCard = cheatingSafeDiscardsCardArray.first!
                    action.targetCardIndexInt = find(currentPlayerHandCardArray, theDiscardCard)!
                } else if !gameState.cheatingAnyPlaysOrSafeDiscards {
                    println("Rare: no one has a play or safe discard?")
                    action.type = .Discard
                    // choose suitable discard
                    // for now, just discard 1st card; refine later
                    action.targetCardIndexInt = 0
                } else if numberOfCluesLeftInt > 0 {
                    action.type = .Clue
                } else {
                    println("Rare for OpenHandElf? No safe discards and no clues.")
                    action.type = .Discard
                    // discard 1st card; refine later
                    action.targetCardIndexInt = 0
                }
            } else if numberOfCluesLeftInt > 0 {
                action.type = .Clue
            }
        }
        return action
    }
}
