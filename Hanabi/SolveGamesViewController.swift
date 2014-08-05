//
//  SolveGamesViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class SolveGamesViewController: UIViewController, SolverElfDelegate, UITextFieldDelegate {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var numberOfGamesTextField: UITextField!
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
        self.solverElf.solveGames()
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        self.viewControllerElf.playButtonDownSound()
    }
    // Text field is for number of games to play/solve.
    // If a valid value, then update model. Show current value in text field.
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Valid: Int >= 1.
        if let theInt = theTextField.text.toInt() {
            if theInt >= 1 {
                self.solverElf.numberOfGamesToPlayInt = theInt
            }
        }
        theTextField.text = String(self.solverElf.numberOfGamesToPlayInt)
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
            self.numberOfGamesTextField.enabled = true
            self.startButton.enabled = true
        case SolverElf.Mode.Solving:
            self.cancelButton.enabled = true
            self.numberOfGamesTextField.enabled = false
            self.startButton.enabled = false
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
