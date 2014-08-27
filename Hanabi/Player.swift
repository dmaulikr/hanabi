//
//  Player.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Player: NSObject {
    // Player's actual hand.
    var handCardArray: [Card] = []
    // String showing cards in hand.
    var handString: String {
        return Card.stringForArray(handCardArray)
    }
    // What player knows about her hand.
    var handCardBackArray: [CardBack] {
        var handCardBackArray: [CardBack] = []
        for card in handCardArray {
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
        for card in handCardArray {
            if !Card.cardValueIsInArrayBool(card, cardArray: noDupsHandCardArray) {
                noDupsHandCardArray.append(card)
            }
        }
        return noDupsHandCardArray
    }
    override func copy() -> AnyObject! {
        var player = Player()
        player.handCardArray = handCardArray
        player.nameString = nameString
        return player
    }
}
