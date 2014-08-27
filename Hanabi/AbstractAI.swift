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
    // Button-suitable string describing this AI.
    var buttonTitleString: String {
        return "AbstractAI"
    }
    var logModel = (UIApplication.sharedApplication().delegate as AppDelegate).logModel
    // Table-view-cell-suitable string describing this AI.
    var tableViewCellString: String {
        return "AbstractAI"
    }
    var type: AIType!
    // Return the best action for the given turn.
    func bestActionForTurn(turn: Turn) -> Action {
        return Action()
    }
}
