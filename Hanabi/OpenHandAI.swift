//
//  OpenHandElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/11/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

// Looks at own hand. (Cheats.)
class OpenHandAI: AbstractAI {
    override var name: String {
        return "Open Hand"
    }
    // Action to discard highest card also in deck. If tie, do first.
    private func actionDiscardHighestDeckCard(#game: Game) -> Action {
        let action = Action(.Discard)
        let player = game.currentPlayer
        let playerDeckCards = self.playerDeckCards(game: game)
        let card = Card.highest(playerDeckCards).first!
        action.targetCardIndex = card.indexIn(player.hand)!
        return action
    }
    // Whether another player should play before player. E.g., having more plays and chains and deck is low.
//    func anotherShouldPlayFirst(#game: Game) -> Bool {
//        // On last round, each may play only one card. If a player has more plays and chains than that, should play them earlier.
//        let currentPlayer = game.currentPlayer
//        let scorePile = game.scorePile
//        let players = game.players
//        let numPlaysAndChains = currentPlayer.numPlaysAndChainsOn(scorePile, players: players)
//        if numPlaysAndChains == 1 {
//            // If others have extra plays and chains (> 1 play per player) and total >= # deck cards, then another should play first.
//            let players = game.players
//            let numAllExtraPlaysAndChains = Player.numExtraPlaysAndChainsOn(scorePile, players: players)
//            let deck = game.deck
//            if numAllExtraPlaysAndChains >= deck.numCardsLeft {
//                // Another should play first, if enough clues to reach.
//                // Note: numTurnsFromPlayerToOneWithExtraPlaysAndChains() assumes current player doesn't play first, which is intended here.
//                if let numCluesNeeded = Player.numTurnsFromPlayerToOneWithExtraPlaysAndChains(currentPlayer, players: players, scorePile: scorePile) {
//                    if game.numCluesLeft >= numCluesNeeded {
//                        return true
//                    }
//                }
//            }
//        }
//        return false
//    }
    
/* Best action depends how close the game is. E.g., if one can play, she normally should. But if that would trigger the last round and someone still has two cards to play, she may want to clue instead. A key metric is # of deck cards left vs # points needed.
Algorithm: keep trying until we can do one:
• (Clue) Why: Can't play; can't discard (max clues). Must give clue.
• Check if enough deck cards to discard safely. Yes:
  • (Play) Play lowest.
  • (Discard) Type: Doesn't increase number of turns to win. (Scored cards, or 2+ copies in hand.)
  • (Clue) Why: Another has play, or has discard that does not increase number of turns to win.
  • Check if player has shared non-1. (E.g., P1 and P3 both have W2.) Depending on which shared card is discarded, the number of turns to win may increase. (E.g., turns to play [P1: W2 W3] > [P1: W2, P3: W3].) However, in most cases this should be okay, and it's not clear that we *can't* win. (C.f., discarding W4 and the other W4 is the last deck card; can't win.)
    • (Discard) Type: Shared non-1. Her discard yields same or better setup.
    • (Clue) Why: Shared non-1. Other-player's discard yields better setup.
  • (Clue) Why: Others have shared non-1 to discard; safer than deck discard.
  • (Discard) Type: Deck. Discard highest.
  • (Discard) Type: Unique unscored card. (Can't win.)
• No:
// • (Clue) Avoid play?: do another metric check here? make sure it's a subset of this situation
  • (Play) Play lowest.
  • (Clue) Why: Another has play.
  • (Discard) Type: Doesn't increase number of turns to win. (Scored cards, or 2+ copies in hand.)
    // Could mimic shared non-1 behavior above. But it may not matter at this point since any discard is bad.
  • (Discard) Type: Shared non-1.
  • (Discard) Type: Deck. Discard highest.
  • (Discard) Type: Unique unscored card. (Can't win.) */
    override func bestAction(#game: Game) -> Action {
        var action: Action?
        let canClue = game.canClue
        let canDiscard = game.canDiscard
        let player = game.currentPlayer
        let players = game.players
        let scorePile = game.scorePile
        let subroundString = "Round \(game.currentSubroundString)"
        let anotherHasPlay = Player.anotherHasPlayOn(scorePile, players: players, currentPlayer: player)
        let anotherHasDiscardThatWillNotIncreaseTurnsToWin = Player.anotherHasDiscardThatWillNotIncreaseTurnsToWin(scorePile: scorePile, players: players, currentPlayer: player)
        let hasSharedNon1 = player.hasSharedNon1(players: players)
        let hasDiscardThatWillNotIncreaseTurnsToWin = player.hasDiscardThatWillNotIncreaseTurnsToWin(scorePile: scorePile)
        let hasPlay = player.hasPlayOn(scorePile)
        let playerHasDeckCard = self.playerHasDeckCard(game: game)
        if !hasPlay && !canDiscard {
//            println("\(subroundString): (Clue) Why: Can't play; can't discard (max clues). Must give clue.")
            action = Action(.Clue)
        } else if haveExtraDeckCards(game: game) {
            if hasPlay {
//              println("\(subroundString): (Play) Play lowest.")
                action = player.actionPlayLowest(scorePile: scorePile)
            } else if hasDiscardThatWillNotIncreaseTurnsToWin {
//            println("\(subroundString): (Discard) Type: Doesn't increase number of turns to win. (Scored cards, or 2+ copies in hand.)")
                action = player.actionDiscardThatWillNotIncreaseTurnsToWin(scorePile: scorePile)
            } else if canClue && (anotherHasPlay || anotherHasDiscardThatWillNotIncreaseTurnsToWin) {
//             println("\(subroundString): (Clue) Why: Another has play, or has discard that does not increase number of turns to win.")
                action = Action(.Clue)
            } else if hasSharedNon1 {
                action = player.actionDiscardSharedNon1ThatYieldsAsGoodASetup(players: players)
                if action != nil {
//                    println("\(subroundString): (Discard) Type: Shared non-1. Her discard yields same or better setup.")
                } else if canClue {
                    println("\(subroundString): (Clue) Why: Shared non-1. Other-player's discard yields better setup.")
                    action = Action(.Clue)
                } else {
                    // For simplicity, discard first shared non-1.
                    println("\(subroundString): (Discard) Type: Shared non-1. Can't clue. Discard first shared.")
                    action = player.actionDiscardFirstSharedNon1(players: players)
                }
            } else if canClue && Player.othersHaveSharedNon1(players: players, currentPlayer: player) {
//                println("\(subroundString): (Clue) Why: Others have shared non-1 to discard; safer than deck discard.")
                action = Action(.Clue)
            } else if playerHasDeckCard {
//                println("\(subroundString): (Discard) Type: Deck. Discard highest.")
                action = actionDiscardHighestDeckCard(game: game)
            } else {
//                println("\(subroundString): (Discard) Type: Unique unscored card. (Can't win.)")
                log.addLine("\(subroundString): Discarding unique. Shouldn't happen with Omni AI. Seed: \(game.seedUInt32).")
                action = Action(.Discard)
                action?.targetCardIndex = 0
            }
        } else {
            if !game.loggedNoExtraDeckCards {
                log.addLine("\(subroundString): No extra deck cards. Seed: \(game.seedUInt32).")
                game.loggedNoExtraDeckCards = true
            }
            if hasPlay {
//              println("\(subroundString): (Play) Play lowest.")
                action = player.actionPlayLowest(scorePile: scorePile)
            } else if canClue && anotherHasPlay {
//             println("\(subroundString): (Clue) Why: Another has play.")
                action = Action(.Clue)
            } else if hasDiscardThatWillNotIncreaseTurnsToWin {
//            println("\(subroundString): (Discard) Type: Doesn't increase number of turns to win. (Scored cards, or 2+ copies in hand.)")
                log.addLine("\(subroundString): (Discard) Type: Doesn't increase number of turns to win. (Scored cards, or 2+ copies in hand.)")
                action = player.actionDiscardThatWillNotIncreaseTurnsToWin(scorePile: scorePile)
            } else if hasSharedNon1 {
                // For simplicity, discard first shared non-1.
                println("\(subroundString): Type: Shared non-1.")
                action = player.actionDiscardFirstSharedNon1(players: players)
            } else if playerHasDeckCard {
//                println("\(subroundString): (Discard) Type: Deck. Discard highest.")
                log.addLine("\(subroundString): (Discard) Type: Deck. Discard highest.")
                action = actionDiscardHighestDeckCard(game: game)
            } else {
//                println("\(subroundString): (Discard) Type: Unique unscored card. (Can't win.)")
                log.addLine("\(subroundString): (Discard) Type: Unique unscored card. (Can't win.)")
                action = Action(.Discard)
                action?.targetCardIndex = 0
            }
        }
        return action!
        
/* old alg; keep until new one works as well
        // Playables. If any:
          // Stall: If another should play first (uneven playables distribution), give clue.
          // Play: Else, play lowest card.
        // Stall: If visible plays and in danger of decking, give clue.
        // Can't discard: If max clues then can't discard, so give clue.
        // Discard safely: Already-played card or in-hand duplicate.
        // Stall: If another can play or discard safely, then give clue.
        // Player has non-1 group duplicate:
          // Discard: If player is in worst position (or can't give clue), then discard.
          // Stall: Else another should discard, so give clue.
        // Stall: Other players have non-1 group duplicate, so give clue.
        // Discard card that's still in deck. (Dangerous if remaining card(s) at end of deck.)
        // Discard unique unscored card. (Can't win.)
        let subroundString = "Round \(game.currentSubroundString)"
        let player = game.currentPlayer
        let scorePile = game.scorePile
        let hand = player.hand
        let canClue = game.canClue
        let players = game.players
        let numVisiblePlays = Player.numVisiblePlays(players: players, scorePile: scorePile)
        let canDiscard = game.canDiscard
        let deck = game.deck
        if player.canPlayOn(scorePile) {
            if canClue && anotherShouldPlayFirst(game: game) {
                println("\(subroundString): Uneven playables. Stall via clue.")
                action.type = .Clue
            } else {
//              println("\(subroundString): Play.")
                action.type = .Play
                let playableCards = player.playsOn(scorePile)
                // Play lowest possible card. If tie, play first.
                let lowestCard = Card.lowest(playableCards).first!
                action.targetCardIndex = lowestCard.indexIn(hand)!
            }
        } else if canClue && numVisiblePlays > 0 && mayDeck(game: game) {
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
        } else if canClue && Player.othersHaveNon1GroupDuplicate(players: players, currentPlayer: player) {
            println("\(subroundString): Others share non-1 group duplicate: Clue.")
            action.type = .Clue
        } else if canDiscard && player.canDiscardDeckCard(deck: deck) {
            println("\(subroundString): Discard deck card.")
            log.addLine("\(subroundString): Discarding deck card. Seed: \(game.seedUInt32).")
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
*/
    }
    // Whether there are enough deck cards to discard and still have time to win.
    // To win, we still need X points. Each point requires 1 deck card so we don't run out of turns. The last round also gives some room. Extra deck cards means we can still discard and win.
    private func haveExtraDeckCards(#game: Game) -> Bool {
        // After the last card is drawn, each player gets 1 action. So, we can gain up to P points (P = # Players). However, if the remaining points are not in order or are distributed unevenly, we can gain as few as 1 point. (Assuming the remaining points are held when the last card is drawn, at least 1 card will always be playable.)
        let numDeckCardsLeft = game.numCardsLeft
        let pointsInLastRound = 1
        let pointsNeeded = game.pointsNeeded
        // E.g., 3 cards left, need 3 points.
        return numDeckCardsLeft + pointsInLastRound > pointsNeeded
    }
    override init() {
        super.init()
        type = AIType.Omniscient
    }
    
    // Whether the deck may run out before winning.
//    private func mayDeck(#game: Game) -> Bool {
//        /* N.B.: A card is drawn after each play/discard, but not for clues. After the last card is drawn, each player gets a turn. If the deck is stacked against the players, they may not have enough time to win. Instead of playing/discarding normally, one may want to give a clue. This gives time for another player to play. It can also cause a different player to draw a playable card.
//        */
//        // On last turn, can play 1 to N points (N = num players). Guaranteed only 1. So if # points needed + N - 1 >= # max plays left, may deck.
//        // If # visible plays >= # deck cards, may deck.
//        let pointsNeeded = game.pointsNeeded
//        let maxPlaysLeft = game.maxPlaysLeft
//        if pointsNeeded + game.numPlayers - 1 >= maxPlaysLeft {
//            return true
//        }
//        let numCardsLeft = game.numCardsLeft
//        let players = game.players
//        let scorePile = game.scorePile
//        let numVisiblePlays = Player.numVisiblePlays(players: players, scorePile: scorePile)
//        let threshold = 0
//        if numCardsLeft > 0 && (numVisiblePlays + threshold >= numCardsLeft) {
//            return true
//        }
//        return false
//    }
    
    
    // Current player's cards that are also in the deck. Note that this AI shouldn't have direct access to the deck, e.g. what card's on the bottom. However, she can know what cards are in the deck by process of elimination.
    private func playerDeckCards(#game: Game) -> [Card] {
        var playerDeckCards: [Card] = []
        let player = game.currentPlayer
        let deck = game.deck
        for card in player.hand {
            if card.isIn(deck.cards) {
                playerDeckCards.append(card)
            }
        }
        return playerDeckCards
    }
    // Whether current player has at least one card also in deck. Note that this AI shouldn't have direct access to the deck, e.g. what card's on the bottom. However, she can know what cards are in the deck by process of elimination.
    private func playerHasDeckCard(#game: Game) -> Bool {
        let player = game.currentPlayer
        let deck = game.deck
        for card in player.hand {
            if card.isIn(deck.cards) {
                return true
            }
        }
        return false
    }
    // Whether card should be discarded by player (vs. another player).
//    private func playerShouldDiscardNon1GroupDuplicate(player: Player, card: Card, players: [Player]) -> Bool {
//        // Find player with duplicate.
//        var otherPlayer: Player!
//        for aPlayer in players {
//            if aPlayer != player && card.isIn(aPlayer.hand) {
//                otherPlayer = aPlayer
//                break
//            }
//        }
//        // Look for next card. If found, get # turns from both players to card. If given player needs fewer turns, don't discard.
//        // Note that multiple players may have next card.
//        let nextCard = card.next!
//        var nextCardFound = false
//        for aPlayer in players {
//            if nextCard.isIn(aPlayer.hand) {
//                nextCardFound = true
//                break
//            }
//        }
//        if nextCardFound {
//            let givenPlayerCount = Player.numTurnsFromPlayerToCard(player, card: nextCard, players: players)
//            let otherPlayerCount = Player.numTurnsFromPlayerToCard(otherPlayer, card: nextCard, players: players)
//            if givenPlayerCount < otherPlayerCount {
//                return false
//            }
//        } else {
//            // Look for previous card. If found, get # turns from card to both players. If given player needs fewer turns, don't discard.
//            // Note that multiple players may have previous card.
//            let previousCard = card.previous!
//            var previousCardFound = false
//            for aPlayer in players {
//                if previousCard.isIn(aPlayer.hand) {
//                    previousCardFound = true
//                    break
//                }
//            }
//            if previousCardFound {
//                let givenPlayerCount = Player.numTurnsFromCardToPlayer(previousCard, player: player, players: players)
//                let otherPlayerCount = Player.numTurnsFromCardToPlayer(previousCard, player: otherPlayer, players: players)
//                if givenPlayerCount < otherPlayerCount {
//                    return false
//                }
//            }
//        }
//        // Default: discard.
//        return true
//    }
}
