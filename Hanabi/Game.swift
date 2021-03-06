//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//
// A single game of Hanabi.
import UIKit
let MaxClues = 8
class Game: NSObject {
    // Whether current player can give a clue.
    var canClue: Bool {
        return numCluesLeft > 0
    }
    // Whether current player can discard.
    var canDiscard: Bool {
        return numCluesLeft < MaxClues
    }
    var currentPlayer: Player {
        return currentTurn.currentPlayer
    }
    var currentSubroundString: String {
        return currentTurn.roundSubroundString
    }
    var currentTurn: Turn {
        return turnArray.last!
    }
    var deck: Deck {
        return currentTurn.deck
    }
    // Score at end of game.
    var finalScoreInt: Int {
        let lastTurn = turnArray.last!
        return lastTurn.scoreInt
    }
    // Whether the game has ended (not necessarily won).
    var isDone: Bool {
        let lastTurn = turnArray.last!
        return lastTurn.gameIsDone
    }
    // Whether it was logged that there are no extra deck cards.
    var loggedNoExtraDeckCards = false
    // Number of bad plays by end of game.
    var numberOfBadPlaysInt: Int {
        let lastTurn = turnArray.last!
        return lastTurn.numberOfBadPlaysInt
    }
    var numCardsLeft: Int {
        return currentTurn.numCardsLeft
    }
    var numCluesLeft: Int {
        return currentTurn.numCluesLeft
    }
    // Number of clues given by end of game.
    var numberOfCluesGivenInt: Int {
        let lastTurn = turnArray.last!
        return lastTurn.numberOfCluesGivenInt
    }
    // Number of discards by end of game.
    var numberOfDiscardsInt: Int {
        let lastTurn = turnArray.last!
        return lastTurn.numberOfDiscardsInt
    }
    var maxPlaysLeft: Int {
        return currentTurn.maxPlaysLeftInt
    }
    var numPlayers: Int
    var numberOfTurnsInt: Int {
        return turnArray.count
    }
    var pointsNeeded: Int {
        return currentTurn.pointsNeeded
    }
    var players: [Player] {
        return currentTurn.players
    }
    var scorePile: ScorePile {
        return currentTurn.scorePile
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
    func dataForTurn(turnNumberInt: Int, turnEndBool: Bool, showCurrentHandBool: Bool) -> (actionString: String, deckString: String, discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreString: String, visibleHandsAttributedString: NSAttributedString) {
        let index = turnNumberInt - 1
        let turn = turnArray[index]
        // Could add this if needed.
        // var turnNumberInt: Int
        let data = turn.data(turnEndBool: turnEndBool, showCurrentHandBool: showCurrentHandBool)
        let actionString = data.actionString
        let deckString = data.deckString
        let discardsString = data.discardsString
        let maxNumberOfPlaysLeftInt = data.maxNumberOfPlaysLeftInt
        let numberOfCardsLeftInt = data.numberOfCardsLeftInt
        let numberOfCluesLeftInt = data.numberOfCluesLeftInt
        let numberOfPointsNeededInt = data.numberOfPointsNeededInt
        let numberOfStrikesLeftInt = data.numberOfStrikesLeftInt
        let scoreString = data.scoreString
        let visibleHandsAttributedString = data.visibleHandsAttributedString
        return (actionString, deckString, discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreString, visibleHandsAttributedString)
    }
    // Do given action for current turn.
    func doAction(action: Action) {
        let turn = currentTurn
        turn.optionalAction = action
        turn.performAction()
    }
    // Make deck. Shuffle. Make first turn.
    init(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        self.numPlayers = numberOfPlayersInt
        super.init()
        var deck = Deck()
        deck.shuffleWithSeed(seedOptionalUInt32)
        seedUInt32 = deck.seedUInt32
        // debugging
//        println("Game Deck: \(deck.string)")
        var playerArray: [Player] = []
        for playerNumberInt in 1...numberOfPlayersInt {
            let player = Player()
            player.nameString = "P\(playerNumberInt)"
            playerArray.append(player)
        }
        let turn = Turn(deck: deck, playerArray: playerArray)
        turnArray.append(turn)
    }
    func makeNextTurn() {
        let nextTurn = Turn(previousTurn: currentTurn)
        turnArray.append(nextTurn)
    }
}
