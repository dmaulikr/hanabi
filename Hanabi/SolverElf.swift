//
//  SolverElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/5/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

@objc protocol SolverElfDelegate {
    // Sent when done solving.
    optional func solverElfDidFinishAGame()
    optional func solverElfDidFinishAllGames()
}

private var myContext = 0

class SolverElf: NSObject {
    // Average for currently solved games.
    var averageScoreFloat: Float {
        var totalScoresInt = 0
        for game in gameArray {
            totalScoresInt += game.finalScoreInt
        }
        return Float(totalScoresInt) / Float(numberOfGamesPlayedInt)
    }
    // Various data on lost games.
    var dataForGamesLost: (averageCluesGivenFloat: Float, averageNumberOfBadPlaysFloat: Float, averageNumberOfDiscardsFloat: Float, numberInt: Int, percentFloat: Float, seedArray: [UInt32]) {
        let averageCluesGivenFloat = averageXIntInLostGamesFloat(xIntKey: "numberOfCluesGivenInt")
        let averageNumberOfBadPlaysFloat = averageXIntInLostGamesFloat(xIntKey: "numberOfBadPlaysInt")
        let averageNumberOfDiscardsFloat = averageXIntInLostGamesFloat(xIntKey: "numberOfDiscardsInt")
        var seedArray: [UInt32] = []
        for game in gameArray {
            if !game.wasWon {
                seedArray.append(game.seedUInt32)
            }
        }
        let percentFloat = Float(numberOfGamesLostInt * 100) / Float(numberOfGamesPlayedInt)
        return (averageCluesGivenFloat, averageNumberOfBadPlaysFloat, averageNumberOfDiscardsFloat, numberOfGamesLostInt, percentFloat, seedArray)
    }
    // Various data on won games.
    var dataForGamesWon: (averageCluesGivenFloat: Float, averageMaxPlaysLeftFloat: Float, averageNumberOfBadPlaysFloat: Float, averageNumberOfDiscardsFloat: Float) {
        let averageCluesGivenFloat = averageXIntInWonGamesFloat(xIntKey: "numberOfCluesGivenInt")
        // Average number of "max plays left" in games that were won.
        let averageMaxPlaysLeftFloat = averageXIntInWonGamesFloat(xIntKey: "numberOfMaxPlaysLeftInt")
        let averageNumberOfBadPlaysFloat = averageXIntInWonGamesFloat(xIntKey: "numberOfBadPlaysInt")
        let averageNumberOfDiscardsFloat = averageXIntInWonGamesFloat(xIntKey: "numberOfDiscardsInt")
        return (averageCluesGivenFloat, averageMaxPlaysLeftFloat, averageNumberOfBadPlaysFloat, averageNumberOfDiscardsFloat)
    }
    // Number of seconds spent solving, average seconds per game.
    var dataForSecondsSpent: (numberDouble: Double, averageDouble: Double) {
        let numberDouble = numberOfSecondsSpentDouble
        let averageDouble = numberDouble / Double(numberOfGamesPlayedInt)
        return (numberDouble, averageDouble)
    }
    var delegate: SolverElfDelegate?
    // Games solved.
    var gameArray: [Game] = []
    var numberOfGamesLostInt: Int {
        return numberOfGamesPlayedInt - numberOfGamesWonInt
    }
    var numberOfGamesPlayedInt: Int {
        return gameArray.count
    }
    var numberOfGamesWonInt: Int {
        var numberOfGamesWonInt = 0
        for game in gameArray {
            if game.wasWon {
                numberOfGamesWonInt++
            }
        }
        return numberOfGamesWonInt
    }
    // Number of seconds spent solving the current games.
    var numberOfSecondsSpentDouble = 0.0
    // Number of turns the first solved game took. If no game, return nil.
    var numberOfTurnsOptionalIntForFirstGame: Int? {
        if let game = gameArray.first {
            return game.numberOfTurnsInt
        } else {
            return nil
        }
    }
    // Seed used to make first game. Assumes exists.
    var seedUInt32ForFirstGame: UInt32 {
        return gameArray.first!.seedUInt32
    }
    // For the game property corresponding to the given key, the average for all lost games. If no lost games, returns 0. Property must be an Int.
    func averageXIntInLostGamesFloat(# xIntKey: String) -> Float {
        var totalXIntInLostGames = 0
        for game in gameArray {
            if !game.wasWon {
                totalXIntInLostGames += game.valueForKey(xIntKey) as Int
            }
        }
        if numberOfGamesLostInt == 0 {
            return 0
        } else {
            return Float(totalXIntInLostGames) / Float(numberOfGamesLostInt)
        }
    }
    // For the game property corresponding to the given key, the average for all won games. If no won games, returns 0. Property must be an Int.
    func averageXIntInWonGamesFloat(# xIntKey: String) -> Float {
        var totalXIntInWonGames = 0
        for game in gameArray {
            if game.wasWon {
                totalXIntInWonGames += game.valueForKey(xIntKey) as Int
            }
        }
        if numberOfGamesWonInt == 0 {
            return 0
        } else {
            return Float(totalXIntInWonGames) / Float(numberOfGamesWonInt)
        }
    }
    // Return the best action for the given turn.
    func bestActionForTurn(turn: Turn) -> Action {
//        let alwaysDiscardElf = AlwaysDiscardElf()
//        let action = alwaysDiscardElf.bestActionForTurn(turn)
        let openHandElf = OpenHandElf()
        let action = openHandElf.bestActionForTurn(turn)
        return action
    }
    // Data for given turn for given game. If turn end, the data is for the end of the turn (vs start). As we're bundling a lot of data here, this should be used only for reporting and not for solving many games at once.
    func dataForTurnForGame(gameNumberInt: Int, turnNumberInt: Int, turnEndBool: Bool, showCurrentHandBool: Bool) -> (actionString: String, deckString: String, discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreString: String, visibleHandsAttributedString: NSAttributedString) {
        let index = gameNumberInt - 1
        let game = gameArray[index]
        // Could add this if needed.
        // var gameNumberInt: Int
        let dataForTurn = game.dataForTurn(turnNumberInt, turnEndBool: turnEndBool, showCurrentHandBool: showCurrentHandBool)
        let actionString = dataForTurn.actionString
        let deckString = dataForTurn.deckString
        let discardsString = dataForTurn.discardsString
        let maxNumberOfPlaysLeftInt = dataForTurn.maxNumberOfPlaysLeftInt
        let numberOfCardsLeftInt = dataForTurn.numberOfCardsLeftInt
        let numberOfCluesLeftInt = dataForTurn.numberOfCluesLeftInt
        let numberOfPointsNeededInt = dataForTurn.numberOfPointsNeededInt
        let numberOfStrikesLeftInt = dataForTurn.numberOfStrikesLeftInt
        let scoreString = dataForTurn.scoreString
        let visibleHandsAttributedString = dataForTurn.visibleHandsAttributedString
        return (actionString, deckString, discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreString, visibleHandsAttributedString)
    }
    // String for the round and subround for the given turn. (E.g., in a 3-player game, turn 4 = round 2.1.)
    func roundSubroundStringForTurnForFirstGame(turnNumberInt: Int) -> String {
        let game = gameArray.first!
        let numberOfPlayersInt = game.numberOfPlayersInt
        let string = roundSubroundStringForTurn(turnNumberInt, numberOfPlayersInt: numberOfPlayersInt)
        return string
    }
    // Determine best action for current turn. Do it.
    func solveCurrentTurnForGame(game: Game) {
        solveTurn(game.currentTurn)
    }
    // Reset list of solved games. Make a game. Solve it.
    func solveGameWithSeed(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        gameArray = []
        let game = Game(seedOptionalUInt32: seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
        solveGame(game)
    }
    // Play the given game to the end. Store game and notify delegate.
    func solveGame(game: Game) {
        do {
            // later might be game.solveCurrentTurn(), once elves attached to players
            solveCurrentTurnForGame(game)
            game.finishCurrentTurn()
        } while !game.isDone
        gameArray.append(game)
        delegate?.solverElfDidFinishAGame?()
    }
    // Reset list of solved games. Make games. Solve them.
    func solveGames(numberOfGames: Int, numberOfPlayersInt: Int) {
        numberOfSecondsSpentDouble = 0.0
        gameArray = []
        // Track time spent.
        let startDate = NSDate()
        // Report every x time units. 10 seconds? increasing intervals?
        // can set a repeating timer to print count of gameArray
        // can notify delegate
        // logTextView: ("Games played: \(gameArray.count)")
        for gameNumber in 1...numberOfGames {
            let game = Game(seedOptionalUInt32: nil, numberOfPlayersInt: numberOfPlayersInt)
            solveGame(game)
        }
        let endDate = NSDate()
        numberOfSecondsSpentDouble = endDate.timeIntervalSinceDate(startDate)
        delegate?.solverElfDidFinishAllGames?()
    }
    // Determine best action for given turn.
    func solveTurn(turn: Turn) {
        // should really do something like currentPlayer.bestActionForGameState(startingGameState)
        // just make sure player doesn't retain the gamestate and create a retain cycle
        // turn.bestAction() -> sGS.bestAction() -> currentPlayer.bestActionForGameState(SGS: SGS) -> elf.bestActionForGameStateForPlayer(playerNumber, SGS: SGS)
        turn.optionalAction = bestActionForTurn(turn)
    }
    func stopSolving() {
    }
}
