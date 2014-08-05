//
//  SolveGamesViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class SolveGamesViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var numberOfGamesTextField: UITextField!
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    var viewControllerElf: ViewControllerElf!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        println("SGVC handleCancelButtonTapped")
    }
    // Play/solve the requested number of games.
    @IBAction func handleStartButtonTapped() {
        println("SGVC handleStartButtonTapped")
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
    // Update UI from model, based on current mode.
    // wait until I really need this (e.g., mode changes -> several things change)
//    func updateUI() {
//        // update textfield from model
//        
//        // if mode is planning do this
//        self.cancelButton.enabled = false
//        // if mode is calculating, do this
////        self.cancelButton.enabled = true
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.solverElf = SolverElf()
        self.viewControllerElf = ViewControllerElf()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.startButton)
        // this might be under updateUI and depend on mode
        self.cancelButton.enabled = false
    }
}
