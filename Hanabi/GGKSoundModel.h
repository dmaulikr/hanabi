//
//  Created by Geoff Hom on 2/20/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioPlayer;

@interface GGKSoundModel : NSObject
// For playing a UI sound when the player presses a button.
@property (nonatomic, strong) AVAudioPlayer *buttonDownAudioPlayer;
// For playing a UI sound to get the user's attention, in a positive way.
@property (nonatomic, strong) AVAudioPlayer *dingAudioPlayer;
// Whether this app's sound should play or not.
@property (assign, nonatomic) BOOL soundIsOn;
// Create the audio player for each sound.
- (id)init;
// Play sound appropriate for a button press.
- (void)playButtonDownSound;
// Play sound appropriate for positive attention.
- (void)playDingSound;
// Prepare the appropriate audio player to play.
- (void)prepareButtonDownSound;
@end
