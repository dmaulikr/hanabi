//
//  GameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class AbstractGameState: NSObject {
    var currentPlayer: Player!
    
//    var currentPlayerNumberInt = 1
    
    var deckCardArray: [Card] = []
    var discardsCardArray: [Card] = []
    // String showing the discard pile.
    var discardsString: String {
        get {
            var discardsString = ""
            for index in 0...discardsCardArray.count {
                let cardString = discardsCardArray[index].string()
                if index == 0 {
                    discardsString += "\(cardString)"
                } else {
                    discardsString += " \(cardString)"
                }
            }
            return discardsString
        }
    }
    // Max number of cards that can be played before the game ends from decking. Once last card is drawn, each player gets one turn. Ignore that the game would end if all 25 points were scored.
    var maxNumberOfPlaysLeftInt: Int {
        get {
            return numberOfCardsLeftInt + numberOfPlayersInt
        }
    }
    // The number of cards in the deck.
    var numberOfCardsLeftInt: Int {
        get {
            return deckCardArray.count
        }
    }
    var numberOfCluesLeftInt = 8
    // Number of points needed for perfect score.
    var numberOfPointsNeededInt: Int {
        get {
            return 25 - totalScore()
        }
    }
    var numberOfStrikesLeftInt = 3
    // Number of turns played after the deck became empty. To determine game end.
    var numberOfTurnsPlayedWithEmptyDeckInt = 0
    var playerArray: [Player] = []
    // The score is a number associated with each color. Total score is the sum.
    var scoreDictionary: [Card.Color: Int] = [:]
    // String showing the score for each color, in order.
    var scoreString: String {
        get {
            var scoreString = ""
            for (_, score) in scoreDictionary {
                scoreString += String(score)
            }
            return scoreString
        }
    }
    // String showing cards in other players' hands.
    var visibleHandsString: String {
        get {
            var visibleHandsString = ""
            for player in playerArray {
                visibleHandsString += "\n\(player.nameString):"
                if player != currentPlayer {
                    visibleHandsString += " \(player.handString)"
//                    for card in player.handCardArray {
//                        visibleHandsString += " \(card.string())"
//                    }
                }
            }
            return visibleHandsString
        }
    }

    // Return whether the given card appears at least twice in the given hand.
    func cardIsDuplicate(card:Card, handCardArray: [Card]) -> Bool {
        var numberOfTimesSeenInt = 0
        for card2 in handCardArray {
            if card2 == card {
                numberOfTimesSeenInt++
            }
        }
        if numberOfTimesSeenInt >= 2 {
            return true
        } else {
            return false
        }
    }
    // Return whether the given card can be played on the score pile.
    func cardIsPlayable(card: Card) -> Bool {
        // It's playable if the card's number is 1 more than its color's current score.
        let currentValueOptionalInt = scoreDictionary[card.color]
        if card.numberInt == currentValueOptionalInt! + 1 {
            return true
        } else {
            return false
        }
    }
    // Return whether given card has already been scored.
    func cardWasAlreadyPlayed(card: Card) -> Bool {
        let scoreForColorInt = scoreDictionary[card.color]!
        if card.numberInt <= scoreForColorInt {
            return true
        } else {
            return false
        }
    }
//    override func copy() -> AnyObject! {
//        var gameState = GameState()
//        gameState.currentPlayerNumberInt = currentPlayerNumberInt
//        gameState.deckCardArray = deckCardArray
//        gameState.discardsCardArray = discardsCardArray
//        gameState.numberOfCluesLeftInt = numberOfCluesLeftInt
//        gameState.numberOfStrikesLeftInt = numberOfStrikesLeftInt
//        gameState.numberOfTurnsPlayedWithEmptyDeckInt = numberOfTurnsPlayedWithEmptyDeckInt
//        // Deep copy.
//        for player in playerArray {
//            gameState.playerArray.append(player.copy() as Player)
//        }
//        gameState.scoreDictionary = scoreDictionary
//        return gameState
//    }
    override init() {
        // Initialize score.
        for int in 1...5 {
            if let color = Card.Color.fromRaw(int) {
                scoreDictionary[color] = 0
            }
        }
        super.init()
    }
    // Return the player who goes after the given player
    func playerAfter(player: Player) -> Player {
        var indexInt = find(playerArray, player)!
        indexInt += 1
        if indexInt == playerArray.count {
            indexInt = 0
        }
        return playerArray[indexInt]
    }
    // Sum of score for each color.
    func totalScore() -> Int {
        var scoreInt = 0
        for (color, score) in scoreDictionary {
            scoreInt += score
        }
        return scoreInt
    }
}
