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
    var handUnknownCardArray: [UnknownCard] = []
    var nameString: String = ""
    override func copy() -> AnyObject! {
        var player = Player()
        player.handCardArray = handCardArray
        player.handUnknownCardArray = handUnknownCardArray
        player.nameString = nameString
        return player
    }
}
