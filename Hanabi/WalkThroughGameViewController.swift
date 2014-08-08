//
//  WalkThroughGameViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class WalkThroughGameViewController: UIViewController, SolverElfDelegate, UITextFieldDelegate {
    enum Mode: Int {
        // Planning: user can set things.
        // Solving: elf is calculating/playing.
        // Solved: game done.
        case Planning, Solving, Solved
    }
    @IBOutlet weak var cancelButton: UIButton!
    var mode: Mode = .Planning {
        didSet {
            if mode != oldValue {
                updateUIBasedOnMode()
            }
        }
    }
    var numberOfPlayersInt = 3
    @IBOutlet weak var seedNumberTextField: UITextField!
    var seedOptionalUInt32: UInt32?
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    var viewControllerElf: ViewControllerElf!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        mode = .Planning
        solverElf.stopSolving()
    }
    // Play/solve the requested game.
    @IBAction func handleStartButtonTapped() {
        mode = .Solving
        solverElf.solveGameWithSeed(seedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        viewControllerElf.playButtonDownSound()
    }
    // Text fields: random-number seed.
    // multiple text fields?
    // If a valid value, then update model. Show current value in text field.
    // Return a string for the current seed, which is an optional int. If nil, return "" to show text field's placeholder.
    func seedString() -> String {
        if let uint32 = seedOptionalUInt32 {
            return String(uint32)
        } else {
            return ""
        }
    }
    func solverElfDidFinish() {
        mode = .Planning
        updateUIBasedOnMode()
    }
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Valid seed: User should enter either an Int >= 0, or nothing ("") to let computer choose a random seed. If neither, do nothing.
        // this line is crashing on device for some reason
        if let int = theTextField.text.toInt() {
            if int >= 0 {
                // Convert Int to UInt32. srandom() requires UInt32.
                seedOptionalUInt32 = UInt32(int)
            }
        }
        if theTextField.text == "" {
            seedOptionalUInt32 = nil
        }
        theTextField.text = seedString()
    }
    // Dismiss keyboard.
    func textFieldShouldReturn(theTextField: UITextField!) -> Bool {
        theTextField.resignFirstResponder()
        return true
    }
    func updateUIBasedOnMode() {
        switch mode {
        case .Planning:
            cancelButton.enabled = false
            seedNumberTextField.enabled = true
            seedNumberTextField.text = seedString()
            startButton.enabled = true
        case .Solving:
            cancelButton.enabled = true
            seedNumberTextField.enabled = false
            startButton.enabled = false
        case .Solved:
            cancelButton.enabled = false
            seedNumberTextField.enabled = true
            startButton.enabled = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        solverElf = SolverElf()
        solverElf.delegate = self;
        viewControllerElf = ViewControllerElf()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: startButton)
        updateUIBasedOnMode()
    }
}
