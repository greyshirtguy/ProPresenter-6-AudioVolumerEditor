//
//  PlayListTableCellView.h
//  Pro6AudioVolumeEditor
//
//  Created by Dan on 28/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PlayListTableCellView : NSTableCellView
@property (weak) IBOutlet NSSlider *volumeSlider;

@end
