//
//  OpenHandElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/11/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

// Looks at own hand. (Cheats.)
class OmniscientAI: AbstractAI {
    override var buttonTitleString: String {
        return "Omniscient"
    }
    override var tableViewCellString: String {
        return "Omniscient"
    }
    //override
    func bestActionForCurrentTurn(game: Game) -> Action {
        let turn = game.currentTurn
        
        let action = Action()
        let currentPlayerHandCardArray = turn.currentPlayer.handCardArray
        let numberOfCardsLeftInt = turn.numberOfCardsLeftInt
        let numberOfCluesLeftInt = turn.numberOfCluesLeftInt
        let cheatingNumberOfVisiblePlaysInt = turn.cheatingNumberOfVisiblePlaysInt
        // If can play, do. Play cards whose sequence will take the longest. (E.g., 132 before 123.)
        let mostTurnsForChainCardArray = turn.mostTurnsForChainCardArray
        //game.
        // Return card(s) whose visible chain will take the longest to play. For example, 123 takes 3 turns, 132 takes 5.
        if !mostTurnsForChainCardArray.isEmpty {
            //            println("Play. (Round \(turn.roundSubroundString))")
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
            action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(thePlayCard, cardArray: currentPlayerHandCardArray)!
            // If the number of visible plays >= number of cards - 1 in the deck, give a clue. (To avoid decking.)
        } else if (cheatingNumberOfVisiblePlaysInt > 0) && (cheatingNumberOfVisiblePlaysInt >= numberOfCardsLeftInt - 1) && (numberOfCluesLeftInt > 0) {
            //            println("avoiding decking; (Round \(turn.roundSubroundString))")
            action.type = .Clue
            // If max clues, can't discard, so give a clue.
        } else if numberOfCluesLeftInt == 8 {
            //            println("Max clues: give clue. (Round \(turn.roundSubroundString))")
            action.type = .Clue
        } else {
            // Do one of the following, in priority order:
            // If player has a safe discard, do.
            // If player has a group duplicate, discard.
            // If anyone else can play, discard safely or discard group duplicate, then give clue.
            // If player has a card that's still in the deck, discard.
            // Discard a unique card.
            let cheatingSafeDiscardsCardArray = turn.cheatingSafeDiscardsCardArray
            if !cheatingSafeDiscardsCardArray.isEmpty {
                //                println("Round \(roundSubroundString): Safe discard.")
                action.type = .Discard
                let theDiscardCard = cheatingSafeDiscardsCardArray.first!
                action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
            } else {
                let cheatingGroupDuplicatesCardArray = turn.cheatingGroupDuplicatesCardArray
                if !cheatingGroupDuplicatesCardArray.isEmpty {
                    //                    println("Round \(roundSubroundString): Group discard.")
                    action.type = .Discard
                    let theDiscardCard = cheatingGroupDuplicatesCardArray.first!
                    action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
                } else if (turn.cheatingAnyPlaysOrSafeDiscardsBool || turn.cheatingAnyGroupDuplicatesBool) && (numberOfCluesLeftInt > 0) {
                    //                    println("Round \(roundSubroundString): Another can play/discard. Give clue.")
                    action.type = .Clue
                } else {
                    // If player has a card that's still in the deck, discard highest.
                    let cheatingCardsAlsoInDeckCardArray = turn.cheatingCardsAlsoInDeckCardArray
                    if !cheatingCardsAlsoInDeckCardArray.isEmpty {
                        logModel.addLine("Semi-rare? No one has a play, safe discard or group duplicate.(Or no clues left.) Seed: \(optionalGame?.seedUInt32). Round \(turn.roundSubroundString).")
                        action.type = .Discard
                        var theDiscardCard = cheatingCardsAlsoInDeckCardArray.first!
                        var maxNumberInt = theDiscardCard.numberInt
                        for card in cheatingCardsAlsoInDeckCardArray {
                            if card.numberInt > maxNumberInt {
                                maxNumberInt = card.numberInt
                                theDiscardCard = card
                            }
                        }
                        action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
                    } else {
                        logModel.addLine("Rare warning: Discarding unique? Seed: \(optionalGame?.seedUInt32). Round \(turn.roundSubroundString).")
                        action.type = .Discard
                        action.targetCardIndexInt = 0
                    }
                }
            }
        }
        return action
    }
    override func bestActionForTurn(turn: Turn) -> Action {
        let action = Action()
//        println("Round \(turn.roundSubroundString).")
        let currentPlayerHandCardArray = turn.currentPlayer.handCardArray
        let numberOfCardsLeftInt = turn.numberOfCardsLeftInt
        let numberOfCluesLeftInt = turn.numberOfCluesLeftInt
        let cheatingNumberOfVisiblePlaysInt = turn.cheatingNumberOfVisiblePlaysInt
        // If can play, do. Play cards whose sequence will take the longest. (E.g., 132 before 123.)
        let mostTurnsForChainCardArray = turn.mostTurnsForChainCardArray
        if !mostTurnsForChainCardArray.isEmpty {
//            println("Play. (Round \(turn.roundSubroundString))")
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
            action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(thePlayCard, cardArray: currentPlayerHandCardArray)!
        // If the number of visible plays >= number of cards - 1 in the deck, give a clue. (To avoid decking.)
        } else if (cheatingNumberOfVisiblePlaysInt > 0) && (cheatingNumberOfVisiblePlaysInt >= numberOfCardsLeftInt - 1) && (numberOfCluesLeftInt > 0) {
//            println("avoiding decking; (Round \(turn.roundSubroundString))")
            action.type = .Clue
        // If max clues, can't discard, so give a clue.
        } else if numberOfCluesLeftInt == 8 {
//            println("Max clues: give clue. (Round \(turn.roundSubroundString))")
            action.type = .Clue
        } else {
            // Do one of the following, in priority order:
            // If player has a safe discard, do.
            // If player has a group duplicate, discard. 
            // If anyone else can play, discard safely or discard group duplicate, then give clue. 
            // If player has a card that's still in the deck, discard. 
            // Discard a unique card.
            let cheatingSafeDiscardsCardArray = turn.cheatingSafeDiscardsCardArray
            if !cheatingSafeDiscardsCardArray.isEmpty {
//                println("Round \(roundSubroundString): Safe discard.")
                action.type = .Discard
                let theDiscardCard = cheatingSafeDiscardsCardArray.first!
                action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
            } else {
                let cheatingGroupDuplicatesCardArray = turn.cheatingGroupDuplicatesCardArray
                if !cheatingGroupDuplicatesCardArray.isEmpty {
//                    println("Round \(roundSubroundString): Group discard.")
                    action.type = .Discard
                    let theDiscardCard = cheatingGroupDuplicatesCardArray.first!
                    action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
                } else if (turn.cheatingAnyPlaysOrSafeDiscardsBool || turn.cheatingAnyGroupDuplicatesBool) && (numberOfCluesLeftInt > 0) {
//                    println("Round \(roundSubroundString): Another can play/discard. Give clue.")
                    action.type = .Clue
                } else {
                    // If player has a card that's still in the deck, discard highest.
                    let cheatingCardsAlsoInDeckCardArray = turn.cheatingCardsAlsoInDeckCardArray
                    if !cheatingCardsAlsoInDeckCardArray.isEmpty {
                        logModel.addLine("Semi-rare? No one has a play, safe discard or group duplicate.(Or no clues left.) Seed: \(optionalGame?.seedUInt32). Round \(turn.roundSubroundString).")
                        action.type = .Discard
                        var theDiscardCard = cheatingCardsAlsoInDeckCardArray.first!
                        var maxNumberInt = theDiscardCard.numberInt
                        for card in cheatingCardsAlsoInDeckCardArray {
                            if card.numberInt > maxNumberInt {
                                maxNumberInt = card.numberInt
                                theDiscardCard = card
                            }
                        }
                        action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
                    } else {
                        logModel.addLine("Rare warning: Discarding unique? Seed: \(optionalGame?.seedUInt32). Round \(turn.roundSubroundString).")
                        action.type = .Discard
                        action.targetCardIndexInt = 0
                    }
                }
            }
        }
        return action
    }
    override init() {
        super.init()
        type = AIType.Omniscient
    }
}
