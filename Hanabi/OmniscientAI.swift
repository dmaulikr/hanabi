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
    override var name: String {
        return "Omniscient"
    }
    override func bestAction(#game: Game) -> Action {
        let action = Action()
        // Try in order:
        // Play: lowest card.
        // Avoid decking: If in danger of decking, give clue.
        // Can't discard: If max clues then can't discard, so give clue.
        // Safe discard: Already-played card or in-hand duplicate.
        
        // Stall 1: If another can play or discard safely, then give clue.
        // Non-1 group duplicates. If any:
          // Discard: If player is in worst position, discard.
          // Stall 2: Else another should discard, so give clue.
    
        // Discard card that's still in deck. (Dangerous if remaining card(s) at end of deck.)
        // Discard unique unscored card. (Can't win.)
        let subroundString = "Round \(game.currentSubroundString)"
        let players = game.players
        let player = game.currentPlayer
        let hand = player.hand
        let scorePile = game.scorePile
        let numCluesLeft = game.numCluesLeft
        if player.canPlayOn(scorePile) {
//            println("\(subroundString): Play.")
            action.type = .Play
            let playableCards = player.playablesOn(scorePile)
            // Play lowest possible card. If tie, play first.
            let lowestCard = Card.lowest(playableCards).first!
            action.targetCardIndex = lowestCard.indexIn(hand)!
        } else if canClue(game: game) && mayDeck(game: game) {
//            println("\(subroundString): Avoid decking: Clue.")
            action.type = .Clue
        } else if !canDiscard(game: game) {
//            println("\(subroundString): Can't discard (max clues?): Clue.")
            action.type = .Clue
        } else if canDiscard(game: game) && player.canDiscardSafely(scorePile: scorePile) {
//            println("\(subroundString): Safe discard.")
            action.type = .Discard
            let discardsSafe = player.discardsSafe(scorePile: scorePile)
            let card = discardsSafe.first!
            action.targetCardIndex = card.indexIn(hand)!
        } else if canClue(game: game) && Player.anotherCanPlayOn(scorePile, players: players, currentPlayer: player) || Player.anotherCanDiscardSafely(scorePile: scorePile, players: players, currentPlayer: player) {
            // println("\(subroundString): Another can play or discard safely: Clue.")
            action.type = .Clue
        } else if player.hasNon1GroupDuplicate(players: players) {
            if canDiscard(game: game) && player.shouldDiscardNon1GroupDuplicate(players: players) {
//                println("\(subroundString): Should discard non-1 group duplicate: Discard.")
                action.type = .Discard
                let card = player.non1GroupDuplicateToDiscard(players: players)!
                action.targetCardIndex = card.indexIn(hand)!
            } else if canClue(game: game) {
                // println("\(subroundString): Another should discard non-1 group duplicate: Clue.")
                action.type = .Clue
            }
        } // WILO
        // else if canDiscard(game: game) && ?? player.canDiscardDeckCard(deck?)
//                    // If player has a card that's still in the deck, discard highest.
//                    let cheatingCardsAlsoInDeckCardArray = turn.cheatingCardsAlsoInDeckCardArray
//                    if !cheatingCardsAlsoInDeckCardArray.isEmpty {
//                        log.addLine("Semi-rare? No one has a play, safe discard or group duplicate.(Or no clues left.) Seed: \(game.seedUInt32). Round \(turn.roundSubroundString).")
//                        action.type = .Discard
//                        var theDiscardCard = cheatingCardsAlsoInDeckCardArray.first!
//                        var maxNumberInt = theDiscardCard.numberInt
//                        for card in cheatingCardsAlsoInDeckCardArray {
//                            if card.numberInt > maxNumberInt {
//                                maxNumberInt = card.numberInt
//                                theDiscardCard = card
//                            }
//                        }
//                        action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentHand)!
//                    } else {
//                        log.addLine("Rare warning: Discarding unique? Seed: \(game.seedUInt32). Round \(turn.roundSubroundString).")
//                        action.type = .Discard
//                        action.targetCardIndexInt = 0
//                    }
//                }
//            }
//        }
        return action
    }
    
    // last working version. keep until new version up and comparable stats
//    override func bestActionForTurn(turn: Turn) -> Action {
//        let action = Action()
////        println("Round \(turn.roundSubroundString).")
//        let currentPlayerHandCardArray = turn.currentPlayer.handCardArray
//        let numberOfCardsLeftInt = turn.numberOfCardsLeftInt
//        let numberOfCluesLeftInt = turn.numberOfCluesLeftInt
//        let cheatingNumberOfVisiblePlaysInt = turn.cheatingNumberOfVisiblePlaysInt
//        // If can play, do. Play cards whose sequence will take the longest. (E.g., 132 before 123.)
//        let mostTurnsForChainCardArray = turn.mostTurnsForChainCardArray
//        if !mostTurnsForChainCardArray.isEmpty {
////            println("Play. (Round \(turn.roundSubroundString))")
//            action.type = .Play
//            // If multiple options, choose first card with lowest number.
//            var thePlayCard: Card = mostTurnsForChainCardArray.first!
//            var minCardNumberInt = 6
//            for card in mostTurnsForChainCardArray {
//                if card.numberInt < minCardNumberInt {
//                    minCardNumberInt = card.numberInt
//                    thePlayCard = card
//                }
//            }
//            action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(thePlayCard, cardArray: currentPlayerHandCardArray)!
//        // If the number of visible plays >= number of cards - 1 in the deck, give a clue. (To avoid decking.)
//        } else if (cheatingNumberOfVisiblePlaysInt > 0) && (cheatingNumberOfVisiblePlaysInt >= numberOfCardsLeftInt - 1) && (numberOfCluesLeftInt > 0) {
////            println("avoiding decking; (Round \(turn.roundSubroundString))")
//            action.type = .Clue
//        // If max clues, can't discard, so give a clue.
//        } else if numberOfCluesLeftInt == 8 {
////            println("Max clues: give clue. (Round \(turn.roundSubroundString))")
//            action.type = .Clue
//        } else {
//            // Do one of the following, in priority order:
//            // If player has a safe discard, do.
//            // If player has a group duplicate, discard. 
//            // If anyone else can play, discard safely or discard group duplicate, then give clue. 
//            // If player has a card that's still in the deck, discard. 
//            // Discard a unique card.
//            let cheatingSafeDiscardsCardArray = turn.cheatingSafeDiscardsCardArray
//            if !cheatingSafeDiscardsCardArray.isEmpty {
////                println("Round \(roundSubroundString): Safe discard.")
//                action.type = .Discard
//                let theDiscardCard = cheatingSafeDiscardsCardArray.first!
//                action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
//            } else {
//                let cheatingGroupDuplicatesCardArray = turn.cheatingGroupDuplicatesCardArray
//                if !cheatingGroupDuplicatesCardArray.isEmpty {
////                    println("Round \(roundSubroundString): Group discard.")
//                    action.type = .Discard
//                    let theDiscardCard = cheatingGroupDuplicatesCardArray.first!
//                    action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
//                } else if (turn.cheatingAnyPlaysOrSafeDiscardsBool || turn.cheatingAnyGroupDuplicatesBool) && (numberOfCluesLeftInt > 0) {
////                    println("Round \(roundSubroundString): Another can play/discard. Give clue.")
//                    action.type = .Clue
//                } else {
//                    // If player has a card that's still in the deck, discard highest.
//                    let cheatingCardsAlsoInDeckCardArray = turn.cheatingCardsAlsoInDeckCardArray
//                    if !cheatingCardsAlsoInDeckCardArray.isEmpty {
//                        logModel.addLine("Semi-rare? No one has a play, safe discard or group duplicate.(Or no clues left.) Seed: \(optionalGame?.seedUInt32). Round \(turn.roundSubroundString).")
//                        action.type = .Discard
//                        var theDiscardCard = cheatingCardsAlsoInDeckCardArray.first!
//                        var maxNumberInt = theDiscardCard.numberInt
//                        for card in cheatingCardsAlsoInDeckCardArray {
//                            if card.numberInt > maxNumberInt {
//                                maxNumberInt = card.numberInt
//                                theDiscardCard = card
//                            }
//                        }
//                        action.targetCardIndexInt = Card.indexOptionalIntOfCardValueInArray(theDiscardCard, cardArray: currentPlayerHandCardArray)!
//                    } else {
//                        logModel.addLine("Rare warning: Discarding unique? Seed: \(optionalGame?.seedUInt32). Round \(turn.roundSubroundString).")
//                        action.type = .Discard
//                        action.targetCardIndexInt = 0
//                    }
//                }
//            }
//        }
//        return action
//    }
    
    // Whether current player can give a clue.
    func canClue(#game: Game) -> Bool {
        let numCluesLeft = game.numCluesLeft
        return numCluesLeft > 0
    }
    // Whether current player can discard.
    func canDiscard(#game: Game) -> Bool {
        let numCluesLeft = game.numCluesLeft
        return numCluesLeft < MaxClues
    }
    override init() {
        super.init()
        type = AIType.Omniscient
    }
    // Whether the deck may run out before winning.
    private func mayDeck(#game: Game) -> Bool {
        /* N.B.: A card is drawn after each play/discard, but not for clues. After the last card is drawn, each player gets a turn. If the deck is stacked against the players, they may not have enough time to win. Instead of playing/discarding normally, one may want to give a clue. This gives time for another player to play. It can also cause a different player to draw a playable card.
        so the questions are: when should we pay attention to who might draw a card? when should we pay attention to giving clues instead of safe discards? do we ever have to deal with both?
        who should draw a card: if all cards in deck are playable, may matter; for the cards that remain, does it matter who draws them? 
        the problem is that playing a card draws a card, so if player A should play but B should draw the card, it's too late; earlier, player B should've drawn player A's card; or B can discard to draw, and then player A can play
        we could just simulate all possibilities and see how it stacks up: current player either clues or plays/discards (play trumps discard), so there's only two options each time; and if play/discard, can draw 1 of X cards in deck; once last card is drawn, only the plays matter
        X playable cards in hand. Y playable cards in deck. Will take at least Z turns to play. (Depends on who picks up which card.) Have max W turns remaining. (Depends on clues.)
        Q cards that need to be played (playable is 123, not 5; but the 5 may be in hand and needs to be played eventually)
        Tough situations and how to handle:
        1) Cards in deck unplayable, but N playable cards in hands. Last card is 5.
        */
        // use old system, then note seeds that lose and try to improve (and keep seeds/decks recorded here)
        
        // simple system: N visible plays, ≤N cards in deck (want 2:2 -> 2:1 -> 2:0 -> 1:0 -> win)
        // next system had N ≥ # cards left - 1 (want 2:3 -> 1:2 -> 1:1 -> 1:0 -> win)
        
        let numCardsLeft = game.numCardsLeft
        let players = game.players
        let scorePile = game.scorePile
        let numVisiblePlays = Player.numVisiblePlays(players: players, scorePile: scorePile)
        return numCardsLeft > 0 && numVisiblePlays >= numCardsLeft
    }
}
