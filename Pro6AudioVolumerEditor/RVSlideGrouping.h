//
//  RVSlideGrouping.h
//  External Display Test
//
//  Created by Daniel Owen on 9/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Appkit/Appkit.h>

@interface RVSlideGrouping : NSObject
@property (nonatomic, strong) NSMutableArray *slides;
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@end
