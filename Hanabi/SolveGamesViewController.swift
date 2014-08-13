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
//        let numberOfGamesPlayedInt = solverElf.numberOfGamesPlayedInt
        resultsString += "Games: \(solverElf.numberOfGamesPlayedInt)"
        // Round to 1 digit.
        let averageScoreFloat = round(solverElf.averageScoreFloat, numberOfDecimalsInt: 1)
        resultsString += "\nAverage score: \(averageScoreFloat)"
        // Round to 1 digit.
        let averageNumberOfTurnsFloat = round(solverElf.averageNumberOfTurnsFloat, numberOfDecimalsInt: 1)
        resultsString += "\nAverage # of turns: \(solverElf.averageNumberOfTurnsFloat)"
//        let numberOfGamesLostInt = solverElf.numberOfGamesLostInt
        // let gamesLost = solverElf.numberAndPercentOfGamesLost()
        // gamesLost.numberInt, gamesLost.percentFloat
        solverElf.percentOfGamesLostFloat
//        let percentOfGamesLostFloat = Float(numberOfGamesLostInt) * 100 / Float(numberOfGamesPlayedInt)
        resultsString += "\nGames lost: \(solverElf.numberOfGamesLostInt) (\(solverElf.percentOfGamesLostFloat)%)"
        resultsString += "\nSeeds for games lost (max 10):"
        var seedsShownInt = 0
        for game in solverElf.gameArray {
            if !game.wasWon() && seedsShownInt < 10 {
                resultsString += "\n\(game.seedUInt32)"
                seedsShownInt++
            }
        }
        // Round to 3 digits.
        let numberOfSecondsSpentDouble = round(solverElf.numberOfSecondsSpentDouble * 1000) / 1000
        let averageSecondsSpentDouble = round(solverElf.numberOfSecondsSpentDouble * 1000 / Double(numberOfGamesPlayedInt)) / 1000
        resultsString += "\nTime spent: \(numberOfSecondsSpentDouble) seconds (average: \(averageSecondsSpentDouble))"
        logTextView.text = resultsString
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
