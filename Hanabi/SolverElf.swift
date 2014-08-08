//
//  SolverElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/5/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

protocol SolverElfDelegate {
    // Sent when done solving.
    func solverElfDidFinish()
}

private var myContext = 0

class SolverElf: NSObject {
    var delegate: SolverElfDelegate?
    var currentOptionalGame: Game?
    var numberOfGamesPlayedInt = 0
//    var numberOfGamesToPlayInt = 1
    var numberOfGamesWonInt = 0
//    var numberOfPlayersInt = 3
    var numberOfSecondsSpentFloat = 0.0
    // Number for srandom().
//    var seedOptionalInt: Int?
    // Return the best action for the given turn.
    // here's where elf can try different stratgies.
    func bestActionForTurn(turn: Turn) -> Action {
        return Action()
    }
    override init() {
        super.init()
    }
    // User sees results of solving.
    func showResults() {
        println("Games: \(numberOfGamesPlayedInt)")
        println("Games won: \(numberOfGamesWonInt)")
        println("Time spent: \(numberOfSecondsSpentFloat) seconds")
    }
    // Make and play the given game.
    func solveGameWithSeed(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        let game = Game(seedOptionalUInt32: seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
        // until we win/end...
        do {
            solveCurrentTurnForGame(game)
            game.finishCurrentTurn()
        } while !game.isDone()
          // that results in turn x
        // repeat
          // turn 1 is start, with an action described but the effects not shown yet
        // turn 2 shows the effects and new player turn, with the next action described
       
        // play/solve game
//        playToEnd()
//        scoreGame()
        // scoreGame -> Mode.Solved
        currentOptionalGame = game
        delegate?.solverElfDidFinish()
    }
    func solveGames(numberOfGames: Int, numberOfPlayersInt: Int) {
        numberOfSecondsSpentFloat = 0.0
        // start timer
        numberOfGamesPlayedInt = 0
        numberOfGamesWonInt = 0
        // Solve one at a time.
        for gameNumber in 1...numberOfGames {
            //            println("Playing game \(gameNumber)")
            solveGameWithSeed(nil, numberOfPlayersInt: numberOfPlayersInt)
            numberOfGamesPlayedInt++
//            saveResults()
        }
        // end timer
//        numberOfSecondsSpentFloat = ??
        showResults()
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
