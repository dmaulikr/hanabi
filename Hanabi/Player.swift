//
//  Player.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Player: NSObject {
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
    // Whether any card can score now.
    func canPlayOn(scorePile: ScorePile) -> Bool {
        for card in hand {
            if scorePile.canScore(card) {
                return true
            }
        }
        return false
    }
    override func copy() -> AnyObject {
        var player = Player()
        player.hand = hand
        player.nameString = nameString
        return player
    }
    // Whether any card is a safe discard.
    func hasSafeDiscard(#scorePile: ScorePile) -> Bool {
        for card in hand {
            if isSafeDiscard(card, scorePile: scorePile) {
                return true
            }
        }
        return false
    }
    // Whether given card is safe discard. I.e., already played or duplicate in hand.
    func isSafeDiscard(card: Card, scorePile: ScorePile) -> Bool {
        return scorePile.has(card) || card.isTwiceIn(hand)
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
    // Cards that can be safely discarded.
    func safeDiscards(#scorePile: ScorePile) -> [Card] {
        var safeDiscards: [Card] = []
        for card in hand {
            if isSafeDiscard(card, scorePile: scorePile) {
                safeDiscards.append(card)
            }
        }
        return safeDiscards
    }
}
