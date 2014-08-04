//
//  SolveGamesViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class SolveGamesViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var numberOfGamesTextField: UITextField!
    var soundModel: GGKSoundModel!
    @IBOutlet weak var startButton: UIButton!
    // Stop calculating.
    @IBAction func handleCancelButtonTapped() {
        println("SGVC handleCancelButtonTapped")
    }
    // Play/solve the requested number of games.
    @IBAction func handleStartButtonTapped() {
        println("SGVC handleStartButtonTapped")
    }
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonSound() {
        soundModel.playButtonTapSound()
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
        self.soundModel = (UIApplication.sharedApplication().delegate as AppDelegate).soundModel
        
        // this might be under updateUI and depend on mode
        self.cancelButton.enabled = false
        
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.cancelButton)
        GGKUtilities.addBorderOfColor(UIColor.blackColor(), toView: self.startButton)
        
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
