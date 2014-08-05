//
//  SolverElf.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/5/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

protocol SolverElfDelegate {
    func solverElfDidChangeMode()
}

private var myContext = 0

class SolverElf: NSObject {
    enum Mode: Int {
        case Planning, Solving
    }
    var delegate: SolverElfDelegate? = nil
    var mode: Mode = Mode.Planning {
    didSet {
        if self.mode != oldValue {
            self.delegate?.solverElfDidChangeMode()
        }
    }
    }
    var numberOfGamesToPlayInt = 1
    init() {
        super.init()
    }
    func solveGames() {
        self.mode = Mode.Solving
    }
    func stopSolving() {
        self.mode = Mode.Planning
    }
}
