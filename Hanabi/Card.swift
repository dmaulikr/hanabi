//
//  Card.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/8/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import Foundation

// Each card has a color and a number.
struct Card {
    enum Color: Int {
        case Blue = 1, Green, Red, White, Yellow
        func letterString() -> String {
            var aLetterString: String
            switch self {
            case Blue:
                aLetterString = "B"
            case Green:
                aLetterString = "G"
            case Red:
                aLetterString = "R"
            case White:
                aLetterString = "W"
            case Yellow:
                aLetterString = "Y"
            default:
                aLetterString = "M"
            }
            return aLetterString
        }
    }
    var color: Color
    var numberInt: Int!
    // Each card can be represented by two letters (e.g., "B4," "Y1").
    func string() -> String {
        return "\(color.letterString())\(numberInt)"
    }
}