//
//  UnknownCard.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/26/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//
// A card whose identity is hidden to some. Includes info on what is known.
import UIKit

class CardBack: NSObject {
    // Cards that the card back could be.
    var optionsCardArray: [Card] {
        var optionsCardArray: [Card] = []
        for (color, optionsArray) in optionsDictionary {
            for indexInt in 0...(optionsArray.count - 1) {
                let optionsInt = optionsArray[indexInt]
                if optionsInt >= 1 {
                    let numberInt = indexInt + 1
                    let card = Card(color: color, numberInt: numberInt)
                    optionsCardArray.append(card)
                }
            }
        }
        return optionsCardArray
    }
    // The options the card could be, based on what is seen and has been clued. This is like a 2D array, but the first part is unordered. Each color has an array of the possible card numbers (1–5), so each element corresponds to a card (e.g., B1). Each element has the number of ways the card back could be that card. E.g., if there are 3 unseen B1s, then this would be 3. If a B1 was played and another was discarded, this would be 1.
    var optionsDictionary: [Card.Color: [Int]] = [:]
    override init() {
        super.init()
        // Start with the full deck. For each color, it's 3/2/2/2/1.
        var int = 1
        while let color = Card.Color.fromRaw(int) {
            let intArray = [3, 2, 2, 2, 1]
            optionsDictionary[color] = intArray
            int++
        }
    }
}
