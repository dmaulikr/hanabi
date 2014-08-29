//
//  WalkThroughGameViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class WalkThroughGameViewController: UIViewController, LogModelDelegate, SolverElfDelegate, UITableViewDataSource,  UITableViewDelegate, UITextFieldDelegate {
    enum Mode: Int {
        // Planning: user can set things.
        // Solving: elf is calculating/playing.
        // Solved: game done.
        case Planning, Solving, Solved
    }
    let LogTextViewTextKeyPathString = "logTextView.text"
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    // How many non-play actions players can make and still win.
    @IBOutlet weak var cushionLabel: UILabel!
    @IBOutlet weak var cushionView: UIView!
    @IBOutlet weak var discardsLabel: UILabel!
    // View enclosing discards label. To make bigger border.
    @IBOutlet weak var discardsView: UIView!
    @IBOutlet weak var gameSettingsView: UIView!
    @IBOutlet weak var logDeckButton: UIButton!
    var logModel: LogModel!
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
    @IBOutlet weak var showActionSwitch: UISwitch!
    @IBOutlet weak var showCurrentHandSwitch: UISwitch!
    @IBOutlet weak var showTurnEndSwitch: UISwitch!
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
        solverElf.stop()
    }
    // Log the current turn's deck.
    @IBAction func handleLogDeckButtonTapped() {
        let aTurnData = solverElf.aTurnData(gameNum: 1, turnNum: turnNumberOptionalInt!, turnEnd: showTurnEndSwitch.on, showCurrentHand: showCurrentHandSwitch.on)
        logModel.addLine("Deck: \(aTurnData.deckDescription)")
    }
    // Update UI.
    @IBAction func handleShowActionSwitchTapped(theSwitch: UISwitch) {
        updateUIBasedOnMode()
    }
    // Update UI.
    @IBAction func handleShowCurrentHandSwitchTapped(theSwitch: UISwitch) {
        updateUIBasedOnMode()
    }
    // Update UI.
    @IBAction func handleShowTurnEndSwitchTapped(theSwitch: UISwitch) {
        updateUIBasedOnMode()
    }
    // Play/solve the requested game.
    @IBAction func handleStartButtonTapped() {
        mode = .Solving
        solverElf.solveGame(seed: userSeedOptionalUInt32, numPlayers: numberOfPlayersInt)
    }
    // Update log view.
    func logModelDidAddText() {
        dispatch_async(dispatch_get_main_queue()) {
            self.logTextView.text = self.logModel.text
        }
    }
    // Log the seed used to create this game.
    func logSeedUsed() {
        logModel.addLine("Seed: \(solverElf.seedForFirstGame)")
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
        let aTurnData = solverElf.aTurnData(gameNum: 1, turnNum: turnNumberOptionalInt!, turnEnd: showTurnEndSwitch.on, showCurrentHand: showCurrentHandSwitch.on)
        cushionLabel.text = "Plays needed: \(aTurnData.numPointsNeeded)" +
        "\nPlays left, max: \(aTurnData.maxNumPlaysLeft)"
        discardsLabel.text = "Discards: \(aTurnData.discardsDescription)"
        scoreLabel.text = "Score: BGRWY" +
            "\n       \(aTurnData.scoreDescription)" +
            "\nClues left: \(aTurnData.numCluesLeft)" +
            "\nStrikes left: \(aTurnData.numStrikesLeft)" +
        "\nCards left: \(aTurnData.numCardsLeft)"
        var visibleHandsDescription = NSMutableAttributedString(string:"Visible hands:")
        visibleHandsDescription.appendAttributedString(aTurnData.visibleHandsDescription)
        visibleHandsLabel.attributedText = visibleHandsDescription
        if showActionSwitch.on {
            actionLabel.text = aTurnData.actionDescription
        } else {
            actionLabel.text = ""
        }
    }
    func solverElfDidFinishAGame() {
        logSeedUsed()
        turnTableView.reloadData()
        mode = .Solved
    }
    // Note selected turn. Update UI.
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        turnNumberOptionalInt = indexPath.row + 1
        updateUIBasedOnMode()
    }
    // Each cell is "Round A.B," where A is the round and B is the player number. E.g., "Round 1.1."
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier("TurnCell") as UITableViewCell
        let turnNumberInt = indexPath.row + 1
        let roundSubroundString = solverElf.firstGameSubroundDescription(turnNum: turnNumberInt)
        tableViewCell.textLabel.text = "Round \(roundSubroundString)"
        return tableViewCell
    }
    // Return number of turns.
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if let numTurns = solverElf.numTurnsForFirstGame {
            return numTurns
        } else {
            return 0
        }
    }
    // Text fields: user seed.
    // Check if valid value. Show current value in text field.
    func textFieldDidEndEditing(textField: UITextField!) {
        // Valid seed: Either Int32 >= 0 or nothing (""). Latter lets computer choose a random seed. If neither, do nothing.
        if let int = textField.text.toInt() {
            if int >= 0 {
                // Convert Int to UInt32. srandom() requires UInt32.
                userSeedOptionalUInt32 = UInt32(int)
            }
        }
        if textField.text == "" {
            userSeedOptionalUInt32 = nil
        }
        textField.text = userSeedString
    }
    // Dismiss keyboard.
    func textFieldShouldReturn(theTextField: UITextField!) -> Bool {
        theTextField.resignFirstResponder()
        return true
    }
    func updateUIBasedOnMode() {
        switch mode {
        case .Planning:
            actionView.hidden = true
            cancelButton.enabled = false
            cushionView.hidden = true
            discardsView.hidden = true
            logDeckButton.hidden = true
            scoreView.hidden = true
            startButton.enabled = true
            turnTableView.hidden = true
            userSeedNumberTextField.enabled = true
            userSeedNumberTextField.text = userSeedString
            visibleHandsView.hidden = true
        case .Solving:
            turnNumberOptionalInt = nil
            cancelButton.enabled = true
            startButton.enabled = false
            turnTableView.hidden = true
            userSeedNumberTextField.enabled = false
        case .Solved:
            actionView.hidden = false
            cancelButton.enabled = false
            cushionView.hidden = false
            discardsView.hidden = false
            logDeckButton.hidden = false
            scoreView.hidden = false
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        logModel = appDelegate.logModel
        logModel.delegate = self
        solverElf = appDelegate.solverElf
        solverElf.delegate = self;
        viewControllerElf = ViewControllerElf()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: actionView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: cushionView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: discardsView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: gameSettingsView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: logDeckButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: logTextView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: scoreView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: startButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: turnTableView)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: visibleHandsView)
        actionView.backgroundColor = UIColor.clearColor()
        cushionView.backgroundColor = UIColor.clearColor()
        discardsView.backgroundColor = UIColor.clearColor()
        gameSettingsView.backgroundColor = UIColor.clearColor()
        logTextView.backgroundColor = UIColor.clearColor()
        scoreView.backgroundColor = UIColor.clearColor()
        visibleHandsView.backgroundColor = UIColor.clearColor()
        logModel.reset()
        // To show bottom of log.
        addObserver(self, forKeyPath: LogTextViewTextKeyPathString, options: NSKeyValueObservingOptions.New, context: nil)
        updateUIBasedOnMode()
    }
}
