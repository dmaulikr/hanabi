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
    // Whether another player should play before player. E.g., having more plays and chains and deck is low.
    func anotherShouldPlayFirst(#game: Game) -> Bool {
        // On last round, each may play only one card. If a player has more plays and chains than that, should play them earlier.
        let currentPlayer = game.currentPlayer
        let scorePile = game.scorePile
        let players = game.players
        let numPlaysAndChains = currentPlayer.numPlaysAndChainsOn(scorePile, players: players)
        if numPlaysAndChains == 1 {
            // If others have extra plays and chains (> 1 play per player) and total >= # deck cards, then another should play first.
            let players = game.players
            let numAllExtraPlaysAndChains = Player.numExtraPlaysAndChainsOn(scorePile, players: players)
            let deck = game.deck
            if numAllExtraPlaysAndChains >= deck.numCardsLeft {
                // Another should play first, if enough clues to reach.
                // Note: numTurnsFromPlayerToOneWithExtraPlaysAndChains() assumes current player doesn't play first, which is intended here.
                if let numCluesNeeded = Player.numTurnsFromPlayerToOneWithExtraPlaysAndChains(currentPlayer, players: players, scorePile: scorePile) {
                    if game.numCluesLeft >= numCluesNeeded {
                        return true
                    }
                }
            }
        }
        return false
    }
/* Best action depends how close the game is. E.g., if one can play, she normally should. But if that would trigger the last round and someone still has two cards to play, she may want to clue instead. A key metric is # of deck cards left vs # points needed.
Algorithm order:
• (Clue) Why: Can't play; can't discard (max clues). Must give clue.
• Check if enough deck cards to discard safely. Yes:
  • (Play) Play lowest.
  • (Discard) Type: Doesn't increase number of turns to win. (Scored cards, or 2+ copies in hand.)
  • (Clue) Why: Another has play, or has discard that does not increase number of turns to win.
  • Check if player has discard that may increase number of turns to win. (Shared non-1s.)
    • (Discard) Type: Her discard probably doesn't increase number of turns to win. (Shared non-1.)
// depre    • (Clue) Why: Other player's discard gives better setup.
  • (Clue) Avoid unsafe discard: If other players share non-1.
  • (Discard) Deck card: highest.
  • (Discard) Unique unscored card. (Can't win.)
• No:
// log round this first happens; it'll stay this way
// • (Clue) Avoid play?: do another metric check here? make sure it's a subset of this situation
  • (Play) Play lowest.
// while the above is a repeat and could be factored out, it'll probably be refined next
  • (Clue) Avoid discard: If another has play.
// log discards; means things are getting worse
  • (Discard) Safe: Scored cards, or 2+ copies in hand.
  • (Discard) Safe but maybe bad position: Shared non-1.
  • (Discard) Deck card: highest.
  • (Discard) Unique unscored card. (Can't win.) */
    override func bestAction(#game: Game) -> Action {
        var action: Action
        let canClue = game.canClue
        let canDiscard = game.canDiscard
        let player = game.currentPlayer
        let players = game.players
        let scorePile = game.scorePile
        let subroundString = "Round \(game.currentSubroundString)"
        let anotherHasPlay = Player.anotherHasPlayOn(scorePile, players: players, currentPlayer: player)
        let anotherHasDiscardThatWillNotIncreaseTurnsToWin = Player.anotherHasDiscardThatWillNotIncreaseTurnsToWin(scorePile: scorePile, players: players, currentPlayer: player)
        let hasDiscardThatMayIncreaseTurnsToWin = player.hasDiscardThatMayIncreaseTurnsToWin(players: players)
        let hasDiscardThatWillNotIncreaseTurnsToWin = player.hasDiscardThatWillNotIncreaseTurnsToWin(scorePile: scorePile)
        let hasPlay = player.hasPlayOn(scorePile)
        if !hasPlay && !canDiscard {
//            println("\(subroundString): (Clue) Why: Can't play; can't discard (max clues). Must give clue.")
            action = Action(.Clue)
        } else if haveExtraDeckCards(game: game) {
            if hasPlay {
//              println("\(subroundString): (Play) Play lowest.")
                action = player.actionLowestPlay(scorePile: scorePile)
            } else if hasDiscardThatWillNotIncreaseTurnsToWin {
//            println("\(subroundString): (Discard) Type: Doesn't increase number of turns to win. (Scored cards, or 2+ copies in hand.)")
                action = player.actionDiscardThatWillNotIncreaseTurnsToWin(scorePile: scorePile)
            } else if canClue && (anotherHasPlay || anotherHasDiscardThatWillNotIncreaseTurnsToWin) {
//             println("\(subroundString): (Clue) Why: Another has play, or has discard that does not increase number of turns to win.")
                action = Action(.Clue)
            // WILO
            // need better explanation in names for why this is here and separate. it is separate from above because we're not sure discarding won't increase number of turns to win; however, it's separate from below because we do know discarding won't affect our ability to win in terms of having the card available; because of that, the AI is choosing here to either discard now or clue, not to discard a more dangerous card
            // so the name has to convey that discarding this card (either here or another player) is better than discarding another card; and that discarding here may increase # of turns to win
            // if we weren't giving the clue option, it'd be a similar structure (this may incr # turns to win, but we're discarding anyway); actually to keep this simple, we can do that now and just comment that we can add the clue option if deemed worth it
            } else if hasDiscardThatMayIncreaseTurnsToWin {
//                println("\(subroundString): Has discard that may increase number of turns to win.")
                let discardsThatMayIncreaseTurnsToWin = player.discardsThatMayIncreaseTurnsToWin(players: players)
                for card in discardsThatMayIncreaseTurnsToWin {
                    // implement this; can replace playerShouldDiscardNon1GroupDuplicate()
                    if !player.discardProbablyIncreasesTurnsToWin(card: card, players: players) {
//                        println("\(subroundString): (Discard) Type: Her discard probably doesn't increase number of turns to win. (Shared non-1.)")
                        //                    action = player.actionDiscard(card)
                        break
                    }
                }
                // remember canClue check: if there's
//                println("\(subroundString): (Clue) Why: Her discard probably increases number of turns to win. Other player's doesn't. (Shared non-1.)")
                action = Action(.Clue)
            } else if canClue && Player.othersShareNon1(players: players, currentPlayer: player) {
                println("\(subroundString): Others share non-1: Clue.")
                action.type = .Clue
            } else if hasDeckCard {
                //
            } else {
                println("\(subroundString): Discard unique.")
                log.addLine("\(subroundString): Discarding unique. Shouldn't happen with Omni AI. Seed: \(game.seedUInt32).")
                action.type = .Discard
                action.targetCardIndex = 0
            }
        } else {
            if hasPlay {
//              println("\(subroundString): Play.")
                action.type = .Play
                //
            } else if canClue && anotherHasPlay {
//             println("\(subroundString): Another has play: Clue.")
                action.type = .Clue
            } else if hasSafeDiscard {
//            println("\(subroundString): Safe discard.")
                action.type = .Discard
                //
            } else if sharesNon1 {
                //
            } else if hasDeckCard {
                
            } else {
                println("\(subroundString): Discard unique.")
                log.addLine("\(subroundString): Discarding unique. Shouldn't happen with Omni AI. Seed: \(game.seedUInt32).")
                action.type = .Discard
                action.targetCardIndex = 0
            }
        }
        return action
        
/* old alg; keep until new one works as good
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
    private func mayDeck(#game: Game) -> Bool {
        /* N.B.: A card is drawn after each play/discard, but not for clues. After the last card is drawn, each player gets a turn. If the deck is stacked against the players, they may not have enough time to win. Instead of playing/discarding normally, one may want to give a clue. This gives time for another player to play. It can also cause a different player to draw a playable card.
        */
        // On last turn, can play 1 to N points (N = num players). Guaranteed only 1. So if # points needed + N - 1 >= # max plays left, may deck.
        // If # visible plays >= # deck cards, may deck.
        let pointsNeeded = game.pointsNeeded
        let maxPlaysLeft = game.maxPlaysLeft
        if pointsNeeded + game.numPlayers - 1 >= maxPlaysLeft {
            return true
        }
        let numCardsLeft = game.numCardsLeft
        let players = game.players
        let scorePile = game.scorePile
        let numVisiblePlays = Player.numVisiblePlays(players: players, scorePile: scorePile)
        let threshold = 0
        if numCardsLeft > 0 && (numVisiblePlays + threshold >= numCardsLeft) {
            return true
        }
        return false
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
        // Find player with duplicate.
        var otherPlayer: Player!
        for aPlayer in players {
            if aPlayer != player && card.isIn(aPlayer.hand) {
                otherPlayer = aPlayer
                break
            }
        }
        // Look for next card. If found, get # turns from both players to card. If given player needs fewer turns, don't discard.
        // Note that multiple players may have next card.
        let nextCard = card.next!
        var nextCardFound = false
        for aPlayer in players {
            if nextCard.isIn(aPlayer.hand) {
                nextCardFound = true
                break
            }
        }
        if nextCardFound {
            let givenPlayerCount = Player.numTurnsFromPlayerToCard(player, card: nextCard, players: players)
            let otherPlayerCount = Player.numTurnsFromPlayerToCard(otherPlayer, card: nextCard, players: players)
            if givenPlayerCount < otherPlayerCount {
                return false
            }
        } else {
            // Look for previous card. If found, get # turns from card to both players. If given player needs fewer turns, don't discard.
            // Note that multiple players may have previous card.
            let previousCard = card.previous!
            var previousCardFound = false
            for aPlayer in players {
                if previousCard.isIn(aPlayer.hand) {
                    previousCardFound = true
                    break
                }
            }
            if previousCardFound {
                let givenPlayerCount = Player.numTurnsFromCardToPlayer(previousCard, player: player, players: players)
                let otherPlayerCount = Player.numTurnsFromCardToPlayer(previousCard, player: otherPlayer, players: players)
                if givenPlayerCount < otherPlayerCount {
                    return false
                }
            }
        }
        // Default: discard.
        return true
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
