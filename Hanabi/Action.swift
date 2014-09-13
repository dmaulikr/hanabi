//
//  Action.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/7/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//
// Action is either give a clue, play a card or discard a card.

import UIKit

class Action: NSObject {
    enum Type: Int {
        case Clue, Play, Discard
    }
    var type: Type = .Clue
    // Index of card in player's hand to play/discard.
    var targetCardIndex = 0
}
