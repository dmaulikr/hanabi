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
        solverElf.stop()
    }
    // Play/solve the requested number of games.
    @IBAction func handleStartButtonTapped() {
        mode = .Solving
        solverElf.solveGames(numberOfGamesInt, numPlayers: 3)
    }
    // Update log view.
    func logModelDidAddText() {
        dispatch_async(dispatch_get_main_queue()) {
            self.logTextView.text = self.logModel.text
        }
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
        var results = "\n"
        results += "Games: \(solverElf.numGamesPlayed)"
        let avgScore = round(Double(solverElf.avgScore), decimals: 2)
        results += "\nScore, avg.: \(avgScore)"
        let gamesWonStats = solverElf.gamesWonStats
        let gamesLostStats = solverElf.gamesLostStats
        let avgMaxPlaysLeft = round(gamesWonStats.avgMaxPlaysLeft, decimals: 1)
        results += "\nMax plays left in games won, avg.: \(avgMaxPlaysLeft)"
        let percentGamesLost = round(gamesLostStats.percent, decimals: 3)
        results += "\nGames lost: \(gamesLostStats.num) (\(percentGamesLost)%)"
        var roundValues = [gamesWonStats.avgNumCluesGiven, gamesLostStats.avgNumCluesGiven].map( { round($0, decimals: 1) } )
        results += "\nClues given in games won, avg.: \(roundValues[0]) (lost: \(roundValues[1]))"
        roundValues = [gamesWonStats.avgNumDiscards, gamesLostStats.avgNumDiscards].map( { round($0, decimals: 1) } )
        results += "\nDiscards in games won, avg.: \(roundValues[0]) (lost: \(roundValues[1]))"
        roundValues = [gamesWonStats.avgNumBadPlays, gamesLostStats.avgNumBadPlays].map( { round($0, decimals: 1) } )
        results += "\nBad plays in games won, avg.: \(roundValues[0]) (lost: \(roundValues[1]))"
        // Up to 10 seeds for games lost.
        let seeds = gamesLostStats.seeds
        let numSeedsToShow = min(10, seeds.count)
        if numSeedsToShow > 0 {
            results += "\nSeeds for games lost (max 10):"
            for index in 0...(numSeedsToShow - 1) {
                results += "\n\(seeds[index])"
            }
        }
        let secondsSpentStats = solverElf.secondsSpentStats
        roundValues = [secondsSpentStats.num, secondsSpentStats.avg].map( { round($0, decimals: 3) } )
        results += "\nTime spent: \(roundValues[0]) sec (avg.: \(roundValues[1]))"
        results += "\n"
        logModel.addLine(results)
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        logModel = appDelegate.logModel
        logModel.delegate = self
        solverElf = appDelegate.solverElf
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
