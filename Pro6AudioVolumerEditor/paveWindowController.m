//
//  paveWindowController.m
//  Pro6AudioVolumeEditor
//
//  Created by Dan on 15/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import "paveWindowController.h"

@interface paveWindowController ()

@end

@implementation paveWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setTitle:[NSString stringWithFormat:@"Pro6 Audio Volume Editor (Version: %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
}

@end
