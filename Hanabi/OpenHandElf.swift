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
    var logModel = (UIApplication.sharedApplication().delegate as AppDelegate).logModel
    // Return the best action for the given turn.
    func bestActionForTurn(turn: Turn) -> Action {
        let action = Action()
        let startingGameState = turn.startingGameState
        let turnNumberInt = startingGameState.turnNumberInt
        let numberOfPlayersInt = startingGameState.numberOfPlayersInt
        let roundSubroundString = roundSubroundStringForTurn(turnNumberInt, numberOfPlayersInt: numberOfPlayersInt)
        let currentPlayerHandCardArray = startingGameState.currentPlayer.handCardArray
        // If can play, do. Play cards whose sequence will take the longest. (E.g., 132 before 123.)
        let mostTurnsForChainCardArray = startingGameState.mostTurnsForChainCardArray
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
            let numberOfCluesLeftInt = startingGameState.numberOfCluesLeftInt
            if numberOfCluesLeftInt < 8 {
                // Do one of the following, in priority order: If player has a safe discard, do. If player has a group duplicate, discard. If anyone else can play, discard safely or discard group duplicate, then give clue. If player has a card that's still in the deck, discard. Discard a unique card.
                let cheatingSafeDiscardsCardArray = startingGameState.cheatingSafeDiscardsCardArray
                if !cheatingSafeDiscardsCardArray.isEmpty {
                    action.type = .Discard
                    let theDiscardCard = cheatingSafeDiscardsCardArray.first!
                    action.targetCardIndexInt = find(currentPlayerHandCardArray, theDiscardCard)!
                } else {
                    let cheatingGroupDuplicatesCardArray = startingGameState.cheatingGroupDuplicatesCardArray
                    if !cheatingGroupDuplicatesCardArray.isEmpty {
                        action.type = .Discard
                        let theDiscardCard = cheatingGroupDuplicatesCardArray.first!
                        action.targetCardIndexInt = find(currentPlayerHandCardArray, theDiscardCard)!
                    } else if (startingGameState.cheatingAnyPlaysOrSafeDiscardsBool || startingGameState.cheatingAnyGroupDuplicatesBool) && (numberOfCluesLeftInt > 0) {
                        action.type = .Clue
                    } else {
                        // If player has a card that's still in the deck, discard highest.
                        let cheatingCardsAlsoInDeckCardArray = startingGameState.cheatingCardsAlsoInDeckCardArray
                        if !cheatingCardsAlsoInDeckCardArray.isEmpty {
                            logModel.addLine("Semi-rare? No one has a play, safe discard or group duplicate.(Or no clues left.) (Round \(roundSubroundString))")
                            action.type = .Discard
                            var theDiscardCard = cheatingCardsAlsoInDeckCardArray.first!
                            var maxNumberInt = theDiscardCard.numberInt
                            for card in cheatingCardsAlsoInDeckCardArray {
                                if card.numberInt > maxNumberInt {
                                    maxNumberInt = card.numberInt
                                    theDiscardCard = card
                                }
                            }
                            action.targetCardIndexInt = find(currentPlayerHandCardArray, theDiscardCard)!
                        } else {
                            logModel.addLine("Rare warning: Discarding unique? (Round \(roundSubroundString))")
                            action.type = .Discard
                            action.targetCardIndexInt = 0
                        }
                    }
                }
            }
        }
        return action
    }
}
