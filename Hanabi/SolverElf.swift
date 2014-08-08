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
    var game: Game?
    var numberOfGamesPlayedInt = 0
//    var numberOfGamesToPlayInt = 1
    var numberOfGamesWonInt = 0
//    var numberOfPlayersInt = 3
    var numberOfSecondsSpentFloat = 0.0
    // Number for srandom().
//    var seedOptionalInt: Int?
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
        game = Game(seedOptionalUInt32: seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
        // play/solve game
//        playToEnd()
//        scoreGame()
        // scoreGame -> Mode.Solved
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
    func stopSolving() {
    }
}
