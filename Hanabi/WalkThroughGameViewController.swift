//
//  WalkThroughGameViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class WalkThroughGameViewController: UIViewController, SolverElfDelegate, UITextFieldDelegate {
    @IBOutlet weak var cancelButton: UIButton!
    var numberOfPlayersInt = 3
    @IBOutlet weak var seedNumberTextField: UITextField!
    var seedOptionalInt: Int?
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    var viewControllerElf: ViewControllerElf!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        solverElf.stopSolving()
    }
    func solverElfDidChangeMode() {
        updateUIBasedOnMode()
    }
    // Play/solve the requested game.
    @IBAction func handleStartButtonTapped() {
        solverElf.solveGameWithSeed(seedOptionalInt, numberOfPlayersInt: numberOfPlayersInt)
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        viewControllerElf.playButtonDownSound()
    }
    // Text fields: random-number seed.
    // multiple text fields?
    // If a valid value, then update model. Show current value in text field.
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Valid seed: User should enter either an Int >= 0, or nothing ("") to let computer choose a random seed. If neither, do nothing.
        if let theInt = theTextField.text.toInt() {
            if theInt >= 0 {
                seedOptionalInt = theInt
            }
        }
        if theTextField.text == "" {
            seedOptionalInt = nil
        }
        theTextField.text = seedString()
    }
    // Dismiss keyboard.
    func textFieldShouldReturn(theTextField: UITextField!) -> Bool {
        theTextField.resignFirstResponder()
        return true
    }
    // Return a string for the current seed, which is an optional int. If nil, return "" to show text field's placeholder.
    func seedString() -> String {
        if let theInt = seedOptionalInt {
            return String(theInt)
        } else {
            return ""
        }
    }
    func updateUIBasedOnMode() {
        switch solverElf.mode {
        case SolverElf.Mode.Planning:
            cancelButton.enabled = false
            seedNumberTextField.enabled = true
            seedNumberTextField.text = seedString()
            startButton.enabled = true
        case SolverElf.Mode.Solving:
            cancelButton.enabled = true
            seedNumberTextField.enabled = false
            startButton.enabled = false
        case SolverElf.Mode.Solved:
            cancelButton.enabled = false
            seedNumberTextField.enabled = false
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
