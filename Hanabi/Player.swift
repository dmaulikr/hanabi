//
//  Player.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Player: NSObject {
    // Whether another player has at least one card that can be discarded safely.
    class func anotherCanDiscardSafely(#scorePile: ScorePile, players: [Player], currentPlayer: Player) -> Bool {
        for player in players {
            if player != currentPlayer {
                for card in player.hand {
                    if player.canDiscardSafely(card, scorePile: scorePile) {
                        return true
                    }
                }
            }
        }
        return false
    }
    // Whether another player has at least one card that can score now.
    class func anotherCanPlayOn(scorePile: ScorePile, players: [Player], currentPlayer: Player) -> Bool {
        for player in players {
            if player != currentPlayer {
                for card in player.hand {
                    if scorePile.canScore(card) {
                        return true
                    }
                }
            }
        }
        return false
    }
    // Whether the given card is in any players' hand.
    class func cardIsInAHand(card: Card, players: [Player]) -> Bool {
        for player in players {
            let hand = player.hand
            if card.isIn(hand) {
                return true
            }
        }
        return false
    }
    // Number of playable cards in players' hands > 1 per player. Includes chains. Duplicates counted once, preferably for a player with no plays.
    // Note: This is implemented not exactly but is deterministic. In particular, a duplicate may be counted as an extra play when it could be assigned a player with no plays. (E.g., while counting, a duplicate may be held by two players with no plays, then later the assigned player is assigned another play.) Depending on how the cards are played, the minimum number could be slightly less.
    class func numExtraVisiblePlays(#players: [Player], scorePile: ScorePile) -> Int {
        var numExtraVisiblePlays = 0
        // For each color, go up the unscored values to see how many plays we can make. Note which player has card. If multiple players, assign to player with 0 plays, else earliest player.
        var playersNumVisiblePlays: [Player: Int] = [:]
        for player in players {
            playersNumVisiblePlays[player] = 0
        }
        var colorInt = 1
        while let color = Card.color(int: colorInt) {
            // If the next card is in a hand, go up the chain.
            var value = scorePile.value(color: color) + 1
            while value <= 5 {
                let card = Card(color: color, num: value)
                let playersWithCard = Player.playersWithCard(card, players: players)
                let numPlayersWithCard = playersWithCard.count
                if numPlayersWithCard == 0 {
                    break
                } else {
                    ++value
                    if numPlayersWithCard == 1 {
                        let player = playersWithCard.first!
                        playersNumVisiblePlays[player] = playersNumVisiblePlays[player]! + 1
                    } else {
                        // Assign to first player with 0 plays, else first player.
                        // Note: Possible that two players have 0 plays at this point, but one player will get a play later. So this isn't exact.
                        var playerToAssign = playersWithCard.first!
    //                    var numPlayersWithNoPlays = 0
                        for player in playersWithCard {
                            if playersNumVisiblePlays[player] == 0 {
    //                            ++numPlayersWithNoPlays
                                playerToAssign = player
                                playersNumVisiblePlays[playerToAssign] = playersNumVisiblePlays[playerToAssign]! + 1
                                break
                            }
                        }
//                    if numPlayersWithNoPlays >= 2 {
//                        log
//                    }
                    }
                }
            }
            ++colorInt
        }
        // Count extras.
        for (player, numVisiblePlays) in playersNumVisiblePlays {
            if numVisiblePlays > 1 {
                numExtraVisiblePlays += numVisiblePlays - 1
            }
        }
        return numExtraVisiblePlays
    }
    // Min number of turns from any player having card to given player. (Min 1.) Assumes card exists.
    class func numTurnsFromCardToPlayer(card: Card, player: Player, players: [Player]) -> Int {
        var numTurns = 0
        let numPlayers = players.count
        // Start before player, then make index valid.
        let lastIndex = numPlayers - 1
        let startIndex = ((find(players, player)! - 1 - lastIndex) % numPlayers) + lastIndex
        for index in 0...numPlayers - 1 {
            // Decrease index, then make valid.
            let realIndex = ((startIndex - index - lastIndex) % numPlayers) + lastIndex
            let aPlayer = players[realIndex]
            ++numTurns
            if card.isIn(aPlayer.hand) {
                break
            }
        }
        return numTurns
    }
    // Number of turns from player to first player having card. (Min 1.) Assumes card exists.
    class func numTurnsFromPlayerToCard(player: Player, card: Card, players: [Player]) -> Int {
        var numTurns = 0
        let numPlayers = players.count
        // Start after player, then make index valid. 
        let startIndex = (find(players, player)! + 1) % numPlayers
        for index in 0...numPlayers - 1 {
            // Increase index, then make valid.
            let realIndex = (startIndex + index) % numPlayers
            let aPlayer = players[realIndex]
            ++numTurns
            if card.isIn(aPlayer.hand) {
                break
            }
        }
        return numTurns
    }
    // Number of turns from player to first player with extra visible play. In this case, an extra visible play means that player can play now (even if given player doesn't) and has >= 2 plays (if given player plays eventually). If no such player, return nil.
    class func numTurnsFromPlayerToOneWithExtraVisiblePlays(player: Player, players: [Player], scorePile: ScorePile) -> Int? {
        var numTurns: Int? = 0
        let numPlayers = players.count
        // Start after player, then make index valid.
        let startIndex = (find(players, player)! + 1) % numPlayers
        // Check other players, in order.
        for index in 0...numPlayers - 2 {
            // Increase index, then make valid.
            let realIndex = (startIndex + index) % numPlayers
            let aPlayer = players[realIndex]
            numTurns = numTurns! + 1
            if aPlayer.canPlayOn(scorePile) && aPlayer.numVisiblePlays(players: players, scorePile: scorePile) >= 2 {
                return numTurns
            }
        }
        return nil
    }
    // Number of playable cards in players' hands. Includes chains. Counts duplicates once.
    class func numVisiblePlays(#players: [Player], scorePile: ScorePile) -> Int {
        var numVisiblePlays = 0
        // For each color, go up the unscored values to see how many plays we can make.
        var colorInt = 1
        while let color = Card.color(int: colorInt) {
            // If the next card is in a hand, go up the chain.
            var value = scorePile.value(color: color) + 1
            while value <= 5 {
                let card = Card(color: color, num: value)
                if Player.cardIsInAHand(card, players: players) {
                    ++numVisiblePlays
                    ++value
                } else {
                    break
                }
            }
            ++colorInt
        }
        return numVisiblePlays
    }
    // If multiple, return first.
    class func playerWithCard(card: Card, players: [Player]) -> Player? {
        for player in players {
            let hand = player.hand
            if card.isIn(hand) {
                return player
            }
        }
        return nil
    }
    // If none, return empty array.
    class func playersWithCard(card: Card, players: [Player]) -> [Player] {
        var playersWithCard: [Player] = []
        for player in players {
            if card.isIn(player.hand) {
                playersWithCard.append(player)
            }
        }
        return playersWithCard
    }
    // Actual hand.
    var hand: [Card] = []
    // String showing cards in hand.
    var handString: String {
        return Card.stringForArray(hand)
    }
    // What player knows about her hand.
    var handCardBackArray: [CardBack] {
        var handCardBackArray: [CardBack] = []
        for card in hand {
            if let cardBack = card.optionalCardBack {
                handCardBackArray.append(cardBack)
            }
        }
        return handCardBackArray
    }
    var nameString: String = ""
    // Hand, with duplicate cards removed.
    var noDupsHandCardArray: [Card] {
        var noDupsHandCardArray: [Card] = []
        for card in hand {
            if !card.isIn(noDupsHandCardArray) {
                noDupsHandCardArray.append(card)
            }
        }
        return noDupsHandCardArray
    }
    // Whether at least one card in hand is also in deck.
    func canDiscardDeckCard(#deck: Deck) -> Bool {
        for card in hand {
            if card.isIn(deck.cards) {
                return true
            }
        }
        return false
    }
    // Whether card can be discarded safely. I.e., was already played or duplicate is in hand.
    private func canDiscardSafely(card: Card, scorePile: ScorePile) -> Bool {
        return scorePile.has(card) || card.isTwiceIn(hand)
    }
    // Whether at least one card can be discarded safely.
    func canDiscardSafely(#scorePile: ScorePile) -> Bool {
        for card in hand {
            if canDiscardSafely(card, scorePile: scorePile) {
                return true
            }
        }
        return false
    }
    // Whether at least one card can score now.
    func canPlayOn(scorePile: ScorePile) -> Bool {
        for card in hand {
            if scorePile.canScore(card) {
                return true
            }
        }
        return false
    }
    // Cards also in deck.
    func cardsAlsoIn(deck: Deck) -> [Card] {
        var cards: [Card] = []
        for card in hand {
            if card.isIn(deck.cards) {
                cards.append(card)
            }
        }
        return cards
    }
    override func copy() -> AnyObject {
        var player = Player()
        player.hand = hand
        player.nameString = nameString
        return player
    }
    // Cards that can be discarded safely.
    func discardsSafe(#scorePile: ScorePile) -> [Card] {
        var discardsSafe: [Card] = []
        for card in hand {
            if canDiscardSafely(card, scorePile: scorePile) {
                discardsSafe.append(card)
            }
        }
        return discardsSafe
    }
    // Whether at least one card is also in another player's hand. Ignore 1s. (Context: Determine who should discard group 2/3/4s.)
    func hasNon1GroupDuplicate(#players: [Player]) -> Bool {
        for card in hand {
            if isNon1GroupDuplicate(card: card, players: players) {
                return true
            }
        }
        return false
    }
    // Whether given card is in this and another's hand. Ignore 1s. (Context: Determine who should discard group 2/3/4s.)
    private func isNon1GroupDuplicate(#card: Card, players: [Player]) -> Bool {
        if card.isIn(hand) && card.num != 1 {
            for otherPlayer in players {
                if otherPlayer != self && card.isIn(otherPlayer.hand) {
                    return true
                }
            }
        }
        return false
    }
    // Cards also in another player's hand. Ignore 1s. (Context: Determine who should discard group 2/3/4s.)
    func non1GroupDuplicates(#players: [Player]) -> [Card] {
        var groupDuplicates: [Card] = []
        for card in hand {
            if isNon1GroupDuplicate(card: card, players: players) {
                groupDuplicates.append(card)
            }
        }
        return groupDuplicates
    }
    // Number of playable cards in hand. Includes chains from self and other players. Counts duplicates once.
    func numVisiblePlays(#players: [Player], scorePile: ScorePile) -> Int {
        var numVisiblePlays = 0
        // For each color, go up the unscored values to see if players have card. If this player has card, count that.
        var colorInt = 1
        while let color = Card.color(int: colorInt) {
            // While next card is in a hand, go up the chain.
            var value = scorePile.value(color: color) + 1
            while value <= 5 {
                let card = Card(color: color, num: value)
                if Player.cardIsInAHand(card, players: players) {
                    if card.isIn(hand) {
                        ++numVisiblePlays
                    }
                    ++value
                } else {
                    break
                }
            }
            ++colorInt
        }
        return numVisiblePlays
    }
    // Cards that can score now.
    func playablesOn(scorePile: ScorePile) -> [Card] {
        var playableCards: [Card] = []
        for card in hand {
            if scorePile.canScore(card) {
                playableCards.append(card)
            }
        }
        return playableCards
    }
}
