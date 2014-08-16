//
//  LogModel.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/16/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

protocol LogModelDelegate {
    func logModelDidAddText()
}

class LogModel: NSObject {
    var delegate: LogModelDelegate?
    var text = ""
    // Add text to log. Include linebreak.
    func addLine(string: String) {
        text += "\(string)\n"
        delegate?.logModelDidAddText()
    }
    func reset() {
        text = ""
    }
}
