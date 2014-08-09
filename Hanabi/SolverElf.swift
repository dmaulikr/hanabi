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
    var delegate: SolverElfDelegate?
    var currentOptionalGame: Game?
    // Games solved.
    var gameArray: [Game] = []
    var numberOfSecondsSpentFloat = 0.0
    // Average number of turns to finish currently solved games. (To be meaningful, presumes most/all games were won.)
    func averageNumberOfTurns() -> Float {
        var totalTurnsInt = 0
        for game in gameArray {
            totalTurnsInt += game.turnArray.count
        }
        return Float(totalTurnsInt) / Float(gameArray.count)
    }
    // Average for currently solved games.
    func averageScore() -> Float {
        var totalScoresInt = 0
        for game in gameArray {
            totalScoresInt += game.finalScore()
        }
        return Float(totalScoresInt) / Float(gameArray.count)
    }
    // Return the best action for the given turn.
    // here's where elf can try different stratgies.
    func bestActionForTurn(turn: Turn) -> Action {
        return Action()
    }
    override init() {
        super.init()
    }
    func numberOfGamesLost() -> Int {
        var numberOfGamesLost = 0
        for game in gameArray {
            if !game.wasWon() {
                numberOfGamesLost++
            }
        }
        return numberOfGamesLost
    }
    func numberOfGamesPlayed() -> Int {
        return gameArray.count
    }
    // Make, play and return a game.
    func solveGameWithSeed(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) -> Game {
        let game = Game(seedOptionalUInt32: seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
        do {
            solveCurrentTurnForGame(game)
            game.finishCurrentTurn()
        } while !game.isDone()
        currentOptionalGame = game
        delegate?.solverElfDidFinishAGame?()
        return game
    }
    func solveGames(numberOfGames: Int, numberOfPlayersInt: Int) {
        numberOfSecondsSpentFloat = 0.0
        gameArray = []
        // Track time spent.
        let startDate = NSDate()
        // Solve one at a time.
        for gameNumber in 1...numberOfGames {
            //            println("Playing game \(gameNumber)")
            let game = solveGameWithSeed(nil, numberOfPlayersInt: numberOfPlayersInt)
            gameArray.append(game)
        }
        let endDate = NSDate()
        numberOfSecondsSpentFloat = endDate.timeIntervalSinceDate(startDate)
        delegate?.solverElfDidFinishAllGames?()
    }
    // Determine best action for given turn. Do it.
    func solveTurn(turn: Turn) {
        // calculate options, or at least best option
        // do it...
        // action is either discard (which card?), give clue (what to whom?), play card (which one?)
        // action is a class with type (discard/give clue/play), card to discard/play, clue is a class; has a target player, and target cards, which gives the number, then either a color or a number.
        turn.optionalAction = bestActionForTurn(turn)
        // well, that sets the turn's action
        // but we still have to do it to get the next turn
    }
    // Determine best action for current turn. Do it.
    func solveCurrentTurnForGame(game: Game) {
        if let turn = game.currentOptionalTurn {
            solveTurn(turn)
        }
    }
    func stopSolving() {
    }
}
