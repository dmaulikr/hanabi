//
//  MainMenuViewController.swift
//  Hanabi
//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    var viewControllerElf: ViewControllerElf!
    // User interacts with UI. She hears a sound to (subconsciously) know she did something.
    @IBAction func playButtonDownSound() {
        viewControllerElf.playButtonDownSound()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerElf = ViewControllerElf()
        let versionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as String
        versionLabel.text = "Version \(versionString)"
    }
}
