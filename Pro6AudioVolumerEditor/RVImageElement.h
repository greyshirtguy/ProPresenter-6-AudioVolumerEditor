//
//  RVImageElement.h
//  External Display Test
//
//  Created by Daniel Owen on 12/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVImageElement : NSObject
@property (nonatomic, strong) NSString *source;
@property (readonly, nonatomic, strong) NSImage *image;
// TODO: add previewImage for performace?
@end
