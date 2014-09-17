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
    // Number of playable cards in players' hands. Includes chains. Ignores duplicates.
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
