//
//  RVVideoElement.h
//  External Display Test
//
//  Created by Daniel Owen on 12/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVVideoElement : NSObject
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSNumber *audioVolume;
@property (nonatomic, strong) NSString *playbackBehavior;  // "0"=stop, "1"=loop , "3"=next, "4"=soft loop (next is only used for image/video bin playlists) - For simplePresenter, lets just do 0,3=stop and 1,4=loop)
@property (nonatomic, strong, readonly) NSImage *thumbNailImage;
@end
