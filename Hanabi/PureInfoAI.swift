//
//  PureInfoAI.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/22/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//
// Gives clues only to provide information, not intention. Interprets clues same way.
import UIKit

class PureInfoAI: AbstractAI {
    override var buttonTitleString: String {
        return "Pure Info"
    }
    override var tableViewCellString: String {
        return "Pure Info"
    }
    override func bestActionForTurn(turn: Turn) -> Action {
        let action = Action()
        // If player knows she has a playable card, play it.
        let startingGameState = turn.startingGameState
        let currentPlayer = startingGameState.currentPlayer
        let handUnknownCardArray = currentPlayer.handUnknownCardArray
        for unknownCard in handUnknownCardArray {
//            if unknownCard.isPlayableBool(scoreDictionary: startingGameState.scoreDictionary) {
//                action.type = .Play
//                action.targetCardIndexInt = find(handUnknownCardArray, unknownCard)!
//                return action
//            }
        }
        
        
        // Whether the given unknown card is a valid play.
//        func isPlayableBool(scoreDictionary: Card) -> Bool {
//            // doesn't need to be known to be playable
//            
//        }
        
        // If player knows she has a safe discard, discard it.
        // something in between?
        // If player knows she has a group/deck duplicate, discard it.
        
        // discardable: safe discards vs duplicates vs uniques?
        
//        let currentPlayerHandCardArray = startingGameState.currentPlayer.handCardArray
//        for card in currentPlayerHandCardArray {
//            // who knows whether this card is playable? game state? this AI? player?
//        }
        // not sure cards in deck (when created) should have possibilities
        // each player has a different set of possibilities for the top card of a deck
        // or what she thinks another player thinks of her cards
        // so we can keep deductions separate from the given cards
        // but it needs to be stored within each gameState so the user can see it at start and end of each turn
        // player.possibleHandCardArray, possibleCard type
        // be sure to keep aligned with cards in real hand, when drawn, played, discarded
        
        // AI has to track each player's hand from turn to turn
        // anything that isn't common knowledge has to be tracked
        // players' hands
        // what each player knows the other player knows
        // what P1 knows about her hand
        // what P1 knows about what P2 knows? later
        // what P1 knows about what P3 knows
        
        // player can keep track of pure info, including literal interpretation of clues, knowledge from seeing other players' hands
        // so, player has handCardArray; card has color and numberInt; need a way to separate true value of card from what we know about a card
        
        // 2d grid: may know card is not B2, G4, 5
        // each value can be false? when all but one are false, the remaining (nil) is true?
        // well really should be a float, because if it sees one G4, it knows there's only half the chance another card's a G4
        // could also track the number of each card that is left for each unknown card; e.g., 1 G5 left, 2 B3s, 1 B4, 0 B2s, taking into account plays, discards, other hands, and also clues
        // when all spots but one are 0, then the card is known
        // like scoreDictionary? but each color needs all 5 values (array) card.possibilitiesDictionary
        // card.isKnownBool
        
        // how does AI access turn data like the discard pile? so it should be above the players and gamestate
        // for now, leave AI where it is
        
        // ok, this isn't quite right, as it will use the actual card
        // we want the AIs knowledge of this card
        // we can have each player have an ai, and the ai has a virtual hand
        // the ai has to maintain virtual hands for all players, as it's tracking what they know
        
        return action
    }
    override init() {
        super.init()
        type = AIType.PureInfo
    }
}
