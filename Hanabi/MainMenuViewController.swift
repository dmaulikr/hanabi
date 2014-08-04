//
//  MainMenuViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    var soundModel: GGKSoundModel!
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonSound() {
        soundModel.playButtonTapSound()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.soundModel = (UIApplication.sharedApplication().delegate as AppDelegate).soundModel
    }
}
