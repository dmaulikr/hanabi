//
//  SolveGamesViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class SolveGamesViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var numberOfGamesTextField: UITextField!
    @IBAction func handleCancelButtonTapped() {
        
    }
    @IBAction func handleStartButtonTapped() {
        println("SGVC handleStartButtonTapped")
    }
    func textFieldDidEndEditing(theTextField: UITextField!) {
        // Ensure we have a valid value. Update model. Update view.
        println("SGVC textFieldDidEndEditing")
    }
    func textFieldShouldReturn(theTextField: UITextField!) -> Bool {
        theTextField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.startButton)
        // this might be under updateUI and depend on mode
        self.cancelButton.enabled = false
    }
    
//    - (void)textFieldDidEndEditing:(UITextField *)theTextField {
//    // Ensure we have a valid value. Update model. Update view.
//    NSInteger anOkayInteger;
//    NSInteger theCurrentInteger = [theTextField.text integerValue];
//    if (theTextField == self.numberOfSecondsToWaitTextField) {
//    anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:99];
//    self.delayedPhotosModel.numberOfSecondsToWaitInteger = anOkayInteger;
//    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
//    anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:1 maximum:99];
//    self.delayedPhotosModel.numberOfPhotosToTakeInteger = anOkayInteger;
//    }
//    [self updateUI];
//    }
}
