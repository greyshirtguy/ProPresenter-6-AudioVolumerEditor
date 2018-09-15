//
//  RVMediaCue.h
//  External Display Test
//
//  Created by Daniel Owen on 12/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RVImageElement.h"
#import "RVVideoElement.h"

@interface RVMediaCue : NSObject
@property (strong, nonatomic) RVImageElement *rvImageElement;
@property (strong, nonatomic) RVVideoElement *rvVideoElement;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *UUID;
@end
