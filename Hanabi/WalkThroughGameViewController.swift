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
    let LogTextViewTextKeyPathString = "logTextView.text"
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
    @IBOutlet weak var showCurrentHandSwitch: UISwitch!
    @IBOutlet weak var showOrHideActionButton: UIButton!
    // Whether to show a turn's ending state (vs. starting state).
    var showTurnEndBool = false
    var solverElf: SolverElf!
    @IBOutlet weak var startButton: UIButton!
    // Turn to view.
    var turnNumberOptionalInt: Int?
    @IBOutlet weak var turnTableView: UITableView!
    @IBOutlet weak var userSeedNumberTextField: UITextField!
    var userSeedOptionalUInt32: UInt32?
    // String showing user-requested seed, which may be nil. If nil, return "" to allow text field's placeholder. (Placeholder says "random," because game will choose a random seed.)
    var userSeedString: String {
        if let uint32 = userSeedOptionalUInt32 {
            return String(uint32)
        } else {
            return ""
        }
    }
    var viewControllerElf: ViewControllerElf!
    @IBOutlet weak var visibleHandsLabel: UILabel!
    // View enclosing visible-hands label. To make bigger border.
    @IBOutlet weak var visibleHandsView: UIView!
    deinit {
        removeObserver(self, forKeyPath: LogTextViewTextKeyPathString)
    }
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        mode = .Planning
        solverElf.stopSolving()
    }
    // Change flag. Update UI.
    @IBAction func handleShowOrHideActionButtonTapped(button: UIButton) {
        showTurnEndBool = !showTurnEndBool
        updateUIBasedOnMode()
    }
    // Update UI.
    @IBAction func handleShowCurrentHandSwitchTapped(theSwitch: UISwitch) {
        updateUIBasedOnMode()
    }
    // Play/solve the requested game.
    @IBAction func handleStartButtonTapped() {
        mode = .Solving
        solverElf.solveGameWithSeed(userSeedOptionalUInt32, numberOfPlayersInt: numberOfPlayersInt)
    }
    // Log the seed used to create this game.
    func logSeedUsed() {
        var logString: String = logTextView.text
        let seedUInt32 = solverElf.seedUInt32ForFirstGame
        logString += "\nSeed: \(seedUInt32)"
        logTextView.text = logString
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
    // Show selected turn for given game.
    func showSelectedTurnForGame(gameNumberInt: Int) {
        let dataForTurnForGame = solverElf.dataForTurnForGame(1, turnNumberInt: turnNumberOptionalInt!, turnEndBool: showTurnEndBool, showCurrentHandBool: showCurrentHandSwitch.on)
        //If show turn end, show action and end of turn. Else, show start of turn.
        if showTurnEndBool {
            var logString: String = logTextView.text
            logString += dataForTurnForGame.actionString
            logTextView.text = logString
        } else {
        }
        cushionLabel.text = "Plays needed: \(dataForTurnForGame.numberOfPointsNeededInt)" +
        "\nPlays left, max: \(dataForTurnForGame.maxNumberOfPlaysLeftInt)"
        discardsLabel.text = "Discards: \(dataForTurnForGame.discardsString)"
        scoreLabel.text = "Score: BGRWY" +
            "\n       \(dataForTurnForGame.scoreString)" +
            "\nClues left: \(dataForTurnForGame.numberOfCluesLeftInt)" +
            "\nStrikes left: \(dataForTurnForGame.numberOfStrikesLeftInt)" +
        "\nCards left: \(dataForTurnForGame.numberOfCardsLeftInt)"
        var vHMutableAttributedString = NSMutableAttributedString(string:"Visible hands:")
        vHMutableAttributedString.appendAttributedString(dataForTurnForGame.visibleHandsAttributedString)
        visibleHandsLabel.attributedText = vHMutableAttributedString
    }
    func solverElfDidFinishAGame() {
        logSeedUsed()
        turnTableView.reloadData()
        mode = .Solved
    }
    // Show selected turn.
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        turnNumberOptionalInt = indexPath.row + 1
        showTurnEndBool = false
        updateUIBasedOnMode()
    }
    // Each cell is "Round A.B," where A is the round and B is the player number. E.g., "Round 1.1."
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier("TurnCell") as UITableViewCell
        let turnNumberInt = indexPath.row + 1
        let roundSubroundString = solverElf.roundSubroundStringForTurnForFirstGame(turnNumberInt)
        tableViewCell.textLabel.text = "Round \(roundSubroundString)"
        return tableViewCell;
    }
    // Return number of turns.
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if let numberOfTurnsInt = solverElf.numberOfTurnsOptionalIntForFirstGame {
            return numberOfTurnsInt
        } else {
            return 0
        }
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
            cushionView.hidden = true
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
            cushionView.hidden = false
            discardsView.hidden = false
            scoreView.hidden = false
            showOrHideActionButton.hidden = false
            var buttonTitleString: String
            if showTurnEndBool {
                buttonTitleString = HideActionTitleString
            } else {
                buttonTitleString = ShowActionTitleString
            }
            showOrHideActionButton.setTitle(buttonTitleString, forState: UIControlState.Normal)
            startButton.enabled = true
            turnTableView.hidden = false
            userSeedNumberTextField.enabled = true
            visibleHandsView.hidden = false
            // If no selected turn, select first one.
            if turnNumberOptionalInt == nil {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                turnTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                turnNumberOptionalInt = indexPath.row + 1
            }
            showSelectedTurnForGame(1)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        solverElf = SolverElf()
        solverElf.delegate = self;
        viewControllerElf = ViewControllerElf()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: cushionView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: discardsView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: gameSettingsView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: logTextView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: scoreView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: showOrHideActionButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: startButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: turnTableView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: visibleHandsView)
        cushionView.backgroundColor = UIColor.clearColor()
        discardsView.backgroundColor = UIColor.clearColor()
        gameSettingsView.backgroundColor = UIColor.clearColor()
        logTextView.backgroundColor = UIColor.clearColor()
        scoreView.backgroundColor = UIColor.clearColor()
        visibleHandsView.backgroundColor = UIColor.clearColor()
        logTextView.text = ""
        // To show bottom of log.
        addObserver(self, forKeyPath: LogTextViewTextKeyPathString, options: NSKeyValueObservingOptions.New, context: nil)
        updateUIBasedOnMode()
    }
}
