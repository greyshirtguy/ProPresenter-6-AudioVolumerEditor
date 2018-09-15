//
//  RVVideoElement.m
//  External Display Test
//
//  Created by Daniel Owen on 12/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import "RVVideoElement.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AppKit/AppKit.h>

@implementation RVVideoElement
-(void)setSource:(NSString *)source {
    
    _source = source;
    
    // Attempt to load image from file pointed to by source into _image
    NSString *filePath = [[[NSURL alloc] initWithString:_source] path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // TODO: error check each step!!!
        NSURL *videoURL = [NSURL fileURLWithPath:filePath];
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = nil;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:nil error:&err];
        _thumbNailImage = [[NSImage alloc] initWithCGImage:oneRef size:NSZeroSize];
    } 
}
@end
