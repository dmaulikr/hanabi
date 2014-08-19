//
//  SolveGamesViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class SolveGamesViewController: UIViewController, LogModelDelegate, SolverElfDelegate, UITextFieldDelegate {
    enum Mode: Int {
        // Planning: user can set things.
        // Solving: elf is calculating/playing.
        // Solved: game done.
        case Planning, Solving, Solved
    }
    let LogTextViewTextKeyPathString = "logTextView.text"
    @IBOutlet weak var cancelButton: UIButton!
    var logModel: LogModel!
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
    deinit {
        removeObserver(self, forKeyPath: LogTextViewTextKeyPathString)
    }
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
    // Update log view.
    func logModelDidAddText() {
        logTextView.text = logModel.text
    }
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        if keyPath == LogTextViewTextKeyPathString {
            let lengthInt = logTextView.text.utf16Count
            logTextView.scrollRangeToVisible(NSMakeRange(lengthInt, 0))
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        viewControllerElf.playButtonDownSound()
    }
    func showResults() {
        var resultsString = "\n"
        resultsString += "Games: \(solverElf.numberOfGamesPlayedInt)"
        let averageScoreDouble = round(Double(solverElf.averageScoreFloat), numberOfDecimalsInt: 1)
        resultsString += "\nScore, avg.: \(averageScoreDouble)"
        let dataForGamesWon = solverElf.dataForGamesWon
        let averageMaxPlaysLeftDouble = round(dataForGamesWon.averageMaxPlaysLeftFloat, numberOfDecimalsInt: 1)
        resultsString += "\nMax plays left in games won, avg.: \(averageMaxPlaysLeftDouble)"
        let averageCluesGivenInWonGamesDouble = round(dataForGamesWon.averageCluesGivenFloat, numberOfDecimalsInt: 1)
        let dataForGamesLost = solverElf.dataForGamesLost
        let percentGamesLostDouble = round(dataForGamesLost.percentFloat, numberOfDecimalsInt: 3)
        resultsString += "\nGames lost: \(dataForGamesLost.numberInt) (\(percentGamesLostDouble)%)"
        let averageCluesGivenInLostGamesDouble = round(dataForGamesLost.averageCluesGivenFloat, numberOfDecimalsInt: 1)
        resultsString += "\nClues given in games won, avg.: \(averageCluesGivenInWonGamesDouble) (lost: \(averageCluesGivenInLostGamesDouble))"
        let averageNumberOfDiscardsInWonGamesDouble = round(dataForGamesWon.averageNumberOfDiscardsFloat, numberOfDecimalsInt: 1)
        let averageNumberOfDiscardsInLostGamesDouble = round(dataForGamesLost.averageNumberOfDiscardsFloat, numberOfDecimalsInt: 1)
        resultsString += "\nDiscards in games won, avg.: \(averageNumberOfDiscardsInWonGamesDouble) (lost: \(averageNumberOfDiscardsInLostGamesDouble))"
        let averageNumberOfBadPlaysInWonGamesDouble = round(dataForGamesWon.averageNumberOfBadPlaysFloat, numberOfDecimalsInt: 1)
        let averageNumberOfBadPlaysInLostGamesDouble = round(dataForGamesLost.averageNumberOfBadPlaysFloat, numberOfDecimalsInt: 1)
        resultsString += "\nBad plays in games won, avg.: \(averageNumberOfBadPlaysInWonGamesDouble) (lost: \(averageNumberOfBadPlaysInLostGamesDouble))"
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
        resultsString += "\nTime spent: \(numberOfSecondsSpentDouble) sec (avg.: \(averageSecondsSpentDouble))"
        logModel.addLine(resultsString)
    }
    func solverElfDidFinishAllGames() {
        mode = .Solved
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
        logModel = (UIApplication.sharedApplication().delegate as AppDelegate).logModel
        logModel.delegate = self
        solverElf = SolverElf()
        solverElf.delegate = self;
        viewControllerElf = ViewControllerElf()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: logTextView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: startButton)
        logTextView.backgroundColor = UIColor.clearColor()
        logModel.reset()
        // To show bottom of log.
        addObserver(self, forKeyPath: LogTextViewTextKeyPathString, options: NSKeyValueObservingOptions.New, context: nil)
        updateUIBasedOnMode()
    }
}
