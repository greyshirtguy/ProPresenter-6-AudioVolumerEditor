//
//  RVDisplaySlide.m
//  External Display Test
//
//  Created by Daniel Owen on 9/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import "RVDisplaySlide.h"

@implementation RVDisplaySlide
- (NSMutableArray *) cues {
    if (!_cues)
        _cues = [[NSMutableArray alloc] init];
    return _cues;
}

@end
