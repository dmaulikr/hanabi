//
//  GameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class AbstractGameState: NSObject {
    // Whether any player, including self, has any group duplicates.
//    var cheatingAnyGroupDuplicatesBool: Bool {
//        for player in playerArray {
//            for card in player.hand {
//                if cardValueIsGroupDuplicateBool(card) {
//                    return true
//                }
//            }
//        }
//        return false
//    }
    // Whether any player, including self, has a play or safe discard.
//    var cheatingAnyPlaysOrSafeDiscardsBool: Bool {
//        for player in playerArray {
//            let handCardArray = player.hand
//            for card in handCardArray {
//                if scorePile.canScore(card) || scorePile.has(card) || cardValueIsDuplicate(card, handCardArray:handCardArray) {
//                    return true
//                }
//            }
//        }
//        return false
//    }
    // Cards the current player shares with the deck.
//    var cheatingCardsAlsoInDeckCardArray: [Card] {
//        var cheatingCardsAlsoInDeckCardArray: [Card] = []
//        for card in currentPlayer.hand {
//            if cardValueIsInDeckBool(card) {
//                cheatingCardsAlsoInDeckCardArray.append(card)
//            }
//        }
//        return cheatingCardsAlsoInDeckCardArray
//    }
    // Cards the current player shares with other players.
//    var cheatingGroupDuplicatesCardArray: [Card] {
//        var cheatingGroupDuplicatesCardArray: [Card] = []
//        for card in currentPlayer.hand {
//            if cardValueIsGroupDuplicateBool(card) {
//                cheatingGroupDuplicatesCardArray.append(card)
//            }
//        }
//        return cheatingGroupDuplicatesCardArray
//    }
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
    // Return card(s) whose visible chain will take the longest to play. For example, 123 takes 3 turns, 132 takes 5.
//    var mostTurnsForChainCardArray: [Card] {
//        var mostTurnsForChainCardArray: [Card] = []
//        var maxNumberOfTurnsForChainInt = 0
//        // Assume we want cards in only the current player's hand. No duplicates.
//        for card in currentPlayer.noDupsHandCardArray {
//            // Want only playable cards.
//            if scorePile.cardIsPlayable(card) {
//                // Calculate turns for card's visible chain.
//                // Look for next card in chain. If found, note turns needed. Repeat.
//                var numberOfTurnsForChainInt = 1
//                var cardToFind = card
//                var cardWasFound = true
//                var playerWithCard = currentPlayer
//                while cardWasFound {
//                    cardWasFound = false
//                    let cardToFindOptional = cardToFind.nextValueOptionalCard
//                    if cardToFindOptional != nil {
//                        cardToFind = cardToFindOptional!
//                        var playerToSearch = playerAfter(playerWithCard)
//                        var numberOfTurnsForCardInt = 0
//                        // Search each player once, including player with the previous card.
//                        while numberOfTurnsForCardInt < numberOfPlayersInt {
//                            numberOfTurnsForCardInt++
//                            if Card.cardValueIsInArrayBool(cardToFind, cardArray: playerToSearch.handCardArray) {
//                                cardWasFound = true
//                                numberOfTurnsForChainInt += numberOfTurnsForCardInt
//                                break
//                            }
//                            playerToSearch = playerAfter(playerToSearch)
//                        }
//                    }
//                }
//                // Keep if longest so far.
//                if numberOfTurnsForChainInt > maxNumberOfTurnsForChainInt {
//                    maxNumberOfTurnsForChainInt = numberOfTurnsForChainInt
//                    mostTurnsForChainCardArray = [card]
//                } else if numberOfTurnsForChainInt == maxNumberOfTurnsForChainInt {
//                    mostTurnsForChainCardArray.append(card)
//                }
//            }
//        }
//        return mostTurnsForChainCardArray
//    }
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
    // deprecate; use isTwiceIn() instead
//    func cardValueIsDuplicate(card: Card, handCardArray: [Card]) -> Bool {
//        var numberOfTimesSeenInt = 0
//        for card2 in handCardArray {
//            if card2.isSameAs(card) {
//                ++numberOfTimesSeenInt
//            }
//        }
//        if numberOfTimesSeenInt >= 2 {
//            return true
//        } else {
//            return false
//        }
//    }
    // Whether the given card appears at least twice among all hands. (Cheating?)
    func cardValueIsGroupDuplicateBool(card: Card) -> Bool {
        var numberOfTimesSeenInt = 0
        for player in playerArray {
            for card2 in player.hand {
                if card2.isSameAs(card) {
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
    // Whether the given card is in the current deck.
    // deprecate; use card.isIn()
//    func cardValueIsInDeckBool(card: Card) -> Bool {
//        return card.isIn(deck.cards)
//    }
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
    // Player who goes after the given player. Rotates in a clockwise circle.
    func playerAfter(player: Player) -> Player {
        var index = find(playerArray, player)!
        index++
        if index == numberOfPlayersInt {
            index = 0
        }
        return playerArray[index]
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
