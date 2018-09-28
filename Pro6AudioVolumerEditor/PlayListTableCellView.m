//
//  PlayListTableCellView.m
//  Pro6AudioVolumeEditor
//
//  Created by Dan on 28/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import "PlayListTableCellView.h"

@implementation PlayListTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (IBAction)playlistItemVolumeSliderChanged:(NSSlider *)sender {
    // Update model
    self.rvAudioElement.volume = sender.stringValue;
    
    // Let viewcontroller know volume was changed
    if (self.playListTableCellViewDelegate)
        [self.playListTableCellViewDelegate userChangedVolumeOfPlayListAudioElement:self.rvAudioElement toVolume:sender.floatValue];
}

@end
