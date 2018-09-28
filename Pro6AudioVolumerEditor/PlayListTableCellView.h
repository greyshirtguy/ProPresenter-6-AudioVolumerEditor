//
//  PlayListTableCellView.h
//  Pro6AudioVolumeEditor
//
//  Created by Dan on 28/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RVAudioElement.h"

@protocol PlayListTableCellViewDelegate <NSObject>
@optional
- (void)userChangedVolumeOfPlayListAudioElement:(RVAudioElement *)rvAudioElement toVolume:(float)volume;
@end

@interface PlayListTableCellView : NSTableCellView
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) id <PlayListTableCellViewDelegate> playListTableCellViewDelegate;

// argh.....probabably should not have these direct links to model - but it makes for very low overhead (high performance) to get from view of selected slide back to matching objects in the model - avoiding overhead of searching via indexPath
@property (weak) RVAudioElement *rvAudioElement;
@end
