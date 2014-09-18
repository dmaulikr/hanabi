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
        // Discard safely: Already-played card or in-hand duplicate.
        
        // Stall 1: If another can play or discard safely, then give clue.
        // Non-1 group duplicates. If any:
          // Discard: If player is in worst position (or can't give clue), then discard.
          // Stall 2: Else another should discard, so give clue.
    
        // Discard card that's still in deck. (Dangerous if remaining card(s) at end of deck.)
        // Discard unique unscored card. (Can't win.)
        let subroundString = "Round \(game.currentSubroundString)"
        let player = game.currentPlayer
        let scorePile = game.scorePile
        let hand = player.hand
        let canClue = game.canClue
        let canDiscard = game.canDiscard
        let players = game.players
        let deck = game.deck
        if player.canPlayOn(scorePile) {
//            println("\(subroundString): Play.")
            action.type = .Play
            let playableCards = player.playablesOn(scorePile)
            // Play lowest possible card. If tie, play first.
            let lowestCard = Card.lowest(playableCards).first!
            action.targetCardIndex = lowestCard.indexIn(hand)!
        } else if canClue && mayDeck(game: game) {
//            println("\(subroundString): Avoid decking: Clue.")
            action.type = .Clue
        } else if !canDiscard {
//            println("\(subroundString): Can't discard (max clues?): Clue.")
            action.type = .Clue
        } else if canDiscard && player.canDiscardSafely(scorePile: scorePile) {
//            println("\(subroundString): Discard safely.")
            action.type = .Discard
            let discardsSafe = player.discardsSafe(scorePile: scorePile)
            let card = discardsSafe.first!
            action.targetCardIndex = card.indexIn(hand)!
        } else if canClue && (Player.anotherCanPlayOn(scorePile, players: players, currentPlayer: player) || Player.anotherCanDiscardSafely(scorePile: scorePile, players: players, currentPlayer: player)) {
//             println("\(subroundString): Another can play or discard safely: Clue.")
            action.type = .Clue
        } else if player.hasNon1GroupDuplicate(players: players) {
            if (canDiscard && playerShouldDiscardNon1GroupDuplicate(player, players: players)) || !canClue {
                println("\(subroundString): Should discard non-1 group duplicate: Discard.")
                action.type = .Discard
                let card = playerNon1GroupDuplicateToDiscard(player, players: players, canClue: canClue)!
                action.targetCardIndex = card.indexIn(hand)!
            } else if canClue {
                 println("\(subroundString): Another should discard non-1 group duplicate: Clue.")
                action.type = .Clue
            }
        } else if canDiscard && player.canDiscardDeckCard(deck: deck) {
            println("\(subroundString): Discard deck card.")
            log.addLine("\(subroundString): Discarding deck card. No one has a play, safe discard or group duplicate. (Or no clues left.) Seed: \(game.seedUInt32).")
            action.type = .Discard
            let card = playerDeckCardToDiscard(player, deck: deck)
            action.targetCardIndex = card.indexIn(hand)!
        } else if canDiscard {
            println("\(subroundString): Discard unique.")
            log.addLine("\(subroundString): Discarding unique. Shouldn't happen with Omni AI. Seed: \(game.seedUInt32).")
            action.type = .Discard
            action.targetCardIndex = 0
        } else {
            println("\(subroundString): Ran out of options!")
        }
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
        // next system had N + 1 ≥ # cards left (want 2:3 -> 1:2 -> 1:1 -> 1:0 -> win)
        
        let numCardsLeft = game.numCardsLeft
        let players = game.players
        let scorePile = game.scorePile
        let numVisiblePlays = Player.numVisiblePlays(players: players, scorePile: scorePile)
        let threshold = 0
        let mayDeck = numCardsLeft > 0 && numVisiblePlays + threshold >= numCardsLeft
        return mayDeck
    }
    // Of player's cards also in the deck, the card to discard. Assumes at least one such card.
    private func playerDeckCardToDiscard(player: Player, deck: Deck) -> Card {
        // Discard highest. Why? Discarding a deck card is an issue if the remaining card is near the end of the deck. Then there's less/no time to play the cards above it. We'll minimize the impact by discarding the highest card.
        let cardsAlsoInDeck = player.cardsAlsoIn(deck)
        var discardCard = cardsAlsoInDeck.first!
        var maxNum = discardCard.num
        for card in cardsAlsoInDeck {
            let num = card.num
            if num > maxNum {
                maxNum = num
                discardCard = card
            }
        }
        return discardCard
    }
    // The group duplicate the player should discard. If can't clue, forced to discard. If none, return nil.
    private func playerNon1GroupDuplicateToDiscard(player: Player, players: [Player], canClue: Bool) -> Card? {
        let groupDuplicates = player.non1GroupDuplicates(players: players)
        for card in groupDuplicates {
            if playerShouldDiscardNon1GroupDuplicate(player, card: card, players: players) {
                return card
            }
        }
        // If no clues left, player should discard since she can't clue.
        if !canClue {
            return groupDuplicates.first
        }
        return nil
    }
    // Whether card should be discarded by player (vs. another player).
    private func playerShouldDiscardNon1GroupDuplicate(player: Player, card: Card, players: [Player]) -> Bool {
        // Get value of next card. If no one has that, might as well discard now.
        let nextCard = card.next!
        var found = false
        for player in players {
            if nextCard.isIn(player.hand) {
                found = true
            }
        }
        if !found {
            return true
        }
        // For both players with card, get # turns to play next card. (Multiple players may have next card.) Player who needs more turns should discard. If tie, might as well discard now.
        // Count after current player.
        let numPlayers = players.count
        var startIndex = (find(players, player)! + 1) % numPlayers
        var currentPlayerCount = 0
        for index in 0...numPlayers - 1 {
            let realIndex = (startIndex + index) % numPlayers
            let aPlayer = players[realIndex]
            ++currentPlayerCount
            if nextCard.isIn(aPlayer.hand) {
                break
            }
        }
        // Find other player with card.
        // Count after other player with card.
        var otherPlayer: Player!
        for index in 0...numPlayers - 1 {
            let realIndex = (startIndex + index) % numPlayers
            let aPlayer = players[realIndex]
            if card.isIn(aPlayer.hand) {
                otherPlayer = aPlayer
                break
            }
        }
        startIndex = (find(players, otherPlayer)! + 1) % numPlayers
        var otherPlayerCount = 0
        for index in 0...numPlayers - 1 {
            let realIndex = (startIndex + index) % numPlayers
            let aPlayer = players[realIndex]
            ++otherPlayerCount
            if nextCard.isIn(aPlayer.hand) {
                break
            }
        }
        return currentPlayerCount >= otherPlayerCount
    }
    // Whether given player should discard at least one group duplicate (vs. another player discarding it).
    private func playerShouldDiscardNon1GroupDuplicate(player: Player, players: [Player]) -> Bool {
        let groupDuplicates = player.non1GroupDuplicates(players: players)
        for card in groupDuplicates {
            if playerShouldDiscardNon1GroupDuplicate(player, card: card, players: players) {
                return true
            }
        }
        return false
    }
}
