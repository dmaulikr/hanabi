//
//  GameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class GameState: NSObject {
    var currentPlayerNumberInt = 1
    var deckCardArray: [Card] = []
    var discardsCardArray: [Card] = []
    var numberOfCluesLeftInt = 8
    var numberOfStrikesLeftInt = 3
    // Number of turns played after the deck became empty. To determine game end.
    var numberOfTurnsPlayedWithEmptyDeckInt = 0
    var playerArray: [Player] = []
    // The score is a number associated with each color. Total score is the sum.
    var scoreDictionary: [Card.Color: Int] = [:]
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
    // Return whether any player, including self, has a play or safe discard.
    func cheatingAnyPlaysOrSafeDiscards() -> Bool {
        for player in playerArray {
            let handCardArray = player.handCardArray
            for card in handCardArray {
                if cardIsPlayable(card) || cardWasAlreadyPlayed(card) || cardIsDuplicate(card, handCardArray:handCardArray) {
                    return true
                }
            }
        }
        return false
    }
    // Return cards the current player can safely discard: 1) already played, 2) duplicates in hand. Keep card order, because that can provide info.
    func cheatingSafeDiscardsCardArray() -> [Card] {
        var cheatingSafeDiscardsCardArray: [Card] = []
        let handCardArray = playerArray[currentPlayerNumberInt - 1].handCardArray
        for card in handCardArray {
            if cardWasAlreadyPlayed(card) || cardIsDuplicate(card, handCardArray:handCardArray) {
                cheatingSafeDiscardsCardArray.append(card)
            }
        }
        return cheatingSafeDiscardsCardArray
    }
    override func copy() -> AnyObject! {
        var gameState = GameState()
        gameState.currentPlayerNumberInt = currentPlayerNumberInt
        gameState.deckCardArray = deckCardArray
        gameState.discardsCardArray = discardsCardArray
        gameState.numberOfCluesLeftInt = numberOfCluesLeftInt
        gameState.numberOfStrikesLeftInt = numberOfStrikesLeftInt
        gameState.numberOfTurnsPlayedWithEmptyDeckInt = numberOfTurnsPlayedWithEmptyDeckInt
        // Deep copy.
        for player in playerArray {
            gameState.playerArray.append(player.copy() as Player)
        }
        gameState.scoreDictionary = scoreDictionary
        return gameState
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
    // Return whether the game has ended (not necessarily won).
    func isDone() -> Bool {
        // Game ends if score maxed, if out of strikes or if out of turns. The last case: when the deck is empty, each player gets one more turn.
        if totalScore() == 25 || numberOfStrikesLeftInt == 0 {
            return true
        }
        if deckCardArray.isEmpty && numberOfTurnsPlayedWithEmptyDeckInt == playerArray.count {
            return true
        }
        return false
    }
    // Return card(s) whose visible chain will take the longest to play. For example, 123 takes 3 turns, 132 takes 5.
    func mostTurnsForChainCardArray() -> [Card] {
        var mostTurnsForChainCardArray: [Card] = []
        var maxNumberOfTurnsForChainInt = 0
        // Assuming we want cards in only the current player's hand.
        for card in playerArray[currentPlayerNumberInt - 1].handCardArray {
            // Want only playable cards, ignoring duplicates in hand.
            if cardIsPlayable(card) && !contains(mostTurnsForChainCardArray, card) {
                // Calculate turns for card's visible chain.
                // Look for next card in chain. If found, note turns needed. Repeat.
                var numberOfTurnsForChainInt = 1
                var cardToFind = card
                var cardWasFound = true
                var playerWithCard = playerArray[currentPlayerNumberInt - 1]
                while cardWasFound {
                    cardWasFound = false
                    let cardToFindOptional = cardToFind.nextValueCard()
                    if cardToFindOptional != nil {
                        cardToFind = cardToFindOptional!
                        var playerToSearch = playerAfter(playerWithCard)
                        var numberOfTurnsForCardInt = 0
                        // Search each player once, including player with the previous card.
                        while numberOfTurnsForCardInt < playerArray.count {
                            numberOfTurnsForCardInt++
                            if contains(playerToSearch.handCardArray, cardToFind) {
                                cardWasFound = true
                                numberOfTurnsForChainInt += numberOfTurnsForCardInt
                                break
                            }
                            playerToSearch = playerAfter(playerToSearch)
                        }
                    }
                }
                // Keep if longest so far.
                if numberOfTurnsForChainInt > maxNumberOfTurnsForChainInt {
                    maxNumberOfTurnsForChainInt = numberOfTurnsForChainInt
                    mostTurnsForChainCardArray = [card]
                } else if numberOfTurnsForChainInt == maxNumberOfTurnsForChainInt {
                    mostTurnsForChainCardArray.append(card)
                }
            }
        }
        return mostTurnsForChainCardArray
    }
    // Change current player to next player. Rotates in a clockwise circle.
    func moveToNextPlayer() {
        currentPlayerNumberInt++
        if currentPlayerNumberInt > playerArray.count {
            currentPlayerNumberInt = 1
        }
    }
    func performAction(action: Action) {
        // If deck already empty, then note turn.
        if deckCardArray.isEmpty {
            numberOfTurnsPlayedWithEmptyDeckInt++
        }
        switch action.type {
        case .Clue:
            println("give a clue")
            // If clues not left, trigger an assertion. (AI shouldn't have chosen this, and player shouldn't have been able to.)
            assert(numberOfCluesLeftInt > 0, "Error: tried to give clue with 0 clue tokens.")
            numberOfCluesLeftInt--
        case .Play:
            println("play a card")
            // Remove card from hand. Play it. If okay, increase score. Else, lose strike and put in discard pile. If deck not empty, draw new card.
            let currentPlayer = playerArray[currentPlayerNumberInt - 1]
            let playCard = currentPlayer.handCardArray.removeAtIndex(action.targetCardIndexInt)
            if cardIsPlayable(playCard) {
                var scoreInt = scoreDictionary[playCard.color]!
                scoreInt++
                scoreDictionary[playCard.color] = scoreInt
            } else {
                numberOfStrikesLeftInt--
                discardsCardArray.append(playCard)
            }
            if !deckCardArray.isEmpty {
                let newCard = deckCardArray.removeLast()
                currentPlayer.handCardArray.append(newCard)
            }
            // if valid, increase score
        case .Discard:
            // If clues not less than max, trigger an assertion. (AI shouldn't have chosen this, and player shouldn't have been able to.)
            assert(numberOfCluesLeftInt < 8, "Error: tried to discard with max clue tokens.")
            // Remove card from hand. Put in discard pile. Gain clue token. If deck not empty, draw new card.
            let currentPlayer = playerArray[currentPlayerNumberInt - 1]
            let discardCard = currentPlayer.handCardArray.removeAtIndex(action.targetCardIndexInt)
            discardsCardArray.append(discardCard)
            numberOfCluesLeftInt++
            if !deckCardArray.isEmpty {
                let newCard = deckCardArray.removeLast()
                currentPlayer.handCardArray.append(newCard)
            }
        }
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
