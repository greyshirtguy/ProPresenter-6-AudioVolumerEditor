//
//  ViewController.h
//  Pro6AudioVolumerEditor
//
//  Created by Dan on 11/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Appkit/Appkit.h>

@interface ViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>
@property (weak) IBOutlet NSCollectionView *slidesCollectionView;


@end

