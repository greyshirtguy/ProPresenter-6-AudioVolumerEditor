//
//  ViewController.m
//  Pro6AudioVolumerEditor
//
//  Created by Dan on 11/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import "ViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "RVSlideViewItem.h"
#import "RVPresentationDocument.h"
#import "RVMediaCue.h"
#import "RVAudioCue.h"
#import "RVVideoElement.h"
#import "RVPlaylistNode.h"

@interface ViewController ()
@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;
@property (nonatomic, weak) RVAudioElement *currentPlayingAudioElement;
@property (nonatomic, weak) RVVideoElement *currentPlayingVideoElement;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) NSSound *soundToPlay;
@property (strong, nonatomic) NSArray *libraryFiles;
@property (strong, nonatomic) RVPresentationDocument *rvPresentationDocument;
@property (strong, nonatomic) RVPlaylistNode *audioRVPlayListNode;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.renewedvision.ProPresenter6"].count > 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"ProPresenter 6 is running!\n\nPlease Quit ProPrensenter 6\nbefore using this editor.";
        alert.icon = [NSImage imageNamed:@"sdf"];
        [alert runModal];
        [NSApp terminate:self];
    }
    
    
    
    NSNib *rvslideviewnib = [[NSNib alloc] initWithNibNamed:@"RVSlideViewItem" bundle:nil];
    [self.slidesCollectionView registerNib:rvslideviewnib forItemWithIdentifier:@"RVSlideViewItem"];
    self.slidesCollectionView.delegate = self;
    self.slidesCollectionView.dataSource = self;
    
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    NSString *homeDir = NSHomeDirectory();
    //TODO: make this robust!!! stop using assumed paths (look it up in Pro6 Prefs)
    self.libraryFiles = [fileManger contentsOfDirectoryAtPath:[homeDir stringByAppendingString:@"/Documents/ProPresenter6"] error:nil];
    NSArray *extensions = [NSArray arrayWithObjects:@"pro6", nil];
    self.libraryFiles = [self.libraryFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(pathExtension IN %@)", extensions]];
    self.libraryFiles = [self.libraryFiles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSLog(@"%lu files in library",(unsigned long)self.libraryFiles.count);
    
    self.libraryTableView.delegate = self;
    self.libraryTableView.dataSource = self;
    
    
    if (!self.audioRVPlayListNode)
        self.audioRVPlayListNode = [[RVPlaylistNode alloc] init];
    
    NSString *audioPlaylistFilePath = [@"~/Library/Application Support/RenewedVision/ProPresenter6/Audio.pro6pl" stringByExpandingTildeInPath];
    [self.audioRVPlayListNode loadAudioPlaylistNodesFromFile:audioPlaylistFilePath];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)button_clicked:(NSButton *)sender {
    NSError *error;
    NSString *homeDir = NSHomeDirectory();
    NSString *pro6DocsDir = [homeDir stringByAppendingPathComponent:@"Documents/ProPresenter6"];
    NSString *docPathName = [pro6DocsDir stringByAppendingPathComponent:self.libraryFiles[self.libraryTableView.selectedRow]];
    NSURL *fileURL = [NSURL fileURLWithPath:docPathName];
    NSXMLDocument *rvPresentationDoc = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL options:NSXMLDocumentTidyXML error:&error];
    NSXMLElement *root = [rvPresentationDoc rootElement];
    
    // Go right through model (which may be updated with new volumes) and update xml file with volumes
    for (RVSlideGrouping * group in self.rvPresentationDocument.groups) {
        for (RVDisplaySlide * slide in group.slides) {
            for (NSObject *cue in slide.cues) {
                if ([cue isKindOfClass:[RVMediaCue class]])
                {
                    //Get rvMediaCue from model (might be updated)
                    RVMediaCue *rvMediaCue = (RVMediaCue *)cue;
                    
                    if (rvMediaCue.rvImageElement) {

                    }
                    if (rvMediaCue.rvVideoElement) {
                        // Get matching XMlElement
                        NSArray *videoCueElements = [root nodesForXPath:[NSString stringWithFormat:@"//RVMediaCue[@UUID='%@']",rvMediaCue.UUID] error:nil];
                        NSXMLNode *videoCueNode = [videoCueElements lastObject];
                        if ([videoCueNode kind] == NSXMLElementKind) {
                            NSXMLElement *videoCueElement = (NSXMLElement *)videoCueNode;
                            NSXMLElement *videoElement = [[videoCueElement elementsForName:@"RVVideoElement"] objectAtIndex:0];
                            NSLog(@"%@",videoElement);
                            NSLog(@"%@",rvMediaCue.rvVideoElement.audioVolume);
                            [videoElement addAttribute:[NSXMLNode attributeWithName:@"audioVolume" stringValue:[rvMediaCue.rvVideoElement.audioVolume stringValue]]];
                            NSLog(@"%@",videoElement);
                        }
                    }
                }
                
                if ([cue isKindOfClass:[RVAudioCue class]]) {
                    // Get rvAudioCue from model (might be updated)
                    RVAudioCue *rvAudioCue = (RVAudioCue *)cue;
                    
                    // Get matching XMlElement
                    NSArray *audioCueElements = [root nodesForXPath:[NSString stringWithFormat:@"//RVAudioCue[@UUID='%@']",rvAudioCue.UUID] error:nil];
                    NSXMLNode *audioCueNode = [audioCueElements lastObject];
                    if ([audioCueNode kind] == NSXMLElementKind) {
                        NSXMLElement *audioCueElement = (NSXMLElement *)audioCueNode;
                        NSXMLElement *audioElement = [[audioCueElement elementsForName:@"RVAudioElement"] objectAtIndex:0];
                        NSLog(@"%@",audioElement);
                        NSLog(@"%@",rvAudioCue.rvAudioElement.volume);
                        [audioElement addAttribute:[NSXMLNode attributeWithName:@"volume" stringValue:rvAudioCue.rvAudioElement.volume]];
                        NSLog(@"%@",audioElement);
                    }
                }
            }
        }
        
        NSData *data = [rvPresentationDoc XMLData];
        [data writeToURL:fileURL atomically:YES];
        self.saveButton.enabled = NO;
    }

    
    
    
}

-(void)userChangedVolumeOfVideoElement:(RVVideoElement *)rvVideoElement toVolume:(float)volume {
    NSLog(@"VC knows video volume was changed");
    self.avPlayer.volume = volume;
    self.saveButton.enabled = YES;
}

-(void)userChangedVolumeOfAudioElement:(RVAudioElement *)rvAudioElement toVolume:(float)volume {
    NSLog(@"VC knows audio volume was changed");
    self.saveButton.enabled = YES;
    if (self.soundToPlay && self.currentPlayingAudioElement == rvAudioElement)
        self.soundToPlay.volume = volume;
}

- (nonnull NSCollectionViewItem *)collectionView:(nonnull NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RVSlideViewItem *rvSlideViewItem = [self.slidesCollectionView makeItemWithIdentifier:@"RVSlideViewItem" forIndexPath:indexPath];
    // setup slideviewitem here
    rvSlideViewItem.VolumeSlider.hidden = YES;
    rvSlideViewItem.rvSlideViewItemDelegate = self;
    rvSlideViewItem.cueLabel.stringValue = @"";
    rvSlideViewItem.rvAudioElement = nil;
    rvSlideViewItem.rvVideoElement = nil;
    rvSlideViewItem.slideImageView.image = nil;
    
    //NSLog(@"dishing up CV item");
    
    // Find RVSlide in model and setup Cell using it's data...
    NSInteger slideNumber = 0;
    for (RVSlideGrouping * group in self.rvPresentationDocument.groups) {
        for (RVDisplaySlide * slide in group.slides) {
            if (slideNumber == indexPath.item) {
                [rvSlideViewItem.SlideTextField setStringValue:slide.text];
 
                if (slide == group.slides.firstObject)
                    rvSlideViewItem.SlideLabel.stringValue = group.name;
                else
                    rvSlideViewItem.SlideLabel.stringValue = @"";
     
                rvSlideViewItem.BackgroundBox.fillColor = group.color;
                
                if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame)
                    rvSlideViewItem.BackgroundBox.borderColor = [NSColor orangeColor];
                else
                    rvSlideViewItem.BackgroundBox.borderColor = [group.color blendedColorWithFraction:0.6 ofColor:[NSColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
                
                for (NSObject *cue in slide.cues) {
                    if ([cue isKindOfClass:[RVMediaCue class]])
                    {
                        RVMediaCue *rvMediaCue = (RVMediaCue *)cue;
                        if (rvMediaCue.rvImageElement)
                        {
                            rvSlideViewItem.cueLabel.stringValue = [rvSlideViewItem.cueLabel.stringValue stringByAppendingString:@"🏞"];
                            rvSlideViewItem.slideImageView.image = rvMediaCue.rvImageElement.image;
                            rvSlideViewItem.slideImageView.imageScaling = NSImageScaleAxesIndependently;  //TODO: apply correct scaling based on file
                            //if (rvMediaCue.rvImageElement.image)
                            //    slideThumbCVCell.bgImage.image = rvMediaCue.rvImageElement.image;
                        }
                        if (rvMediaCue.rvVideoElement) {
                            rvSlideViewItem.cueLabel.stringValue = [rvSlideViewItem.cueLabel.stringValue stringByAppendingString:@"🎬"];
                            rvSlideViewItem.slideImageView.image = rvMediaCue.rvVideoElement.thumbNailImage;
                            rvSlideViewItem.slideImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
                            // Only enable video control is audio not already set.
                            if (!rvSlideViewItem.rvAudioElement)
                            {
                                rvSlideViewItem.VolumeSlider.hidden = NO;
                                rvSlideViewItem.VolumeSlider.floatValue = [rvMediaCue.rvVideoElement.audioVolume floatValue];
                                rvSlideViewItem.rvVideoElement = rvMediaCue.rvVideoElement;
                            }
                        }
                    }
                    
                    if ([cue isKindOfClass:[RVAudioCue class]])
                    {
                        RVAudioCue *rvAudioCue = (RVAudioCue *)cue;
                        
                        // if there is an audio element - lets setup to play it....
                        if (rvAudioCue.rvAudioElement)
                        {
                            rvSlideViewItem.cueLabel.stringValue = [rvSlideViewItem.cueLabel.stringValue stringByAppendingString:@"🔈"];
                            rvSlideViewItem.VolumeSlider.hidden = NO;
                            rvSlideViewItem.VolumeSlider.floatValue = [rvAudioCue.rvAudioElement.volume floatValue];
                            rvSlideViewItem.rvAudioElement = rvAudioCue.rvAudioElement;
                            
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
    if (self.rvPresentationDocument.groups) {
        slideCount = 0;
        for (RVSlideGrouping *group in self.rvPresentationDocument.groups) {
            slideCount += group.slides.count;
        }
    }
    
    return slideCount;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}


- (void)collectionView:(NSCollectionView *)collectionView
didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;
{
    // Get selected RVSlideViewItem
    NSIndexPath *selectedIndexPath = [indexPaths allObjects].lastObject;
    RVSlideViewItem *selectedSlideItem = (RVSlideViewItem *)[collectionView itemAtIndexPath:selectedIndexPath];
    NSLog(@"Selected Slide %ld with %@",(long)selectedIndexPath.item, selectedSlideItem);
    NSLog(@"%ld slides selected",(long)indexPaths.count);
    
    // Create short list of current and previous selected slides (to limit the reload/update of collectionview)
    NSMutableArray *currentAndPreviousSelectedItem;
    if ([selectedIndexPath isEqual:self.selectedItemIndexPath] || self.selectedItemIndexPath == nil)
        currentAndPreviousSelectedItem = [NSMutableArray arrayWithObjects:selectedIndexPath,nil];
    else
    {
        currentAndPreviousSelectedItem = [NSMutableArray arrayWithObjects:selectedIndexPath, self.selectedItemIndexPath,nil];
    }
    self.selectedItemIndexPath = selectedIndexPath;
    
    NSLog(@"%@",currentAndPreviousSelectedItem);
    
    //  Check for audio or video cues and play
    if (selectedSlideItem.rvAudioElement) {
        NSLog(@"Found Audio");
        // Stop any already playing Audio
        if (self.currentPlayingAudioElement)
        {
            self.currentPlayingAudioElement = nil;
            [self.soundToPlay stop];
        }
        
        // STop any video playing
        if (self.currentPlayingVideoElement)
        {
            [self.avPlayer pause];
            self.currentPlayingVideoElement = nil;
        }
        
        // Play Audio
        NSURL *fileURL = [[NSURL alloc] initWithString:selectedSlideItem.rvAudioElement.source];
        if(self.soundToPlay)
        {
            self.soundToPlay = nil;
        }
        self.soundToPlay = [[NSSound alloc] initWithContentsOfURL:fileURL byReference:NO];
        self.soundToPlay.volume = [selectedSlideItem.rvAudioElement.volume floatValue];
        self.soundToPlay.loops = YES;
        self.currentPlayingAudioElement = selectedSlideItem.rvAudioElement;
        [self.soundToPlay play];
        
    } else if (selectedSlideItem.rvVideoElement) {
        NSLog(@"Found Video");
        // Stop any already playing Audio
        [self.soundToPlay stop];
        if (self.currentPlayingAudioElement)
            self.currentPlayingAudioElement = nil;
        
        // STop any video playing
        [self.avPlayer pause];
        if (self.currentPlayingVideoElement)
            self.currentPlayingVideoElement = nil;
        
        
        // Play Video
        self.avPlayer = nil;
        //TODO: watch out when working with files that might not exist!!! make this more robust
        NSURL *fileURL = [[NSURL alloc] initWithString:selectedSlideItem.rvVideoElement.source];
        self.avPlayer = [AVPlayer playerWithURL:fileURL];
        self.avPlayer.volume = [selectedSlideItem.rvVideoElement.audioVolume floatValue];
        self.currentPlayingVideoElement = selectedSlideItem.rvVideoElement;
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self.avPlayer play];
        
    } else {
        NSLog(@"Found No AV");
        //Stop any audio or video playing...
        self.currentPlayingAudioElement = nil;
        [self.soundToPlay stop];
        
        self.currentPlayingVideoElement = nil;
        [self.avPlayer pause];
    }
    
    
    /*
    // I dont like this any more
    // Find RVSlide in model and get detils to play sound at selected volume....
    NSInteger slideNumber = 0;
    for (RVSlideGrouping * group in self.rvPresentationDocument.groups) {
        for (RVDisplaySlide * slide in group.slides) {
            if (slideNumber == selectedSlide) {
                BOOL audioCueFound = NO;
                for (NSObject *cue in slide.cues)
                    if ([cue isKindOfClass:[RVAudioCue class]])
                    {
                        audioCueFound = YES;
                        RVAudioCue *rvAudioCue = (RVAudioCue *)cue;
                        
                        // if there is an audio element then lets play os
                        if (rvAudioCue.rvAudioElement)
                        {
                            // Let's play the audio track at volume currently set on the slider!!!
                            NSLog(@"Slide: %li, Volume: %@ - Source: %@",(long)slideNumber, rvAudioCue.rvAudioElement.volume, rvAudioCue.rvAudioElement.source);
                            
                            if (self.soundToPlay)
                            {
                                self.currentPlayingAudioElement = nil;
                                [self.soundToPlay stop];
                            }
                            NSURL *fileURL = [[NSURL alloc] initWithString:rvAudioCue.rvAudioElement.source];
                            self.soundToPlay = [[NSSound alloc] initWithContentsOfURL:fileURL byReference:NO];
                            self.soundToPlay.volume = [rvAudioCue.rvAudioElement.volume floatValue];
                            self.currentPlayingAudioElement = rvAudioCue.rvAudioElement;
                            [self.soundToPlay play];
                        
                            
                        }
                    }
                    if (!audioCueFound && self.soundToPlay)
                    {
                        self.currentPlayingAudioElement = nil;
                        [self.soundToPlay stop];
                    }
                }
               slideNumber++;
            }
        
        }
    */
    [collectionView reloadItemsAtIndexPaths:[NSSet setWithArray:currentAndPreviousSelectedItem]];

}

/*
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[NSTableRowView alloc] init];
} */


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *libDocTableViewCell = [tableView makeViewWithIdentifier:@"LibraryDocTableViewCell" owner:self];
    libDocTableViewCell.textField.stringValue = self.libraryFiles[row];
    return libDocTableViewCell;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.libraryFiles) {
        return self.libraryFiles.count;
    } else {
        return 0;
    }
  
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSLog(@"%ld",(long)self.libraryTableView.selectedRow);
    self.saveButton.enabled = NO;
    NSString *homeDir = NSHomeDirectory();
    NSString *pro6DocsDir = [homeDir stringByAppendingPathComponent:@"Documents/ProPresenter6"];
    NSString *docPathName = [pro6DocsDir stringByAppendingPathComponent:self.libraryFiles[self.libraryTableView.selectedRow]];
    self.rvPresentationDocument = [[RVPresentationDocument alloc] init];
    [self.rvPresentationDocument loadFromFile:docPathName];
    self.selectedItemIndexPath = nil;  // protect against crash!
    [self.slidesCollectionView reloadData];
    
    self.currentPlayingAudioElement = nil;
    [self.soundToPlay stop];
    self.currentPlayingVideoElement = nil;
    [self.avPlayer  pause];
}
@end
