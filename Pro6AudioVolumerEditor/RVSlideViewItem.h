//
//  RVSlideViewItem.h
//  Pro6AudioVolumerEditor
//
//  Created by Dan on 12/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RVAudioElement.h"
#import "RVVideoElement.h"
//#import "RVDisplaySlide.h"

@protocol RVSlideViewItemDelegate <NSObject>
@optional
- (void)userChangedVolumeOfAudioElement:(RVAudioElement *)rvAudioElement toVolume:(float)volume;
- (void)userChangedVolumeOfVideoElement:(RVVideoElement *)rvVideoElement toVolume:(float)volume;
@end


@interface RVSlideViewItem : NSCollectionViewItem
@property (weak) IBOutlet NSTextField *SlideTextField;
@property (weak) IBOutlet NSSlider *VolumeSlider;
@property (weak) IBOutlet NSBox *BackgroundBox;
@property (weak) IBOutlet NSTextField *SlideLabel;
@property (weak) IBOutlet NSTextField *cueLabel;
@property (weak) IBOutlet NSImageView *slideImageView;

@property (weak) id <RVSlideViewItemDelegate> rvSlideViewItemDelegate;

// argh.....probabably should not have these direct links to model - but it makes for very low overhead (high performance) to get from view of selected slide back to matching objects in the model - avoiding overhead of searching via indexPath
@property (weak) RVAudioElement *rvAudioElement;
@property (weak) RVVideoElement *rvVideoElement;
//@property (weak) RVDisplaySlide *rvDisplaySlide;
@end
