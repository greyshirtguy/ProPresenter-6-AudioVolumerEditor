//
//  ViewController.m
//  Pro6AudioVolumerEditor
//
//  Created by Dan on 11/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import "ViewController.h"
#import "RVSlideViewItem.h"
#import "RVPresentationDocument.h"
#import "RVMediaCue.h"
#import "RVAudioCue.h"

@implementation ViewController
RVPresentationDocument *rvPresentationDocument;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSNib *rvslideviewnib = [[NSNib alloc] initWithNibNamed:@"RVSlideViewItem" bundle:nil];
    [self.slidesCollectionView registerNib:rvslideviewnib forItemWithIdentifier:@"RVSlideViewItem"];
    self.slidesCollectionView.delegate = self;
    self.slidesCollectionView.dataSource = self;
    
    // Lets test loading a document...
    rvPresentationDocument = [[RVPresentationDocument alloc] init];
    [rvPresentationDocument loadFromFile:@"/Users/dan/Documents/ProPresenter6/Heart Of God.pro6"];
    //NSLog(rvPresentationDocument.groups.lastObject);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)button_clicked:(NSButton *)sender {

    

}


- (nonnull NSCollectionViewItem *)collectionView:(nonnull NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RVSlideViewItem *rvSlideViewItem = [self.slidesCollectionView makeItemWithIdentifier:@"RVSlideViewItem" forIndexPath:indexPath];
    // setup slideviewitem here
    rvSlideViewItem.VolumeSlider.hidden = YES;
    
    // Find RVSlide in model and setup Cell using it's data...
    NSInteger slideNumber = 0;
    for (RVSlideGrouping * group in rvPresentationDocument.groups) {
        for (RVDisplaySlide * slide in group.slides) {
            if (slideNumber == indexPath.item) {
                [rvSlideViewItem.SlideTextField setStringValue:slide.text];
 
                if (slide == group.slides.firstObject)
                    rvSlideViewItem.SlideLabel.stringValue = group.name;
                else
                    rvSlideViewItem.SlideLabel.stringValue = @"";
     
                rvSlideViewItem.BackgroundBox.fillColor = group.color;
                rvSlideViewItem.BackgroundBox.borderColor = [group.color blendedColorWithFraction:0.6 ofColor:[NSColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
                
                for (NSObject *cue in slide.cues) {
                    if ([cue isKindOfClass:[RVMediaCue class]])
                    {
                        RVMediaCue *rvMediaCue = (RVMediaCue *)cue;
                        if (rvMediaCue.rvImageElement)
                        {
                            rvSlideViewItem.SlideLabel.stringValue = [rvSlideViewItem.SlideLabel.stringValue stringByAppendingString:@" [I]"];
                            //if (rvMediaCue.rvImageElement.image)
                            //    slideThumbCVCell.bgImage.image = rvMediaCue.rvImageElement.image;
                        }
                        if (rvMediaCue.rvVideoElement) {
                            rvSlideViewItem.SlideLabel.stringValue = [rvSlideViewItem.SlideLabel.stringValue stringByAppendingString:@" [V]"];
                            //slideThumbCVCell.videoPath = rvMediaCue.rvVideoElement.localSource;
                            //if (rvMediaCue.rvVideoElement.thumbNailImage)
                            //    slideThumbCVCell.bgImage.image = cue.rvVideoElement.thumbNailImage;
                        }
                    }
                    
                    if ([cue isKindOfClass:[RVAudioCue class]])
                    {
                        RVAudioCue *rvAudioCue = (RVAudioCue *)cue;
                        
                        // if there is an audio element - lets show the volume control!
                        if (rvAudioCue.rvAudioElement)
                        {
                            rvSlideViewItem.VolumeSlider.hidden = NO;
                            rvSlideViewItem.VolumeSlider.floatValue = [rvAudioCue.rvAudioElement.volume floatValue];
                        }
                    }
                }
                
            }
            slideNumber++;
        }
        
    }


    
    return rvSlideViewItem;
}

- (NSInteger)collectionView:(nonnull NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger slideCount = 1;
    if (rvPresentationDocument.groups) {
        slideCount = 0;
        for (RVSlideGrouping *group in rvPresentationDocument.groups) {
            slideCount += group.slides.count;
        }
    }
    
    return slideCount;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}

@end
