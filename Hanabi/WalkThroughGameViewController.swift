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
    // How many non-play actions players can make and still win.
    @IBOutlet weak var cushionLabel: UILabel!
    @IBOutlet weak var cushionView: UIView!
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
    @IBOutlet weak var showOrHideActionButton: UIButton!
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var turnTableView: UITableView!
    @IBOutlet weak var userSeedNumberTextField: UITextField!
    var userSeedOptionalUInt32: UInt32?
    // String showing user-requested seed, which may be nil. If nil, return "" to allow text field's placeholder. (Placeholder says "random," because game will choose a random seed.)
    var userSeedString: String {
        get {
            if let uint32 = userSeedOptionalUInt32 {
                return String(uint32)
            } else {
                return ""
            }
        }
    }
    var viewControllerElf: ViewControllerElf!
    @IBOutlet weak var visibleHandsLabel: UILabel!
    // View enclosing visible-hands label. To make bigger border.
    @IBOutlet weak var visibleHandsView: UIView!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        mode = .Planning
        solverElf.stopSolving()
    }
    // If show-action, then show selected turn's end. Else, show turn's start.
    @IBAction func handleShowOrHideActionButtonTapped(button: UIButton) {
        let indexPath = turnTableView.indexPathForSelectedRow()
        let turnNumberInt = indexPath.row + 1
        var turnEndBool: Bool
        if button.titleForState(UIControlState.Normal) == ShowActionTitleString {
            turnEndBool = true
        } else {
            turnEndBool = false
        }
        showTurnForGame(1, turnNumberInt: turnNumberInt, turnEndBool: turnEndBool)
    }
    // Play/solve the requested game.
    @IBAction func handleStartButtonTapped() {
        mode = .Solving
        solverElf.solveGameWithSeed(userSeedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        viewControllerElf.playButtonDownSound()
    }
    // Show seed used to create this game.
    func showSeedUsed() {
        var logString: String = logTextView.text
        let seedUInt32 = solverElf.seedUInt32ForGame(1)
        logString += "\nSeed: \(seedUInt32)"
        logTextView.text = logString
    }
    // Show given turn for given game. If turn end, show action and end of turn. Else, show start of turn.
    func showTurnForGame(gameNumberInt: Int, turnNumberInt: Int, turnEndBool: Bool) {
        var buttonTitleString: String
        if turnEndBool {
            var logString: String = logTextView.text
            logString += solverElf.actionStringForTurnForGame(1, turnNumberInt: turnNumberInt)
            logTextView.text = logString
            buttonTitleString = HideActionTitleString
        } else {
            buttonTitleString = ShowActionTitleString
        }
        let turnDataForGame = solverElf.turnDataForGame(1, turnNumberInt: turnNumberInt, turnEndBool: turnEndBool)
        cushionLabel.text = "Points needed: \(turnDataForGame.numberOfPointsNeededInt)" +
        "\nPlays left, max: (\(turnDataForGame.maxNumberOfPlaysLeftInt))"
        discardsLabel.text = "Discards: \(turnDataForGame.discardsString)"
        scoreLabel.text = "Score: BGRWY" +
            "\n       \(turnDataForGame.scoreString)" +
            "\nClues left: \(turnDataForGame.numberOfCluesLeftInt)" +
            "\nStrikes left: \(turnDataForGame.numberOfStrikesLeftInt)" +
        "\nCards left: \(turnDataForGame.numberOfCardsLeftInt)"
        visibleHandsLabel.text = "Visible hands:\(turnDataForGame.visibleHandsString)"
        // Let user hide (or see) turn's action and end.
        showOrHideActionButton.enabled = true
        showOrHideActionButton.setTitle(buttonTitleString, forState: UIControlState.Normal)
    }
    func solverElfDidFinishAGame() {
        mode = .Solved
        updateUIBasedOnMode()
    }
    // Show selected turn.
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let turnNumberInt = indexPath.row + 1
        showTurnForGame(1, turnNumberInt: turnNumberInt, turnEndBool: false)
    }
    // Each cell is "Round A.B," where A is the round and B is the player number. E.g., "Round 1.1."
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier("TurnCell") as UITableViewCell
        let turnNumberInt = indexPath.row + 1
        let roundSubroundString = solverElf.roundSubroundString(turnNumberInt)
        tableViewCell.textLabel.text = "Round \(roundSubroundString)"
        return tableViewCell;
    }
    // Return the number of turns.
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return solverElf.numberOfTurnsForGame(1)
    }
    // Text fields: user seed.
    // Check if valid value. Show current value in text field.
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Valid seed: User should enter either an Int >= 0 or nothing (""). Latter lets computer choose a random seed. If neither, do nothing.
        if let int = theTextField.text.toInt() {
            if int >= 0 {
                // Convert Int to UInt32. srandom() requires UInt32.
                userSeedOptionalUInt32 = UInt32(int)
            }
        }
        if theTextField.text == "" {
            userSeedOptionalUInt32 = nil
        }
        theTextField.text = userSeedString
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
            showOrHideActionButton.hidden = true
            startButton.enabled = true
            turnTableView.hidden = true
            userSeedNumberTextField.enabled = true
            userSeedNumberTextField.text = userSeedString
            visibleHandsView.hidden = true
        case .Solving:
            cancelButton.enabled = true
            showOrHideActionButton.hidden = true
            startButton.enabled = false
            turnTableView.hidden = true
            userSeedNumberTextField.enabled = false
        case .Solved:
            cancelButton.enabled = false
            discardsView.hidden = false
            scoreView.hidden = false
            showOrHideActionButton.hidden = false
            showOrHideActionButton.enabled = false
            startButton.enabled = true
            turnTableView.hidden = false
            userSeedNumberTextField.enabled = true
            visibleHandsView.hidden = false
            turnTableView.reloadData()
            // Show seed, then first turn.
            showSeedUsed()
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
        logTextView.text = ""
        updateUIBasedOnMode()
    }
}
