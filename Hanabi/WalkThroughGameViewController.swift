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
    // The turn currently being viewed. Start/setup is 1, last turn is N and end of game is N + 1.
    var currentTurnInt = 1
    @IBOutlet weak var discardsLabel: UILabel!
    // View enclosing discards label. To make bigger border.
    @IBOutlet weak var discardsView: UIView!
    var mode: Mode = .Planning {
        didSet {
            if mode != oldValue {
                updateUIBasedOnMode()
            }
        }
    }
    var numberOfPlayersInt = 3
    @IBOutlet weak var scoreLabel: UILabel!
    // View enclosing score label. To make bigger border.
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var seedNumberTextField: UITextField!
    var seedOptionalUInt32: UInt32?
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var gameSettingsView: UIView!
    var viewControllerElf: ViewControllerElf!
    @IBOutlet weak var visibleHandsLabel: UILabel!
    // View enclosing visible-hands label. To make bigger border.
    @IBOutlet weak var visibleHandsView: UIView!
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
    // Show data for given turn.
    // ok we can show the turn, but it has a starting and ending game state
    // how will the user see the action and ending state? in the same table picker, or separately? (separately seems interesting)
    func showTurn(turnInt: Int) {
        if let game = solverElf.currentOptionalGame {
            let turnArray = game.turnArray
            if turnArray.count >= turnInt {
                let turn = turnArray[turnInt - 1]
                let gameState = turn.startingGameState
                var scoreString = ""
                for (color, score) in gameState.scoreDictionary {
                    scoreString += String(score)
                }
                scoreLabel.text = "Score: BGRWY" +
                "\n       \(scoreString)" +
                "\nClues left: \(gameState.numberOfCluesLeftInt)" +
                "\nStrikes left: \(gameState.numberOfStrikesLeftInt)" +
                "\nCards left: \(gameState.deckCardArray.count)"
                var discardsString = ""
                discardsLabel.text = "Discards:"
                "\n\(discardsString)"
                var visibleHandsString = ""
                for index in 1...gameState.playerArray.count {
                    visibleHandsString += "\nP\(index):"
                    if index != gameState.currentPlayerNumberInt {
                        let player = gameState.playerArray[index - 1]
                        for card in player.handCardArray {
                            visibleHandsString += " \(card.string())"
                        }
                    }
                }
                visibleHandsLabel.text = "Visible hands:" +
                "\(visibleHandsString)"
            }
        }
    }
    func solverElfDidFinish() {
        mode = .Solved
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
            showTurn(currentTurnInt)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        solverElf = SolverElf()
        solverElf.delegate = self;
        viewControllerElf = ViewControllerElf()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: discardsView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: gameSettingsView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: scoreView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: startButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: visibleHandsView)
        discardsView.backgroundColor = UIColor.clearColor()
        gameSettingsView.backgroundColor = UIColor.clearColor()
        scoreView.backgroundColor = UIColor.clearColor()
        visibleHandsView.backgroundColor = UIColor.clearColor()
        updateUIBasedOnMode()
    }
}
