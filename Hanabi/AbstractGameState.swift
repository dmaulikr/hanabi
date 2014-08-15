//
//  GameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class AbstractGameState: NSObject {
    var currentPlayer: Player {
        return playerArray[currentPlayerIndex]
    }
    var currentPlayerIndex: Int!
    var deck: Deck!
    var discardsCardArray: [Card] = []
    // String showing the discard pile.
    var discardsString: String {
        return Card.stringForArray(discardsCardArray)
    }
    // Max number of cards that can be played before the game ends from decking. Once last card is drawn, each player gets one turn. Ignore that the game would end if all 25 points were scored.
    var maxNumberOfPlaysLeftInt: Int {
        return numberOfCardsLeftInt + numberOfPlayersInt
    }
    // The number of cards in the deck.
    var numberOfCardsLeftInt: Int {
        return deck.numberOfCardsLeftInt
    }
    var numberOfCluesLeftInt = 8
    var numberOfPlayersInt: Int {
        return playerArray.count
    }
    // Number of points needed for perfect score.
    var numberOfPointsNeededInt: Int {
        return 25 - scoreInt
    }
    var numberOfStrikesLeftInt = 3
    // Number of turns played after the deck became empty. To determine game end.
    var numberOfTurnsPlayedWithEmptyDeckInt = 0
    var playerArray: [Player] = []
    // The score is a number associated with each color. Total score is the sum.
    var scoreDictionary: [Card.Color: Int] = [:]
    // Sum of score for each color.
    var scoreInt: Int {
        var scoreInt = 0
        for (color, score) in scoreDictionary {
            scoreInt += score
        }
        return scoreInt
    }
    // String showing the score for each color, in order.
    var scoreString: String {
        // Score is kept in a dictionary, which does not guarantee order. We'll put each color's score in an array, then join the elements.
        var stringArray = [String](count: 5, repeatedValue: "")
        for (color, score) in scoreDictionary {
            switch color {
            case .Blue:
                stringArray[0] = String(score)
            case .Green:
                stringArray[1] = String(score)
            case .Red:
                stringArray[2] = String(score)
            case .White:
                stringArray[3] = String(score)
            case .Yellow:
                stringArray[4] = String(score)
            }
        }
        let scoreString = "".join(stringArray)
        return scoreString
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
    // Useful data describing game state.
    func data(#showCurrentHandBool: Bool) -> (discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreInt: Int, scoreString: String, visibleHandsAttributedString: NSAttributedString) {
        let vHAttributedString = visibleHandsAttributedString(showCurrentHandBool: showCurrentHandBool)
        return (discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreInt, scoreString, vHAttributedString)
    }
    override init() {
        // Initialize score.
        for int in 1...5 {
            if let color = Card.Color.fromRaw(int) {
                scoreDictionary[color] = 0
            }
        }
        super.init()
    }
    // Attributed string showing cards in hands. Current player is in bold.
    func visibleHandsAttributedString(#showCurrentHandBool: Bool) -> NSAttributedString {
        var vHMutableAttributedString = NSMutableAttributedString()
        for player in playerArray {
            var playerString: String
            playerString = "\n\(player.nameString):"
            // Add hand if player is not current player, or if asked to show current player.
            if (player != currentPlayer) || showCurrentHandBool  {
                playerString += " \(player.handString)"
            }
            var playerAttributedString: NSAttributedString
            if player == currentPlayer {
                let attributesDictionary = [NSFontAttributeName : UIFont(name: "Courier-Bold", size: 15.0)]
                playerAttributedString = NSAttributedString(string: playerString, attributes: attributesDictionary)
            } else {
                playerAttributedString = NSAttributedString(string: playerString)
            }
            vHMutableAttributedString.appendAttributedString(playerAttributedString)
        }
        return vHMutableAttributedString
    }
}
