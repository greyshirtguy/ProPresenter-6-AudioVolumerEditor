//
//  RVImageElement.m
//  External Display Test
//
//  Created by Daniel Owen on 12/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import "RVImageElement.h"
#import <AppKit/AppKit.h>

@implementation RVImageElement
-(void)setSource:(NSString *)source {
    _source = source;
    // Attempt to load image from file pointed to by source into _image
    NSURL *fileURL = [[NSURL alloc] initWithString:_source];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]])
        _image = [[NSImage alloc] initWithContentsOfFile:[fileURL path]];
    
}
@end
