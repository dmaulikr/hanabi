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
    private var ais: [AbstractAI] = []
    // For all games.
    var avgScore: Float {
        var total = 0
        for game in games {
            total += game.finalScoreInt
        }
        return Float(total) / Float(numGamesPlayed)
    }
    // AI for solving games. If not set, use Omniscient.
    var currentAI: AbstractAI {
        get {
            let aiRawValue = NSUserDefaults.standardUserDefaults().integerForKey(AITypeUserDefaultsKeyString)
            if let aiType = AIType.fromRaw(aiRawValue) {
                return aiForType(aiType)
            } else {
                return aiForType(AIType.Omniscient)
            }
        }
        set(newAI) {
            let aiRawValue = newAI.type.toRaw()
            NSUserDefaults.standardUserDefaults().setInteger(aiRawValue, forKey: AITypeUserDefaultsKeyString)
        }
    }
    var delegate: SolverElfDelegate?
    // Games solved.
    private var games: [Game] = []
    var gamesLost: [Game] {
        return games.filter( { !$0.wasWon } )
    }
    var gamesLostStats: (avgNumCluesGiven: Float, avgNumBadPlays: Float, avgNumDiscards: Float, num: Int, percent: Float, seeds: [UInt32]) {
        let avgNumCluesGiven = avgXInYs(ys: gamesLost, xInY: { $0.numberOfCluesGivenInt } )
        let avgNumBadPlays = avgXInYs(ys: gamesLost, xInY: { $0.numberOfBadPlaysInt } )
        let avgNumDiscards = avgXInYs(ys: gamesLost, xInY: { $0.numberOfDiscardsInt } )
        var seeds: [UInt32] = []
        for game in gamesLost {
            seeds.append(game.seedUInt32)
        }
        let percent = Float(numGamesLost * 100) / Float(numGamesPlayed)
        return (avgNumCluesGiven, avgNumBadPlays, avgNumDiscards, numGamesLost, percent, seeds)
    }
    var gamesWon: [Game] {
        return games.filter( { $0.wasWon } )
    }
    var gamesWonStats: (avgNumCluesGiven: Float, avgMaxPlaysLeft: Float, avgNumBadPlays: Float, avgNumDiscards: Float) {
        let avgNumCluesGiven = avgXInYs(ys: gamesWon, xInY: { $0.numberOfCluesGivenInt } )
        // Average number of "max plays left" in games that were won.
        let avgMaxPlaysLeft = avgXInYs(ys: gamesWon, xInY: { $0.numberOfMaxPlaysLeftInt } )
        let avgNumBadPlays = avgXInYs(ys: gamesWon, xInY: { $0.numberOfBadPlaysInt } )
        let avgNumDiscards = avgXInYs(ys: gamesWon, xInY: { $0.numberOfDiscardsInt } )
        return (avgNumCluesGiven, avgMaxPlaysLeft, avgNumBadPlays, avgNumDiscards)
    }
    private var log = (UIApplication.sharedApplication().delegate as AppDelegate).logModel
    var numAIs: Int {
        return ais.count
    }
    var numGamesLost: Int {
        return gamesLost.count
    }
    var numGamesPlayed: Int {
        return games.count
    }
    var numGamesWon: Int {
        return gamesWon.count
    }
    // Number of seconds spent solving games.
    private var numSecondsSpent = 0.0
    // Number of turns the first game took. If no game, return nil.
    var numTurnsForFirstGame: Int? {
        if let game = games.first {
            return game.numberOfTurnsInt
        } else {
            return nil
        }
    }
    // Number of seconds spent solving; average seconds per game.
    var secondsSpentStats: (num: Double, avg: Double) {
        let num = numSecondsSpent
        let avg = num / Double(numGamesPlayed)
        return (num, avg)
    }
    // Seed used to make first game. Assumes exists.
    var seedForFirstGame: UInt32 {
        return games.first!.seedUInt32
    }
    // Whether to stop solving. Can be either one or multiple games.
    private var stopSolving = false
    
    // WILO
    // AI for the given number. AIs are in an undefined order.
    func aiForNumberInt(numberInt: Int) -> AbstractAI {
        let indexInt = numberInt - 1
        return ais[indexInt]
    }
    // AI for the given AI type. If type not found, return first value.
    func aiForType(aiType: AIType) -> AbstractAI {
        for ai in ais {
            if ai.type == aiType {
                return ai
            }
        }
        println("Warning: AI type not found: \(aiType.toRaw()).")
        return ais[0]
    }
    
    // Return the best action for the given turn.
    func bestActionForTurn(turn: Turn) -> Action {
        let action = currentAI.bestActionForTurn(turn)
        return action
    }
    // Data for given turn for given game. If turn end, the data is for the end of the turn (vs start). As we're bundling a lot of data here, this should be used only for reporting and not for solving many games at once.
    func dataForTurnForGame(gameNumberInt: Int, turnNumberInt: Int, turnEndBool: Bool, showCurrentHandBool: Bool) -> (actionString: String, deckString: String, discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreString: String, visibleHandsAttributedString: NSAttributedString) {
        let index = gameNumberInt - 1
        let game = games[index]
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
        ais.append(OmniscientAI())
        ais.append(PureInfoAI())
    }
    // Order number for the given AI. First number is 1. If AI not found, return 1.
    func numberIntForAI(ai: AbstractAI) -> Int {
        for index in 0...ais.count {
            let ai2 = ais[index]
            if ai2 == ai {
                return index + 1
            }
        }
        return 1
    }
    // String for the round and subround for the given turn. (E.g., in a 3-player game, turn 4 = round 2.1.)
    func roundSubroundStringForTurnForFirstGame(turnNumberInt: Int) -> String {
        let game = games.first!
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
        } while !game.isDone && !stopSolving
        self.games.append(game)
        // Assume delegate wants to be notified on main thread.
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.solverElfDidFinishAGame?()
            // Need this line as single-line closures return implicitly.
            return
        }
    }
    // Reset list of solved games. Make a game. Solve it. Use bg thread to not block main.
    func solveGameWithSeed(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        stopSolving = false
        games = []
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let game = Game(seedOptionalUInt32: seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
            self.solveGame(game)
        }
    }
    // Reset list of solved games. Make games. Solve them. Games are solved in bg thread to not block main.
    func solveGames(numberOfGames: Int, numberOfPlayersInt: Int) {
        stopSolving = false
        numSecondsSpent = 0.0
        games = []
        // Track time spent.
        let startDate = NSDate()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var numberOfSecondsToWaitToLogDouble: Double = 1.0
            for gameNumberInt in 1...numberOfGames {
                if self.stopSolving {
                    break
                }
                // Give feedback in increasing intervals.
                let tempDate = NSDate()
                let numberOfSecondsSoFarDouble = tempDate.timeIntervalSinceDate(startDate)
                if numberOfSecondsSoFarDouble > numberOfSecondsToWaitToLogDouble {
                    numberOfSecondsToWaitToLogDouble = numberOfSecondsToWaitToLogDouble * 3.0
                    self.log.addLine("Games so far: \(self.numGamesPlayed). Next update: \(Int(numberOfSecondsToWaitToLogDouble)) seconds.")
                }
                let game = Game(seedOptionalUInt32: nil, numberOfPlayersInt: numberOfPlayersInt)
                self.solveGame(game)
            }
            // Assume delegate wants to be notified on main thread.
            dispatch_async(dispatch_get_main_queue()) {
                let endDate = NSDate()
                self.numSecondsSpent = endDate.timeIntervalSinceDate(startDate)
                self.delegate?.solverElfDidFinishAllGames?()
            }
        }
    }
    // Determine best action for given turn.
    func solveTurn(turn: Turn) {
        turn.optionalAction = bestActionForTurn(turn)
    }
    func stop() {
        stopSolving = true
    }
}
