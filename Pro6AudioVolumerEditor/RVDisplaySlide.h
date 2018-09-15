//
//  RVDisplaySlide.h
//  External Display Test
//
//  Created by Daniel Owen on 9/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface RVDisplaySlide : NSObject
@property (nonatomic, strong) NSMutableString *text;  // NSMutableArray *RVDisplayElements;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSColor *highlightColor;
@property (nonatomic, strong) NSMutableArray *cues;
@end
