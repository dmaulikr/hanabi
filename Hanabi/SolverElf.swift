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
    // Info for a game's turn.
    struct TurnDataForGame {
        var discardsString: String
        // Could add this if needed.
        // var gameNumberInt: Int
        var maxNumberOfPlaysLeftInt: Int
        var numberOfCardsLeftInt: Int
        var numberOfCluesLeftInt: Int
        var numberOfPointsNeededInt: Int
        var numberOfStrikesLeftInt: Int
        var scoreString: String
        var visibleHandsString: String
    }
    // Average for currently solved games.
    var averageScoreFloat: Float {
        get {
            var totalScoresInt = 0
            for game in gameArray {
                totalScoresInt += game.finalScore()
            }
            return Float(totalScoresInt) / Float(gameArray.count)
        }
    }
    var delegate: SolverElfDelegate?
//    var currentOptionalGame: Game?
    // Games solved.
    var gameArray: [Game] = []
    var numberOfSecondsSpentDouble = 0.0
    // String describing action for given turn for given game.
    func actionStringForTurnForGame(gameNumberInt: Int, turnNumberInt: Int) -> String {
        // Could put game number here.
        var actionStringForTurnForGame: String = ""
        let game = gameArray[gameNumberInt]
        actionStringForTurnForGame += game.actionStringForTurn(turnNumberInt: Int)
        return actionStringForTurnForGame
    }
    // Average number of turns to finish currently solved games. (To be meaningful, presumes most/all games were won.)
    func averageNumberOfTurns() -> Float {
        var totalTurnsInt = 0
        for game in gameArray {
            totalTurnsInt += game.turnArray.count
        }
        return Float(totalTurnsInt) / Float(gameArray.count)
    }
    
    // Return the best action for the given turn.
    func bestActionForTurn(turn: Turn) -> Action {
//        let alwaysDiscardElf = AlwaysDiscardElf()
//        let action = alwaysDiscardElf.bestActionForTurn(turn)
        
        let openHandElf = OpenHandElf()
        let action = openHandElf.bestActionForTurn(turn)
        return action
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
    // Number of turns the given game took.
    func numberOfTurnsForGame(gameNumberInt: Int) -> Int {
        
        //        if let game = solverElf.currentOptionalGame {
        //            return game.numberOfTurnsInt
        //        } else {
        //            return 0
        //        }
    }
    // String for the round and subround for the given turn. (E.g., in a 3-player game, turn 4 = round 2.1.)
    func roundSubroundString(turnNumberInt: Int) -> String {
        //        if let game = solverElf.currentOptionalGame {
        //            let rowIndexInt = indexPath.row
        //            let numberOfPlayersInt = game.numberOfPlayersInt()
        //            // 3 players: 0 = 1, 1 = 1, 2 = 1, 3 = 2, 4 = 2, 5 = 2
        //            let turnNumberInt = (rowIndexInt / numberOfPlayersInt) + 1
        //            // 3 players: 0 = 1, 1 = 2, 2 = 3, 3 = 1, 4 = 2, 5 = 3
        //            let playerNumberInt = (rowIndexInt % numberOfPlayersInt) + 1
        //            tableViewCell.textLabel.text = "Turn \(turnNumberInt).\(playerNumberInt)"
        //        }

    }
    // Seed used to make given game.
    func seedUInt32ForGame(gameNumberInt: Int) -> UInt32 {
        return gameArray[gameNumberInt].seedUInt32
    }
    // Make, play and return a game.
    func solveGameWithSeed(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) -> Game {
        let game = Game(seedOptionalUInt32: seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
        gameArray = [game]
        do {
            solveCurrentTurnForGame(game)
            game.finishCurrentTurn()
        } while !game.isDone()
        currentOptionalGame = game
        delegate?.solverElfDidFinishAGame?()
        return game
    }
    func solveGames(numberOfGames: Int, numberOfPlayersInt: Int) {
        numberOfSecondsSpentDouble = 0.0
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
        numberOfSecondsSpentDouble = endDate.timeIntervalSinceDate(startDate)
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
    
//    let turnDataForGame = solverElf.turnDataForGame(1, turnNumberInt: turnNumberInt, turnEndBool: turnEndBool)

    // Data for given turn for given game. If turn end, the data is for the end of the turn (vs start).
    func turnDataForGame(gameNumberInt: Int, turnNumberInt: Int, turnEndBool: Bool) -> TurnDataForGame {
        var turnDataForGame: TurnDataForGame = TurnDataForGame()
        let game = gameArray[gameNumberInt]
        let turnData = game.turnData(turnNumberInt: turnNumberInt, turnEndBool: turnEndBool)
        turnDataForGame.discardsString = turnData.discardsString
        return turnDataForGame
    }
}
