//
//  RVAudioCue.h
//  Pro6AudioVolumerEditor
//
//  Created by Dan on 12/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVAudioElement.h"

@interface RVAudioCue : NSObject
@property (strong, nonatomic) RVAudioElement *rvAudioElement;
@property (strong, nonatomic) NSString *UUID;
@property (strong, nonatomic) NSString *displayName;
@end
