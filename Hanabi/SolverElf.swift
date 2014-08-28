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
    var aiArray: [AbstractAI] = []
    // Average for currently solved games.
    var averageScoreFloat: Float {
        var totalScoresInt = 0
        for game in gameArray {
            totalScoresInt += game.finalScoreInt
        }
        return Float(totalScoresInt) / Float(numberOfGamesPlayedInt)
    }
    // AI for solving games. If not set, use Omniscient.
    var currentAI: AbstractAI {
        get {
            let aiInt = NSUserDefaults.standardUserDefaults().integerForKey(AITypeUserDefaultsKeyString)
            if let aiType = AIType.fromRaw(aiInt) {
                return aiForType(aiType)
            } else {
                return aiForType(AIType.Omniscient)
            }
        }
        set(newAI) {
            let aiInt = newAI.type.toRaw()
            NSUserDefaults.standardUserDefaults().setInteger(aiInt, forKey: AITypeUserDefaultsKeyString)
        }
    }
    var currentAIButtonTitleString: String {
        return currentAI.buttonTitleString
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
    var numberOfAIs: Int {
        return aiArray.count
    }
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
    // AI for the given number. AIs are in an undefined order.
    func aiForNumberInt(numberInt: Int) -> AbstractAI {
        let indexInt = numberInt - 1
        return aiArray[indexInt]
    }
    // AI for the given AI type. If type not found, return first value.
    func aiForType(aiType: AIType) -> AbstractAI {
        for ai in aiArray {
            if ai.type == aiType {
                return ai
            }
        }
        println("Warning: AI type not found: \(aiType.toRaw()).")
        return aiArray[0]
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
        let action = currentAI.bestActionForTurn(turn)
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
    override init() {
        super.init()
        aiArray.append(OmniscientAI())
        aiArray.append(PureInfoAI())
    }
    // Order number for the given AI. First number is 1. If AI not found, return 1.
    func numberIntForAI(ai: AbstractAI) -> Int {
        for index in 0...aiArray.count {
            let ai2 = aiArray[index]
            if ai2 == ai {
                return index + 1
            }
        }
        return 1
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
    // Play the given game to the end. Store game and notify delegate.
    func solveGame(game: Game) {
//        currentAI.optionalGame = game
        do {
            // get current turn
            game.currentTurn
            // determine best action
            //currentAI.bestActionForTurn(turn)
            
//            let action = currentAI.bestActionForCurrentTurn(game)
            
            // do action
            // game.doActionForCurrentTurn(action)
            // solverElf is game.del? 
            // gameDidDoAction() -> currentAI.updateAfterAction(game)
            //currentAI.bestActionForCurrentTurn
            // if not done, make next turn
            // if not done, game.makeNextTurn()
            solveCurrentTurnForGame(game)
            game.finishCurrentTurn()
        } while !game.isDone && !stopSolvingBool
        self.gameArray.append(game)
        // Assume delegate wants to be notified on main thread.
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.solverElfDidFinishAGame?()
            // Need this line as single-line closures return implicitly.
            return
        }
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
        turn.optionalAction = bestActionForTurn(turn)
    }
    func stopSolving() {
        stopSolvingBool = true
    }
}
