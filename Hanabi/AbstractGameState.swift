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
        return numberOfCardsLeftInt + numberOfPlayersInt - numberOfTurnsPlayedWithEmptyDeckInt
    }
    // Number of invalid plays up to this point.
    var numberOfBadPlaysInt: Int {
        return AbstractGameState.numberOfStrikesAtStartInt - numberOfStrikesLeftInt
    }
    // Number of cards in the deck.
    var numberOfCardsLeftInt: Int {
        return deck.numberOfCardsLeftInt
    }
    class var numberOfCluesAtStartInt: Int {
        return 8
    }
    // Number of clues given up to this point. Equals clues started with + clues gained - clues left. Clues gained = number of discards.
    var numberOfCluesGivenInt: Int {
        let numberOfCluesGainedInt = numberOfDiscardsInt
        let numberOfCluesGivenInt = AbstractGameState.numberOfCluesAtStartInt + numberOfCluesGainedInt - numberOfCluesLeftInt
        return numberOfCluesGivenInt
    }
    var numberOfCluesLeftInt = numberOfCluesAtStartInt
    // Number of cards discarded. Equals number of cards in discard pile - number of bad plays.
    var numberOfDiscardsInt: Int {
        return discardsCardArray.count - numberOfBadPlaysInt
    }
    var numberOfPlayersInt: Int {
        return playerArray.count
    }
    // Number of points needed for perfect score.
    var numberOfPointsNeededInt: Int {
        return 25 - scorePile.currentInt
    }
    class var numberOfStrikesAtStartInt: Int {
        return 3
    }
    var numberOfStrikesLeftInt = numberOfStrikesAtStartInt
    // Number of turns played after the deck became empty. To determine game end.
    var numberOfTurnsPlayedWithEmptyDeckInt = 0
    var playerArray: [Player] = []
    var scorePile: ScorePile!
    var scoreInt: Int {
        return scorePile.currentInt
    }
    // Return whether the given card appears at least twice in the given hand.
    func cardValueIsDuplicate(card: Card, handCardArray: [Card]) -> Bool {
        var numberOfTimesSeenInt = 0
        for card2 in handCardArray {
            if card2.isEqualColorAndNumber(card) {
                ++numberOfTimesSeenInt
            }
        }
        if numberOfTimesSeenInt >= 2 {
            return true
        } else {
            return false
        }
    }
    // Whether the given card appears at least twice among all hands. (Cheating?)
    func cardValueIsGroupDuplicateBool(card: Card) -> Bool {
        var numberOfTimesSeenInt = 0
        for player in playerArray {
            for card2 in player.handCardArray {
                if card2.isEqualColorAndNumber(card) {
                    ++numberOfTimesSeenInt
                }
            }
        }
        if numberOfTimesSeenInt >= 2 {
            return true
        } else {
            return false
        }
    }
    // Whether the given card is in any hand. (Cheating?)
    func cardValueIsInAHandBool(card: Card) -> Bool {
        for player in playerArray {
            if Card.cardValueIsInArrayBool(card, cardArray: player.handCardArray) {
                return true
            }
        }
        return false
    }
    // Whether the given card is in the current deck.
    func cardValueIsInDeckBool(card: Card) -> Bool {
        return Card.cardValueIsInArrayBool(card, cardArray: deck.cardArray)
    }
    // Useful data describing game state.
    func data(#showCurrentHandBool: Bool) -> (discardsString: String, maxNumberOfPlaysLeftInt: Int, numberOfCardsLeftInt: Int, numberOfCluesLeftInt: Int, numberOfPointsNeededInt: Int, numberOfStrikesLeftInt: Int, scoreInt: Int, scoreString: String, visibleHandsAttributedString: NSAttributedString) {
        let scoreInt = scorePile.currentInt
        let scoreString = scorePile.string
        let vHAttributedString = visibleHandsAttributedString(showCurrentHandBool: showCurrentHandBool)
        return (discardsString, maxNumberOfPlaysLeftInt, numberOfCardsLeftInt, numberOfCluesLeftInt, numberOfPointsNeededInt, numberOfStrikesLeftInt, scoreInt, scoreString, vHAttributedString)
    }
    override init() {
        scorePile = ScorePile()
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
