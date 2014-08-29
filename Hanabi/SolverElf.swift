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
                return ai(type: aiType)
            } else {
                return ai(type: AIType.Omniscient)
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
    // AI for the given number, starting at 1. AIs are in an undefined order.
    func ai(#num: Int) -> AbstractAI {
        let index = num - 1
        return ais[index]
    }
    // AI for the given AI type. If type not found, return first value.
    func ai(#type: AIType) -> AbstractAI {
        for ai in ais {
            if ai.type == type {
                return ai
            }
        }
        println("Warning: AI type not found: \(type.toRaw()).")
        return ais[0]
    }
    // The order number for the given AI. First number is 1. If AI not found, return 1.
    func aiNum(#ai: AbstractAI) -> Int {
        for index in 0...(ais.count - 1) {
            let ai2 = ais[index]
            if ai2 == ai {
                return index + 1
            }
        }
        return 1
    }
    // Data for given turn for given game. If turn end, the data is for the end of the turn (vs start). As we're bundling a lot of data here, this should be used only for reporting and not for solving many games at once.
    func aTurnData(#gameNum: Int, turnNum: Int, turnEnd: Bool, showCurrentHand: Bool) -> (actionDescription: String, deckDescription: String, discardsDescription: String, maxNumPlaysLeft: Int, numCardsLeft: Int, numCluesLeft: Int, numPointsNeeded: Int, numStrikesLeft: Int, scoreDescription: String, visibleHandsDescription: NSAttributedString) {
        let index = gameNum - 1
        let game = games[index]
        let aTurnData = game.dataForTurn(turnNum, turnEndBool: turnEnd, showCurrentHandBool: showCurrentHand)
        let actionDescription = aTurnData.actionString
        let deckDescription = aTurnData.deckString
        let discardsDescription = aTurnData.discardsString
        let maxNumPlaysLeft = aTurnData.maxNumberOfPlaysLeftInt
        let numCardsLeft = aTurnData.numberOfCardsLeftInt
        let numCluesLeft = aTurnData.numberOfCluesLeftInt
        let numPointsNeeded = aTurnData.numberOfPointsNeededInt
        let numStrikesLeft = aTurnData.numberOfStrikesLeftInt
        let scoreDescription = aTurnData.scoreString
        let visibleHandsDescription = aTurnData.visibleHandsAttributedString
        return (actionDescription, deckDescription, discardsDescription, maxNumPlaysLeft, numCardsLeft, numCluesLeft, numPointsNeeded, numStrikesLeft, scoreDescription, visibleHandsDescription)
    }
    // Description for given turn's subround. (E.g., in a 3-player game, turn 6 = round 2.3.)
    func firstGameSubroundDescription(#turnNum: Int) -> String {
        let game = games.first!
        let numPlayers = game.numberOfPlayersInt
        let description = roundSubroundStringForTurn(turnNum, numberOfPlayersInt: numPlayers)
        return description
    }
    override init() {
        super.init()
        ais.append(OmniscientAI())
        ais.append(PureInfoAI())
    }
    // Play the given game to the end. Store game and notify delegate.
    private func solveGame(game: Game) {
        do {
            let action = currentAI.bestAction(game: game)
            game.doAction(action)
            currentAI.updateAfterAction(game: game)
            if !game.isDone {
                game.makeNextTurn()
            }
        } while !game.isDone && !stopSolving
        games.append(game)
        // Assume delegate wants to be notified on main thread.
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.solverElfDidFinishAGame?()
            // Need this line as single-line closures return implicitly.
            return
        }
    }
    // Make and solve one game, based on the given seed.
    func solveGame(#seed: UInt32?, numPlayers: Int) {
        // Reset list of solved games. Make a game. Solve it. Use bg thread to not block main.
        stopSolving = false
        games = []
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let game = Game(seedOptionalUInt32: seed, numberOfPlayersInt: numPlayers)
            self.solveGame(game)
        }
    }
    // Make and solve multiple games.
    func solveGames(numGames: Int, numPlayers: Int) {
        // Reset list of solved games. Make games. Solve them. Games are solved in bg thread to not block main.
        stopSolving = false
        numSecondsSpent = 0.0
        games = []
        // Track time spent.
        let startTime = NSDate()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var numSecondsToWaitToLog: Double = 1.0
            for _ in 1...numGames {
                if self.stopSolving {
                    break
                }
                // Give feedback in increasing intervals.
                let now = NSDate()
                let numSecondsSoFar = now.timeIntervalSinceDate(startTime)
                if numSecondsSoFar > numSecondsToWaitToLog {
                    numSecondsToWaitToLog *= 3.0
                    self.log.addLine("Games done: \(self.numGamesPlayed). Next update: \(round(numSecondsToWaitToLog - numSecondsSoFar, decimals: 1)) seconds.")
                }
                let game = Game(seedOptionalUInt32: nil, numberOfPlayersInt: numPlayers)
                self.solveGame(game)
            }
            // Assume delegate wants to be notified on main thread.
            dispatch_async(dispatch_get_main_queue()) {
                let endTime = NSDate()
                self.numSecondsSpent = endTime.timeIntervalSinceDate(startTime)
                self.delegate?.solverElfDidFinishAllGames?()
            }
        }
    }
    // Tells Solver Elf to stop solving.
    func stop() {
        stopSolving = true
    }
}
