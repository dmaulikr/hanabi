//
//  StartingGameState.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/12/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class StartingGameState: AbstractGameState {
    // Whether any player, including self, has a play or safe discard.
    var cheatingAnyPlaysOrSafeDiscards: Bool {
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
    // Cards the current player can safely discard: 1) already played, 2) duplicates in hand. Keep card order, because that can provide info.
    var cheatingSafeDiscardsCardArray: [Card] {
        var cheatingSafeDiscardsCardArray: [Card] = []
        let handCardArray = currentPlayer.handCardArray
        for card in handCardArray {
            if cardWasAlreadyPlayed(card) || cardIsDuplicate(card, handCardArray:handCardArray) {
                cheatingSafeDiscardsCardArray.append(card)
            }
        }
        return cheatingSafeDiscardsCardArray
    }
    // Return card(s) whose visible chain will take the longest to play. For example, 123 takes 3 turns, 132 takes 5.
    var mostTurnsForChainCardArray: [Card] {
        var mostTurnsForChainCardArray: [Card] = []
        var maxNumberOfTurnsForChainInt = 0
        // Assuming we want cards in only the current player's hand.
        for card in currentPlayer.handCardArray {
            // Want only playable cards, ignoring duplicates in hand.
            if cardIsPlayable(card) && !contains(mostTurnsForChainCardArray, card) {
                // Calculate turns for card's visible chain.
                // Look for next card in chain. If found, note turns needed. Repeat.
                var numberOfTurnsForChainInt = 1
                var cardToFind = card
                var cardWasFound = true
                var playerWithCard = currentPlayer
                while cardWasFound {
                    cardWasFound = false
                    let cardToFindOptional = cardToFind.nextValueCard
                    if cardToFindOptional != nil {
                        cardToFind = cardToFindOptional!
                        var playerToSearch = playerAfter(playerWithCard)
                        var numberOfTurnsForCardInt = 0
                        // Search each player once, including player with the previous card.
                        while numberOfTurnsForCardInt < numberOfPlayersInt {
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
    // Deal starting hands to players.
    func dealHands() {
        // In reality, we'd deal a card to a player at a time, because the cards may not be well-shuffled. Here, we'll deal each player completely. This makes games with the same deck but different numbers of players more comparable.
        var numberOfCardsPerPlayerInt: Int
        switch numberOfPlayersInt {
        case 2, 3:
            numberOfCardsPerPlayerInt = 5
        case 4, 5:
            numberOfCardsPerPlayerInt = 4
        default:
            numberOfCardsPerPlayerInt = 3
        }
        for player in playerArray {
            player.handCardArray = deck.drawCards(numberOfCardsPerPlayerInt)
        }
    }
    // Make new, deal hands to given players.
    init(deck: Deck, playerArray: [Player]) {
        super.init()
        self.deck = deck
        self.playerArray = playerArray
        currentPlayerIndex = 0
        dealHands()
    }
    // Make from previous game state. Just change current player.
    init(endingGameState: EndingGameState) {
        super.init()
        currentPlayerIndex = endingGameState.currentPlayerIndex
        deck = endingGameState.deck.copy() as Deck
        discardsCardArray = endingGameState.discardsCardArray
        numberOfCluesLeftInt = endingGameState.numberOfCluesLeftInt
        numberOfStrikesLeftInt = endingGameState.numberOfStrikesLeftInt
        numberOfTurnsPlayedWithEmptyDeckInt = endingGameState.numberOfTurnsPlayedWithEmptyDeckInt
        for player in endingGameState.playerArray {
            playerArray.append(player.copy() as Player)
        }
        scoreDictionary = endingGameState.scoreDictionary
        moveToNextPlayer()
    }
    // Change current player to next player.
    func moveToNextPlayer() {
        currentPlayerIndex = currentPlayerIndex + 1
        if currentPlayerIndex == numberOfPlayersInt {
            currentPlayerIndex = 0
        }
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
    // String describing the given action and its result.
    func stringForAction(action: Action) -> String {
        var resultString = "\n\(currentPlayer.nameString)"
        let index = action.targetCardIndexInt
        let card = currentPlayer.handCardArray[index]
        // Card position and abbreviation.
        let cardPositionString = "card \(index + 1): \(card.string)"
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
