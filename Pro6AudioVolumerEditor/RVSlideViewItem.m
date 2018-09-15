//
//  RVSlideViewItem.m
//  Pro6AudioVolumerEditor
//
//  Created by Dan on 12/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import "RVSlideViewItem.h"

@interface RVSlideViewItem ()

@end

@implementation RVSlideViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)volumeChanged:(NSSlider *)sender {
    NSLog(@"volume changed");
    if (self.rvAudioElement)
    {
        // Update model
        self.rvAudioElement.volume = sender.stringValue;
        
        // Let viewcontroller know volume was changed
        if (self.rvSlideViewItemDelegate)
            [self.rvSlideViewItemDelegate userChangedVolumeOfAudioElement:self.rvAudioElement toVolume:sender.floatValue];
    }
    
    if (self.rvVideoElement)
    {
        // Update model
        self.rvVideoElement.audioVolume = [NSNumber numberWithFloat:sender.floatValue];
        
        // let viewcontroller know volume was changed
        if (self.rvSlideViewItemDelegate)
            [self.rvSlideViewItemDelegate userChangedVolumeOfVideoElement:self.rvVideoElement toVolume:sender.floatValue];
    }
}

@end
