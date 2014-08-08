//
//  GameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class GameState: NSObject {
    var currentPlayerNumberInt = 1
    var deckCardArray: [Card] = []
    var discardsCardArray: [Card] = []
    var numberOfCluesLeftInt = 8
    var numberOfStrikesLeftInt = 3
    var playerArray: [Player] = []
    // The score is a number associated with each color. Total score is the sum.
    var scoreDictionary: [Card.Color: Int] = [:]
    override init() {
        // Initialize score.
        for int in 1...5 {
            if let color = Card.Color.fromRaw(int) {
                scoreDictionary[color] = 0
            }
        }
        super.init()
    }
}
