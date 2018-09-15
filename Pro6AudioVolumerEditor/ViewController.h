//
//  ViewController.h
//  Pro6AudioVolumerEditor
//
//  Created by Dan on 11/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Appkit/Appkit.h>
#import "RVSlideViewItem.h"

@interface ViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource, NSTableViewDelegate, NSTableViewDataSource, RVSlideViewItemDelegate>
@property (weak) IBOutlet NSCollectionView *slidesCollectionView;
@property (weak) IBOutlet NSTableView *libraryTableView;
@property (weak) IBOutlet NSButtonCell *saveButton;

@end

