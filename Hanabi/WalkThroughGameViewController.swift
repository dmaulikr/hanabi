//
//  WalkThroughGameViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class WalkThroughGameViewController: UIViewController, SolverElfDelegate, UITableViewDataSource,  UITableViewDelegate, UITextFieldDelegate {
    enum Mode: Int {
        // Planning: user can set things.
        // Solving: elf is calculating/playing.
        // Solved: game done.
        case Planning, Solving, Solved
    }
    let HideActionTitleString = "Hide Action"
    let ShowActionTitleString = "Show Action"
    @IBOutlet weak var cancelButton: UIButton!
    // The turn currently being viewed. Start/setup is 1, last turn is N and end of game is N + 1.
//    var currentTurnInt = 1
    @IBOutlet weak var discardsLabel: UILabel!
    // View enclosing discards label. To make bigger border.
    @IBOutlet weak var discardsView: UIView!
    @IBOutlet weak var gameSettingsView: UIView!
    @IBOutlet weak var logTextView: UITextView!
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
    @IBOutlet weak var showOrHideActionButton: UIButton!
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var turnTableView: UITableView!
    var viewControllerElf: ViewControllerElf!
    @IBOutlet weak var visibleHandsLabel: UILabel!
    // View enclosing visible-hands label. To make bigger border.
    @IBOutlet weak var visibleHandsView: UIView!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        mode = .Planning
        solverElf.stopSolving()
    }
    // If show action, then show turn's ending state. Else, show turn's starting state.
    @IBAction func handleShowOrHideActionButtonTapped(button: UIButton) {
        if button.titleForState(UIControlState.Normal) == ShowActionTitleString {
            if let indexPath = turnTableView.indexPathForSelectedRow() {
                showTurnEnd(indexPath.row)
            }
        } else {
            if let indexPath = turnTableView.indexPathForSelectedRow() {
                showTurnStart(indexPath.row)
            }
        }
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
    func showGameState(gameState: GameState) {
        var scoreString = ""
        for (color, score) in gameState.scoreDictionary {
            scoreString += String(score)
        }
        scoreLabel.text = "Score: BGRWY" +
            "\n       \(scoreString)" +
            "\nClues left: \(gameState.numberOfCluesLeftInt)" +
            "\nStrikes left: \(gameState.numberOfStrikesLeftInt)" +
        "\nCards left: \(gameState.deckCardArray.count)"
        var discardsString = "Discards:"
        for card in gameState.discardsCardArray {
            discardsString += " \(card.string())"
        }
        discardsLabel.text = discardsString
        var visibleHandsString = "Visible hands:"
        for index in 1...gameState.playerArray.count {
            visibleHandsString += "\nP\(index):"
            if index != gameState.currentPlayerNumberInt {
                let player = gameState.playerArray[index - 1]
                for card in player.handCardArray {
                    visibleHandsString += " \(card.string())"
                }
            }
        }
        visibleHandsLabel.text = visibleHandsString
    }
    // Show ending state of given turn.
    func showTurnEnd(turnIndexInt: Int) {
        if let game = solverElf.currentOptionalGame {
            var logString = "Seed: \(game.seedUInt32)"
            let turn = game.turnArray[turnIndexInt]
            logString += turn.actionResultString()
            if let gameState = turn.endingOptionalGameState {
                
                                
                // and show action in a label? or in log view?
                showGameState(gameState)
                
                // Let user hide action.
                showOrHideActionButton.enabled = true
                showOrHideActionButton.setTitle(HideActionTitleString, forState: UIControlState.Normal)
            }
            logTextView.text = logString
        }
    }
    // Show starting state of given turn.
    func showTurnStart(turnIndexInt: Int) {
        if let game = solverElf.currentOptionalGame {
            logTextView.text = "Seed: \(game.seedUInt32)"
            let turn = game.turnArray[turnIndexInt]
            let gameState = turn.startingGameState
            showGameState(gameState)
            // Let user see action.
            showOrHideActionButton.enabled = true
            showOrHideActionButton.setTitle(ShowActionTitleString, forState: UIControlState.Normal)
        }
    }
    func solverElfDidFinishAGame() {
        mode = .Solved
        updateUIBasedOnMode()
    }
    //    func tableView(tableView: UITableView!, didDeselectRowAtIndexPath indexPath: NSIndexPath!) {
    //        <#code#>
    //    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // Show turn.
        showTurnStart(indexPath.row)
    }
    // Each cell is "Turn A.B," where A is the round and B is the player. E.g., "Turn 1.1."
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier("TurnCell") as UITableViewCell
        if let game = solverElf.currentOptionalGame {
            let rowIndexInt = indexPath.row
            let numberOfPlayersInt = game.numberOfPlayersInt()
            // 3 players: 0 = 1, 1 = 1, 2 = 1, 3 = 2, 4 = 2, 5 = 2
            let turnNumberInt = (rowIndexInt / numberOfPlayersInt) + 1
            // 3 players: 0 = 1, 1 = 2, 2 = 3, 3 = 1, 4 = 2, 5 = 3
            let playerNumberInt = (rowIndexInt % numberOfPlayersInt) + 1
            tableViewCell.textLabel.text = "Turn \(turnNumberInt).\(playerNumberInt)"
        }
        return tableViewCell;
    }
    // Return the number of turns.
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if let game = solverElf.currentOptionalGame {
            return game.turnArray.count
        } else {
            return 0
        }
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
            discardsView.hidden = true
            scoreView.hidden = true
            seedNumberTextField.enabled = true
            seedNumberTextField.text = seedString()
            showOrHideActionButton.hidden = true
            startButton.enabled = true
            turnTableView.hidden = true
            visibleHandsView.hidden = true
        case .Solving:
            cancelButton.enabled = true
            seedNumberTextField.enabled = false
            showOrHideActionButton.hidden = true
            startButton.enabled = false
            turnTableView.hidden = true
        case .Solved:
            cancelButton.enabled = false
            discardsView.hidden = false
            scoreView.hidden = false
            seedNumberTextField.enabled = true
            showOrHideActionButton.hidden = false
            showOrHideActionButton.enabled = false
            startButton.enabled = true
            turnTableView.hidden = false
            visibleHandsView.hidden = false
            turnTableView.reloadData()
            // Show first turn.
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            turnTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            turnTableView.delegate?.tableView!(turnTableView, didSelectRowAtIndexPath: indexPath)
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
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: logTextView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: scoreView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: showOrHideActionButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: startButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: turnTableView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: visibleHandsView)
        discardsView.backgroundColor = UIColor.clearColor()
        gameSettingsView.backgroundColor = UIColor.clearColor()
        logTextView.backgroundColor = UIColor.clearColor()
        scoreView.backgroundColor = UIColor.clearColor()
        visibleHandsView.backgroundColor = UIColor.clearColor()
        updateUIBasedOnMode()
    }
}
