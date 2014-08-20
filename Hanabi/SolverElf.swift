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
    var logModel = (UIApplication.sharedApplication().delegate as AppDelegate).logModel
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
    // Whether to stop solving. Can be either one or multiple games.
    var stopSolvingBool = false
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
    // Reset list of solved games. Make a game. Solve it. Use bg thread to not block main.
    func solveGameWithSeed(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        stopSolvingBool = false
        gameArray = []
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let game = Game(seedOptionalUInt32: seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
            self.solveGame(game)
        }
    }
    // Play the given game to the end. Store game and notify delegate.
    func solveGame(game: Game) {
        do {
            // later might be game.solveCurrentTurn(), once elves attached to players
            self.solveCurrentTurnForGame(game)
            game.finishCurrentTurn()
        } while !game.isDone && !self.stopSolvingBool
        self.gameArray.append(game)
        // Assume delegate wants to be notified on main thread.
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.solverElfDidFinishAGame?()
            // Need this line as single-line closures return implicitly.
            return
        }
    }
    // Reset list of solved games. Make games. Solve them. Games are solved in bg thread to not block main.
    func solveGames(numberOfGames: Int, numberOfPlayersInt: Int) {
        stopSolvingBool = false
        numberOfSecondsSpentDouble = 0.0
        gameArray = []
        // Track time spent.
        let startDate = NSDate()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var numberOfSecondsToWaitToLogDouble: Double = 1.0
            for gameNumberInt in 1...numberOfGames {
                if self.stopSolvingBool {
                    break
                }
                // Give feedback in increasing intervals.
                let tempDate = NSDate()
                let numberOfSecondsSoFarDouble = tempDate.timeIntervalSinceDate(startDate)
                if numberOfSecondsSoFarDouble > numberOfSecondsToWaitToLogDouble {
                    numberOfSecondsToWaitToLogDouble = numberOfSecondsToWaitToLogDouble * 3.0
                    self.logModel.addLine("Games so far: \(self.numberOfGamesPlayedInt). Next update: \(Int(numberOfSecondsToWaitToLogDouble)) seconds.")
                }
                let game = Game(seedOptionalUInt32: nil, numberOfPlayersInt: numberOfPlayersInt)
                self.solveGame(game)
            }
            // Assume delegate wants to be notified on main thread.
            dispatch_async(dispatch_get_main_queue()) {
                let endDate = NSDate()
                self.numberOfSecondsSpentDouble = endDate.timeIntervalSinceDate(startDate)
                self.delegate?.solverElfDidFinishAllGames?()
            }
        }
    }
    // Determine best action for given turn.
    func solveTurn(turn: Turn) {
        // should really do something like currentPlayer.bestActionForGameState(startingGameState)
        // just make sure player doesn't retain the gamestate and create a retain cycle
        // turn.bestAction() -> sGS.bestAction() -> currentPlayer.bestActionForGameState(SGS: SGS) -> elf.bestActionForGameStateForPlayer(playerNumber, SGS: SGS)
        turn.optionalAction = bestActionForTurn(turn)
    }
    func stopSolving() {
        stopSolvingBool = true
    }
}
