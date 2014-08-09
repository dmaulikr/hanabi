//
//  SolveGamesViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class SolveGamesViewController: UIViewController, SolverElfDelegate, UITextFieldDelegate {
    enum Mode: Int {
        // Planning: user can set things.
        // Solving: elf is calculating/playing.
        // Solved: game done.
        case Planning, Solving, Solved
    }
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    var mode: Mode = .Planning {
        didSet {
            if mode != oldValue {
                updateUIBasedOnMode()
            }
        }
    }
    var numberOfGames: Int = 1
    @IBOutlet weak var numberOfGamesTextField: UITextField!
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    var viewControllerElf: ViewControllerElf!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        mode = .Planning
        solverElf.stopSolving()
    }
    // Play/solve the requested number of games.
    @IBAction func handleStartButtonTapped() {
        mode = .Solving
        solverElf.solveGames(numberOfGames, numberOfPlayersInt: 3)
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        viewControllerElf.playButtonDownSound()
    }
    func showResults() {
        let numberOfGamesPlayedInt = solverElf.numberOfGamesPlayed()
        println("Games: \(numberOfGamesPlayedInt)")
        println("Average score: \(solverElf.averageScore())")
        println("Average # of turns: \(solverElf.averageNumberOfTurns())")
        let numberOfGamesLostInt = solverElf.numberOfGamesLost()
        let percentOfGamesLostFloat = Float(numberOfGamesLostInt) * 100 / Float(numberOfGamesPlayedInt)
        println("Games lost: \(numberOfGamesLostInt) (\(percentOfGamesLostFloat)%)")
        println("Seeds for games lost:")
        println("Time spent: \(solverElf.numberOfSecondsSpentFloat) seconds")
    }
    func solverElfDidFinishAllGames() {
        mode = .Solved
        updateUIBasedOnMode()
    }
    // Text field is for number of games to play/solve.
    // If a valid value, then update model. Show current value in text field.
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Valid: Int >= 1.
        if let theInt = theTextField.text.toInt() {
            if theInt >= 1 {
                numberOfGames = theInt
            }
        }
        theTextField.text = String(numberOfGames)
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
            numberOfGamesTextField.enabled = true
            numberOfGamesTextField.text = String(numberOfGames)
            startButton.enabled = true
        case .Solving:
            cancelButton.enabled = true
            numberOfGamesTextField.enabled = false
            startButton.enabled = false
        case .Solved:
            cancelButton.enabled = false
            numberOfGamesTextField.enabled = true
            startButton.enabled = true
            showResults()
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
