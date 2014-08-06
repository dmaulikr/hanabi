//
//  SolverElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/5/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

protocol SolverElfDelegate {
    func solverElfDidChangeMode()
}

private var myContext = 0

class SolverElf: NSObject {
    enum Mode: Int {
        case Planning, Solving
    }
    var delegate: SolverElfDelegate? = nil
    var mode: Mode = Mode.Planning {
    didSet {
        if self.mode != oldValue {
            self.delegate?.solverElfDidChangeMode()
        }
    }
    }
    var numberOfGamesPlayedInt = 0
    var numberOfGamesToPlayInt = 1
    var numberOfGamesWonInt = 0
    var numberOfSecondsSpentFloat = 0.0
    override init() {
        super.init()
    }
    // User sees results of solving.
    func showResults() {
        println("Games: \(self.numberOfGamesPlayedInt)")
        println("Games won: \(self.numberOfGamesWonInt)")
        println("Time spent: \(self.numberOfSecondsSpentFloat) seconds")
    }
    func solveGames() {
        self.mode = Mode.Solving
        self.numberOfSecondsSpentFloat = 0.0
        // start timer
        self.numberOfGamesPlayedInt = 0
        self.numberOfGamesWonInt = 0
        // Solve one at a time.
        for var gameNumber = 1; gameNumber <= self.numberOfGamesToPlayInt; ++gameNumber {
//            println("Playing game \(gameNumber)")
//            self.shuffleDeck()
//            self.dealHands()
//            self.playToEnd()
//            self.scoreGame()
            self.numberOfGamesPlayedInt++
//            self.saveResults()
        }
        // end timer
//        self.numberOfSecondsSpentFloat = ??
        self.showResults()
        self.mode = Mode.Planning
    }
    func stopSolving() {
        self.mode = Mode.Planning
    }
}
