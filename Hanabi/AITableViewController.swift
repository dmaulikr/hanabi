//
//  AITableViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/22/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit
protocol AITableViewControllerDelegate {
    func aiTableViewControllerDidSelectAI()
}
class AITableViewController: UITableViewController {
    var delegate: AITableViewControllerDelegate?
    var solverElf: SolverElf!
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return 1
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier("AICell", forIndexPath: indexPath) as UITableViewCell
        let aiNum = indexPath.row + 1
        let ai = solverElf.ai(num: aiNum)
        let aiTableViewCellString = ai.tableViewCellString
        tableViewCell.textLabel.text = "\(aiTableViewCellString)"
        // If currently selected AI, add checkmark.
        var tableViewCellAccessoryType: UITableViewCellAccessoryType
        if ai == solverElf.currentAI {
            tableViewCellAccessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            tableViewCellAccessoryType = UITableViewCellAccessoryType.None
        }
        tableViewCell.accessoryType = tableViewCellAccessoryType;
        return tableViewCell
    }
    // Set checkmark. Set current AI.
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // Remove checkmark from the previously selected cell.
        let aiNumberInt = solverElf.aiNum(ai: solverElf.currentAI)
        let previouslySelectedRowIndexPath = NSIndexPath(forRow: aiNumberInt - 1, inSection: 0)
        let tableViewCell = tableView.cellForRowAtIndexPath(previouslySelectedRowIndexPath)
        tableViewCell.accessoryType = UITableViewCellAccessoryType.None
        // Show checkmark on the selected cell.
        let selectedTableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        selectedTableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
        // Set current AI.
        let newAINum = indexPath.row + 1
        solverElf.currentAI = solverElf.ai(num: newAINum)
        delegate?.aiTableViewControllerDidSelectAI()
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return solverElf.numAIs
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        solverElf = appDelegate.solverElf
    }
}
