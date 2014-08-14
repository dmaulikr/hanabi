//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class Game: NSObject {
    var currentTurn: Turn {
        return turnArray.last!
    }
    // Score at end of last turn.
    var finalScore: Int {
        let lastTurn = turnArray.last!
        // need to specify that I want the score at end of turn, not start... hmmm
            // turn.endingScore, turn.finalScore
        return lastTurn.totalScore
    }
    // Whether the game has ended (not necessarily won).
    var isDone: Bool {
        let lastTurn = turnArray.last!
        return lastTurn.gameIsDone
//        if let endingGameState = turnArray.last?.endingOptionalGameState {
//            if endingGameState.isDone() {
//                return true
//            }
//            }
//            // Safety check to prevent infinite loop.
//            if turnArray.count > 99 {
//                println("Warning: > 99 turns.")
//                return true
//            }
//            return false
    }
    var numberOfTurnsInt: Int {
        return turnArray.count
    }
    var seedUInt32: UInt32 {
        return turnArray.first!.seedUInt32
    }
    var turnArray: [Turn] = []
    
    // Whether the game had a winning score.
    var wasWon: Bool {
        if finalScore == 25 {
            return true
        } else {
            return false
        }
    }
    // String describing action for given turn.
    func actionStringForTurn(turnNumberInt: Int) -> String {
        let index = turnNumberInt - 1
        let turn = turnArray[index]
        return turn.actionString
    }

    
    // Return the number of the current turn.
//    func currentTurnNumberOptionalInt() -> Int? {
//        if let turn = currentOptionalTurn {
//            let optionalIndex = find(turnArray, turn)
//            if let index = optionalIndex {
//                return index + 1
//            }
//        }
//        return nil
//    }
    
    // Data for given turn. If turn end, the data is for the end of the turn (vs start).
    func dataForTurn(turnNumberInt: Int, turnEndBool: Bool) -> (discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreString: String, visibleHandsString: String) {
        let index = turnNumberInt - 1
        let turn = turnArray[index]
        // Could add this if needed.
        // var turnNumberInt: Int
        let data = turn.data(turnEndBool: turnEndBool)
        let discardsString = data.discardsString
        let maxNumberOfPlaysLeftInt = data.maxNumberOfPlaysLeftInt
        let numberOfCardsLeftInt = data.numberOfCardsLeftInt
        let numberOfCluesLeftInt = data.numberOfCluesLeftInt
        let numberOfPointsNeededInt = data.numberOfPointsNeededInt
        let numberOfStrikesLeftInt = data.numberOfStrikesLeftInt
        let scoreString = data.scoreString
        let visibleHandsString = data.visibleHandsString
        return (discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreString, visibleHandsString)
    }
    
    // Deal starting hands to the given players.
//    func dealHandsFromDeck(inout deckCardArray: [Card], inout playerArray: [Player]) {
//        // In reality, we'd deal a card to a player at a time, because the cards may not be well-shuffled. Here, we'll deal each player completely. This makes games with the same deck but different numbers of players more comparable.
//        let numberOfPlayersInt = playerArray.count
//        var numberOfCardsPerPlayerInt: Int
//        switch numberOfPlayersInt {
//        case 2, 3:
//            numberOfCardsPerPlayerInt = 5
//        case 4, 5:
//            numberOfCardsPerPlayerInt = 4
//        default:
//            numberOfCardsPerPlayerInt = 5
//        }
//        for playerNumberInt in 1...numberOfPlayersInt {
//            let player = playerArray[playerNumberInt - 1]
//            for int2 in 1...numberOfCardsPerPlayerInt {
//                // Pulling last card of deck because it should be easier/faster.
//                let card = deckCardArray.removeLast()
//                player.handCardArray.append(card)
//            }
//        }
//    }
    
    // Perform current action. If game not done, make next turn.
    func finishCurrentTurn() {
        let turn = currentTurn
        turn.performAction()
        if !isDone {
            let nextTurn = turn.makeNextTurn()
            turnArray.append(nextTurn)
        }
    }
    // Make deck. Shuffle. Deal hands.
    init(seedOptionalUInt32: UInt32?, numberOfPlayersInt: Int) {
        super.init()
        var deck = Deck()
        deck.shuffleWithSeed(seedOptionalUInt32)
        // debugging
        println("Deck: \(deck.string)")
        var playerArray: [Player] = []
        for playerNumberInt in 1...numberOfPlayersInt {
            let player = Player()
            player.nameString = "P\(playerNumberInt)"
            playerArray.append(player)
        }
        // make turn, given the deck and players
        let turn = Turn.firstTurn(deck: deck, playerArray: playerArray)
        // so Turn.firstTurn has to deal the initial hands
        turnArray.append(turn)
//        currentOptionalTurn = turn
        
        
//        dealHandsFromDeck(&deckCardArray, playerArray: &playerArray)
        
        // make turn, given the deck and players
//        let gameState = GameState()
//        gameState.playerArray = playerArray
//        gameState.deckCardArray = deckCardArray
//        let turn = Turn(gameState: gameState)
//        turnArray.append(turn)
//        currentOptionalTurn = turn
    }
    // String for the round and subround for the given turn. (E.g., in a 3-player game, turn 4 = round 2.1.)
    func roundSubroundStringForTurn(turnNumberInt: Int) -> String {
        let index = turnNumberInt - 1
        let turn = turnArray[index]
        return turn.roundSubroundString
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
    
    // Return the number of players in the game.
    // do we need this?
//    func numberOfPlayersInt() -> Int {
//        if let gameState = turnArray.first?.startingGameState {
//            return gameState.playerArray.count
//        }
//        return 0
//    }    
}
