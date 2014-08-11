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
        // If can play, do. Play cards whose sequence will take the longest. (E.g., 132 before 123.)
        let mostTurnsForChainCardArray = gameState.mostTurnsForChainCardArray()
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
            println("thePlayCard: \(thePlayCard.string())")
            let currentPlayerHandCardArray = gameState.playerArray[gameState.currentPlayerNumberInt - 1].handCardArray
            action.targetCardIndexInt = find(currentPlayerHandCardArray, thePlayCard)!
        } else {
            // If an easy discard (already played, dup in hand), do.
            
            // for now, let's just discard so we can test the plays
            // If can discard, do it. Else, give clue.
            let numberOfCluesLeftInt = turn.startingGameState.numberOfCluesLeftInt
            if numberOfCluesLeftInt < 8 {
                action.type = .Discard
            } else if numberOfCluesLeftInt > 0 {
                action.type = .Clue
            }
        }
        return action
    }
}
