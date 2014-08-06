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
    @IBOutlet weak var seedNumberTextField: UITextField!
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    var viewControllerElf: ViewControllerElf!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        self.solverElf.stopSolving()
    }
    func solverElfDidChangeMode() {
        self.updateUIBasedOnMode()
    }
    // Play/solve the requested number of games.
    @IBAction func handleStartButtonTapped() {
        self.solverElf.solveAGame()
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        self.viewControllerElf.playButtonDownSound()
    }
    // Text fields: random-number seed.
    // multiple text fields?
    // If a valid value, then update model. Show current value in text field.
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Valid seed: User should enter either an Int >= 0, or nothing ("") to let computer choose a random seed. If neither, do nothing.
        if let theInt = theTextField.text.toInt() {
            if theInt >= 0 {
                self.solverElf.seedNumberOptionalInt = theInt
            }
        }
        if theTextField.text == "" {
            self.solverElf.seedNumberOptionalInt = nil
        }
        // Show seed or placeholder.
        var aString: String
        if let theInt = self.solverElf.seedNumberOptionalInt {
            aString = String(theInt)
        } else {
            aString = ""
        }
        theTextField.text = aString
    }
    // Dismiss keyboard.
    func textFieldShouldReturn(theTextField: UITextField!) -> Bool {
        theTextField.resignFirstResponder()
        return true
    }
    func updateUIBasedOnMode() {
        switch self.solverElf.mode {
        case SolverElf.Mode.Planning:
            self.cancelButton.enabled = false
            self.seedNumberTextField.enabled = true
            self.startButton.enabled = true
        case SolverElf.Mode.Solving:
            self.cancelButton.enabled = true
            self.seedNumberTextField.enabled = false
            self.startButton.enabled = false
        case SolverElf.Mode.Solved:
            self.cancelButton.enabled = false
            self.seedNumberTextField.enabled = false
            self.startButton.enabled = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let aSolverElf = SolverElf()
        aSolverElf.delegate = self;
        self.solverElf = aSolverElf
        self.viewControllerElf = ViewControllerElf()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.startButton)
        self.updateUIBasedOnMode()
    }
}
