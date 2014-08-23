//
//  PureInfoAI.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/22/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class PureInfoAI: AbstractAI {
    override var buttonTitleString: String {
        return "Pure Info"
    }
    override var tableViewCellString: String {
        return "Pure Info"
    }
    override init() {
        super.init()
        type = AIType.PureInfo
    }
}
