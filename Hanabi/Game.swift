//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Game: NSObject {
    var currentTurn: Turn {
        return turnArray.last!
    }
    // Score at end of last turn.
    var finalScoreInt: Int {
        let lastTurn = turnArray.last!
        return lastTurn.endingScoreInt
    }
    // Whether the game has ended (not necessarily won).
    var isDone: Bool {
        let lastTurn = turnArray.last!
        return lastTurn.gameIsDone
    }
    var numberOfPlayersInt: Int
    var numberOfTurnsInt: Int {
        return turnArray.count
    }
    // Seed used to shuffle deck.
    var seedUInt32: UInt32!
    var turnArray: [Turn] = []
    // Whether the game had a winning score.
    var wasWon: Bool {
        if finalScoreInt == 25 {
            return true
        } else {
            return false
        }
    }
    // Data for given turn. If turn end, the data is for the end of the turn (vs start).
    func dataForTurn(turnNumberInt: Int, turnEndBool: Bool, showCurrentHandBool: Bool) -> (actionString: String, discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreString: String, visibleHandsAttributedString: NSAttributedString) {
        let index = turnNumberInt - 1
        let turn = turnArray[index]
        // Could add this if needed.
        // var turnNumberInt: Int
        let data = turn.data(turnEndBool: turnEndBool, showCurrentHandBool: showCurrentHandBool)
        let actionString = data.actionString
        let discardsString = data.discardsString
        let maxNumberOfPlaysLeftInt = data.maxNumberOfPlaysLeftInt
        let numberOfCardsLeftInt = data.numberOfCardsLeftInt
        let numberOfCluesLeftInt = data.numberOfCluesLeftInt
        let numberOfPointsNeededInt = data.numberOfPointsNeededInt
        let numberOfStrikesLeftInt = data.numberOfStrikesLeftInt
        let scoreString = data.scoreString
        let visibleHandsAttributedString = data.visibleHandsAttributedString
        return (actionString, discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreString, visibleHandsAttributedString)
    }
    // Perform current action. If game not done, make next turn.
    func finishCurrentTurn() {
        let turn = currentTurn
        turn.performAction()
        if !isDone {
            let nextTurn = Turn(previousTurn: turn)
            turnArray.append(nextTurn)
        }
    }
    // Make deck. Shuffle. Make first turn.
    init(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        self.numberOfPlayersInt = numberOfPlayersInt
        super.init()
        var deck = Deck()
        deck.shuffleWithSeed(seedOptionalUInt32)
        seedUInt32 = deck.seedUInt32
        // debugging
        println("Game Deck: \(deck.string)")
        var playerArray: [Player] = []
        for playerNumberInt in 1...numberOfPlayersInt {
            let player = Player()
            player.nameString = "P\(playerNumberInt)"
            playerArray.append(player)
        }
        let turn = Turn(deck: deck, playerArray: playerArray)
        turnArray.append(turn)
    }
}
