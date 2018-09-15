//
//  RVSlideGrouping.m
//  External Display Test
//
//  Created by Daniel Owen on 9/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import "RVSlideGrouping.h"

@implementation RVSlideGrouping

- (NSMutableArray *) slides {
    if (!_slides)
        _slides = [[NSMutableArray alloc] init];
    return _slides;
}

@end
