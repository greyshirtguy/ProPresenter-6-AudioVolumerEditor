//
//  RVPresentationDocument.h
//  External Display Test
//
//  Created by Daniel Owen on 9/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVSlideGrouping.h"
#import "RVDisplaySlide.h"

@interface RVPresentationDocument : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *arrangements;
@property (nonatomic, strong) NSString *selectedArrangementID;
@property (nonatomic) double transitionDuration;
-(void)loadFromFile:(NSString *)filePath;
@end
