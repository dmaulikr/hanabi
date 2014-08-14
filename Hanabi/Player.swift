//
//  Player.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Player: NSObject {
    var handCardArray: [Card] = []
    // String showing cards in hand.
    var handString: String {
        return Card.stringForArray(handCardArray)
    }
    var nameString: String = ""
    override func copy() -> AnyObject! {
        var player = Player()
        player.handCardArray = handCardArray
        player.nameString = nameString
        return player
    }
}
