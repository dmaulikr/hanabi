//
//  StartingGameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/12/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class StartingGameState: AbstractGameState {
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
    init(endingGameState: EndingGameState) {
        // what about first init? should be just ()
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
    // String describing the given action and its result.
    func resultStringForAction(action: Action) -> String {
        var resultString = "\n\(currentPlayer.nameString)"
        let index = action.targetCardIndexInt
        let card = currentPlayer.handCardArray[index]
        // Card position and abbreviation.
        let cardPositionString = "card \(index + 1): \(card.string())"
        switch action.type {
        case .Clue:
            resultString += " gave a clue: X."
        case .Discard:
            resultString += " discarded \(cardPositionString)."
            if numberOfCardsLeftInt >= 1 {
                resultString += " Drew a card."
            }
        case .Play:
            resultString += " played \(cardPositionString)."
            // If invalid play, mention that.
            if !cardIsPlayable(card) {
                resultString += " Invalid play. Strike."
            }
            if numberOfCardsLeftInt >= 1 {
                resultString += " Drew a card."
            }
        }
        return resultString
    }
}
