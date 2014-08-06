//
//  Created by Geoff Hom on 8/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//
// Provides UIViewController-subclass functionality without requiring inheritance.

import UIKit

//@objc protocol ViewControllerHelperDelegate {
//    optional func viewControllerHelperViewWillAppearToUser()
//}

class ViewControllerElf: NSObject {
//    var delegate: ViewControllerHelperDelegate? = nil
    var soundModel: GGKSoundModel!
    override init() {
        super.init()
        self.soundModel = (UIApplication.sharedApplication().delegate as AppDelegate).soundModel
        // still figuring out how to add notification properly; may need [weak self]
//        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil, usingBlock: { [unowned self] (note: NSNotification!) in
//            self.handleAppWillEnterForeground()
//            })
    }
//    func handleAppWillEnterForeground() {
////        self.delegate? // try to cast as VC, then see if it's on top of stack
    // if so, then notify delegate
    // rename helper as elf?
//    self.delegate?.viewControllerHelperViewWillAppearToUser?()
//    }
    
    // The view will appear to the user, so ensure it's up to date.
    // A view appears in two ways: 1) the app makes the view appear/disappear and 2) the app enters the foreground (from the home screen, another app or screen lock). -viewWillAppear: is called for 1). UIApplicationWillEnterForegroundNotification is sent for 2). To have a consistent UI, both will call this method. Subclasses should call super and override.
    // The foreground notification can be received independent of a VC's visibility (i.e., position in the nav stack). To prevent this, we'll add the observer in -viewWillAppear: and remove it in -viewWillDisappear:.
    
    // what if we add the observer on init and remove on dealloc? then test if the view/delegate is visible?
    // it should instead call handleAppWillEnterForeground which should test and then maybe call handleViewWillAppear
    
    
    func playButtonDownSound() {
        self.soundModel.playButtonDownSound()
    }
}
