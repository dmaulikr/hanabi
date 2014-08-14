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
    var numberOfGamesInt = 1
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
        solverElf.solveGames(numberOfGamesInt, numberOfPlayersInt: 3)
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        viewControllerElf.playButtonDownSound()
    }
    func showResults() {
        var resultsString = ""
        resultsString += "Games: \(solverElf.numberOfGamesPlayedInt)"
        let averageScoreFloat = round(solverElf.averageScoreFloat, numberOfDecimalsInt: 1)
        resultsString += "\nAverage score: \(averageScoreFloat)"
        let averageNumberOfTurnsForGamesWonFloat = round(solverElf.averageNumberOfTurnsForGamesWonFloat, numberOfDecimalsInt: 1)
        resultsString += "\nAverage # of turns for games won: \(averageNumberOfTurnsForGamesWonFloat)"
        let dataForGamesLost = solverElf.dataForGamesLost
        let percentOfGamesLostFloat = round(dataForGamesLost.percentFloat, numberOfDecimalsInt: 3)
        resultsString += "\nGames lost: \(dataForGamesLost.numberInt) (\(percentOfGamesLostFloat)%)"
        // Show up to 10 seeds.
        let seedArray = dataForGamesLost.seedArray
        let numberOfSeedsToShowInt = min(10, seedArray.count)
        if numberOfSeedsToShowInt > 0 {
            resultsString += "\nSeeds for games lost (max 10):"
            for numberInt in 1...numberOfSeedsToShowInt {
                let index = numberInt - 1
                resultsString += "\n\(seedArray[index])"
            }
        }
        let dataForSecondsSpent = solverElf.dataForSecondsSpent
        let numberOfSecondsSpentDouble = round(dataForSecondsSpent.numberDouble, numberOfDecimalsInt: 3)
        let averageSecondsSpentDouble = round(dataForSecondsSpent.averageDouble, numberOfDecimalsInt: 3)
        resultsString += "\nTime spent: \(numberOfSecondsSpentDouble) seconds (average: \(averageSecondsSpentDouble))"
        logTextView.text = logTextView.text + resultsString
    }
    func solverElfDidFinishAllGames() {
        mode = .Solved
        updateUIBasedOnMode()
    }
    // Text field is for number of games to play/solve.
    // Check if valid value. Show current value in text field.
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Valid: Int >= 1.
        if let int = theTextField.text.toInt() {
            if int >= 1 {
                numberOfGamesInt = int
            }
        }
        theTextField.text = String(numberOfGamesInt)
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
            numberOfGamesTextField.text = String(numberOfGamesInt)
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
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: logTextView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: startButton)
        logTextView.backgroundColor = UIColor.clearColor()
        logTextView.text = ""
        updateUIBasedOnMode()
    }
}
