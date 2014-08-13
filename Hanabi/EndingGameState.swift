//
//  EndingGameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/12/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class EndingGameState: AbstractGameState {
    init(startingGameState: StartingGameState, action: Action) {
//        // Initialize score.
//        for int in 1...5 {
//            if let color = Card.Color.fromRaw(int) {
//                scoreDictionary[color] = 0
//            }
//        }
//        super.init()
    }
    // Return whether the game has ended (not necessarily won).
    func isDone() -> Bool {
        // Game ends if score maxed, if out of strikes or if out of turns. The last case: when the deck is empty, each player gets one more turn.
        if totalScore() == 25 || numberOfStrikesLeftInt == 0 {
            return true
        }
        if deckCardArray.isEmpty && numberOfTurnsPlayedWithEmptyDeckInt == playerArray.count {
            return true
        }
        return false
    }
    // Change current player to next player. Rotates in a clockwise circle.
    func moveToNextPlayer() {
        currentPlayerNumberInt++
        if currentPlayerNumberInt > playerArray.count {
            currentPlayerNumberInt = 1
        }
    }
    
}
