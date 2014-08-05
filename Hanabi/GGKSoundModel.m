//
//  Created by Geoff Hom on 2/20/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKSoundModel.h"

#import <AVFoundation/AVFoundation.h>

@implementation GGKSoundModel
- (id)init {
    self = [super init];
    if (self) {
        self.soundIsOn = YES;
        NSString *soundFilePath;
        NSURL *soundFileURL;
        AVAudioPlayer *anAudioPlayer;
        // Ding sound.
//        soundFilePath = [ [NSBundle mainBundle] pathForResource:@"scoreIncrease" ofType:@"aiff" ];
//        soundFileURL = [NSURL fileURLWithPath:soundFilePath];
//        anAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
//        self.dingAudioPlayer = anAudioPlayer;
        // Button-down sound.
        soundFilePath = [ [NSBundle mainBundle] pathForResource:@"tap" ofType:@"aif" ];
        soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        anAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        self.buttonDownAudioPlayer = anAudioPlayer;
        // The button-down sound will be needed first.
        [self prepareButtonDownSound];
    }
    return self;
}
- (void)playButtonDownSound {
    if (self.soundIsOn) {
        [self.buttonDownAudioPlayer play];
    }
}
- (void)playDingSound {
    if (self.soundIsOn) {
        [self.dingAudioPlayer play];
    }
}
- (void)prepareButtonDownSound {
    [self.buttonDownAudioPlayer prepareToPlay];
}
@end
