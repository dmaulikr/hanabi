//
//  AbstractAI.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/22/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit
let AITypeUserDefaultsKeyString = "AI-type user-defaults key string."
enum AIType: Int {
    case Omniscient = 1, PureInfo
}
class AbstractAI: NSObject {
    var name: String {
        return "Abstract AI"
    }
    var log = (UIApplication.sharedApplication().delegate as AppDelegate).logModel
    var type: AIType!
    // Best action for current turn.
    func bestAction(#game: Game) -> Action {
        return Action(.Clue)
    }
    // The turn's action has been done. The game will have updated only the basic game state. If there's something the AI needs to update, do that here. (E.g., how each player interprets the turn.)
    func updateAfterAction(#game: Game) {
    }
}
