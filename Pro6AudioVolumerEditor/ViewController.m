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
#import "PlayListTableCellView.h"

@interface ViewController ()
@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;
@property (nonatomic, weak) RVAudioElement *currentPlayingAudioElement;
@property (nonatomic, weak) RVVideoElement *currentPlayingVideoElement;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) NSSound *soundToPlay;
@property (strong, nonatomic) NSArray *libraryFiles;
@property (strong, nonatomic) RVPresentationDocument *rvPresentationDocument;
@property (strong, nonatomic) RVPlaylistNode *audioRVPlayListsRootNode;
@property (weak, nonatomic) RVPlaylistNode *currentSelectedRVPlaylistNode;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // check for Pro6 running - Warn user and quit if found...
    if ([NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.renewedvision.ProPresenter6"].count > 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"ProPresenter 6 is running!\n\nPlease Quit ProPrensenter 6\nbefore using this editor.";
        alert.icon = [NSImage imageNamed:@"sdf"];
        [alert runModal];
        [NSApp terminate:self];
    }
    
    // Prepare CollectionView custom cell view.
    NSNib *rvslideviewnib = [[NSNib alloc] initWithNibNamed:@"RVSlideViewItem" bundle:nil];
    [self.slidesCollectionView registerNib:rvslideviewnib forItemWithIdentifier:@"RVSlideViewItem"];
    
    // Setup model to hold list of library files...
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    NSString *homeDir = NSHomeDirectory();
    //TODO: make this robust!!! stop using assumed paths (look it up in Pro6 Prefs)
    self.libraryFiles = [fileManger contentsOfDirectoryAtPath:[homeDir stringByAppendingString:@"/Documents/ProPresenter6"] error:nil];
    NSArray *extensions = [NSArray arrayWithObjects:@"pro6", nil];
    self.libraryFiles = [self.libraryFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(pathExtension IN %@)", extensions]];
    self.libraryFiles = [self.libraryFiles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSLog(@"%lu files in library",(unsigned long)self.libraryFiles.count);
    
    // Setup control delegates...
    self.slidesCollectionView.delegate = self;
    self.slidesCollectionView.dataSource = self;
    
    self.libraryTableView.delegate = self;
    self.libraryTableView.dataSource = self;
    
    self.selectedPlaylistTableView.delegate = self;
    self.selectedPlaylistTableView.dataSource = self;
    
    self.playlistsOutlineView.delegate = self;
    self.playlistsOutlineView.dataSource = self;
    
    // Prepare model to hold Audio Playlists
    if (!self.audioRVPlayListsRootNode)
        self.audioRVPlayListsRootNode = [[RVPlaylistNode alloc] init];
    
    // Load up Audio PlayLists...
    NSString *audioPlaylistFilePath = [@"~/Library/Application Support/RenewedVision/ProPresenter6/Audio.pro6pl" stringByExpandingTildeInPath];
    [self.audioRVPlayListsRootNode loadAudioPlaylistNodesFromFile:audioPlaylistFilePath];
    [self.playlistsOutlineView reloadData];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)doc_save_button_clicked:(NSButton *)sender {
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
                        // Get matching XMlElement and update attibure for volume.
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
                    
                    // Get matching XMlElement and update attribute for volume.
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
        
        // Save File
        NSData *data = [rvPresentationDoc XMLData];
        [data writeToURL:fileURL atomically:YES];
        
        // Disable Save button
        self.docSaveButton.enabled = NO;
    }
}

- (IBAction)audioPlaylistButtonClicked:(NSButton *)sender {
    NSError *error;
    NSString *audioPlaylistFilePath = [@"~/Library/Application Support/RenewedVision/ProPresenter6/Audio.pro6pl" stringByExpandingTildeInPath];
    NSURL *fileURL = [NSURL fileURLWithPath:audioPlaylistFilePath];
    NSXMLDocument *rvAudioPlayListsXMLDoc = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL options:NSXMLDocumentTidyXML error:&error];
    
    // Go right through model (which may be updated with new volumes) and update xml file with volumes
    for (RVPlaylistNode *rvPlayListNode in self.audioRVPlayListsRootNode.children) {
        [self UpdateAudioPlayListsXMLDoc:rvAudioPlayListsXMLDoc forChildrenOfRVAudiaoPlaylistNode:rvPlayListNode];
    }
    
    // Save File
    NSData *data = [rvAudioPlayListsXMLDoc XMLData];
    [data writeToURL:fileURL atomically:YES];
    
    // Disable Save button
    self.audioPlayListSaveButton.enabled = NO;
}

-(void)UpdateAudioPlayListsXMLDoc:(NSXMLDocument *)rvAudioPlayListsXMLDoc forChildrenOfRVAudiaoPlaylistNode:(RVPlaylistNode *)rvPlayListNode {
    if (![rvPlayListNode.type isEqualToString:@"3"] && rvPlayListNode.children.count > 0) {
        for (RVPlaylistNode *childRVPlayListNode in rvPlayListNode.children) {
            [self UpdateAudioPlayListsXMLDoc:rvAudioPlayListsXMLDoc forChildrenOfRVAudiaoPlaylistNode:childRVPlayListNode];
        }
    }
    
    // For each RVAudioCue, find matching XMLElement and update volume
    // TODO: deal with multiple Audio cues with same UUID!!!!
    NSXMLElement *root = [rvAudioPlayListsXMLDoc rootElement];
    if ([rvPlayListNode.type isEqualToString:@"3"] && rvPlayListNode.children.count > 0)
    {
        for (RVAudioCue *rvAudioCue in rvPlayListNode.children) {
            // Get matching XMlElement and update attribute for volume.
            NSArray *audioCueElements = [root nodesForXPath:[NSString stringWithFormat:@"//RVAudioCue[@UUID='%@']",rvAudioCue.UUID] error:nil];
            for (NSXMLNode *audioCueNode in audioCueElements) {
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
    
    //NSLog(@"Saving Node: %@", rvPlayListNode.displayName);
}

-(void)userChangedVolumeOfVideoElement:(RVVideoElement *)rvVideoElement toVolume:(float)volume {
    NSLog(@"VC knows Slide video volume was changed");
    self.avPlayer.volume = volume;
    self.docSaveButton.enabled = YES;
}

-(void)userChangedVolumeOfAudioElement:(RVAudioElement *)rvAudioElement toVolume:(float)volume {
    NSLog(@"VC knows Slide audio volume was changed");
    self.docSaveButton.enabled = YES;
    if (self.soundToPlay && self.currentPlayingAudioElement == rvAudioElement)
        self.soundToPlay.volume = volume;
}

- (void)userChangedVolumeOfPlayListAudioElement:(RVAudioElement *)rvAudioElement toVolume:(float)volume {
    NSLog(@"VC knows PlayList audio volume was changed");
    self.audioPlayListSaveButton.enabled = YES;
    if (self.soundToPlay && self.currentPlayingAudioElement == rvAudioElement)
        self.soundToPlay.volume = volume;
}

/*
 - (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
 
 }
 */


#pragma mark CollectionView Methods

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

#pragma mark TableView methods

/*
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[NSTableRowView alloc] init];
} */

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.libraryTableView)
    {
        // Library TableView
        NSTableCellView *libDocTableViewCell = [tableView makeViewWithIdentifier:@"LibraryDocTableCellView" owner:self];
        libDocTableViewCell.textField.stringValue = self.libraryFiles[row];
        return libDocTableViewCell;
    } else {
        // selectedPlaylistTableView
        PlayListTableCellView *playListTableViewCell = [tableView makeViewWithIdentifier:@"PlayListTableCellView" owner:self];
        RVAudioCue *rvAudioCue = self.currentSelectedRVPlaylistNode.children[row]; // TODO: should really confirm expected type first!
        playListTableViewCell.textField.stringValue = rvAudioCue.displayName;
        playListTableViewCell.rvAudioElement = rvAudioCue.rvAudioElement;
        playListTableViewCell.volumeSlider.enabled = (self.selectedPlaylistTableView.selectedRow == row);
        playListTableViewCell.volumeSlider.floatValue = [playListTableViewCell.rvAudioElement.volume floatValue];
        playListTableViewCell.playListTableCellViewDelegate = self;
        return playListTableViewCell;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.libraryTableView)
    {
        // Library TableView
        if (self.libraryFiles)
            return self.libraryFiles.count;
        else
            return 0;
        
    } else {
        // selectedPlaylistTableView
        if ([self.currentSelectedRVPlaylistNode.type isEqualToString:@"3"])
            return self.currentSelectedRVPlaylistNode.children.count;
        else
            return 0;
    }
}



- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.libraryTableView)
    {
        // Library TableView
        NSLog(@"%ld",(long)self.libraryTableView.selectedRow);
        self.docSaveButton.enabled = NO;
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
    } else {
        // selectedPlaylistTableView

        // Keep volume sliders disabled until row is selected....
        [self.selectedPlaylistTableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
            PlayListTableCellView *playListTableViewCell =  [self.selectedPlaylistTableView viewAtColumn:0 row:row makeIfNecessary:NO];
            playListTableViewCell.volumeSlider.enabled = (row==self.selectedPlaylistTableView.selectedRow);
        }];
        
        // Kick off audio for selected item
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
        RVAudioCue *rvAudioCue = self.currentSelectedRVPlaylistNode.children[self.selectedPlaylistTableView.selectedRow];
        RVAudioElement *rvAudioElement = rvAudioCue.rvAudioElement;
        NSURL *fileURL = [[NSURL alloc] initWithString:rvAudioElement.source];
        if(self.soundToPlay)
        {
            self.soundToPlay = nil;
        }
        self.soundToPlay = [[NSSound alloc] initWithContentsOfURL:fileURL byReference:NO];
        self.soundToPlay.volume = [rvAudioElement.volume floatValue];
        self.soundToPlay.loops = YES;
        self.currentPlayingAudioElement = rvAudioElement;
        [self.soundToPlay play];
        
    }
}

#pragma mark OutlineView methods

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        RVPlaylistNode *rootNode = [self.audioRVPlayListsRootNode.children firstObject];
        return [rootNode.children objectAtIndex:index];
    } else {
        return [((RVPlaylistNode *)item).children objectAtIndex:index];
    }
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [((RVPlaylistNode *)item).type isEqualToString:@"2"];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        // Root node, return count of root node's childern
        RVPlaylistNode *rootNode = [self.audioRVPlayListsRootNode.children firstObject];
        return rootNode.children.count;
    } else {
        return ((RVPlaylistNode *)item).children.count;
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
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
    
    
    self.currentSelectedRVPlaylistNode = [self.playlistsOutlineView itemAtRow:[self.playlistsOutlineView selectedRow]];
    [self.selectedPlaylistTableView reloadData];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *audioTableCellView = [outlineView makeViewWithIdentifier:@"AudioTableCellView" owner:self];
    audioTableCellView.textField.stringValue = ((RVPlaylistNode *)item).displayName;
    
    if ([((RVPlaylistNode *)item).type isEqualToString:@"2"])
        audioTableCellView.imageView.image = [NSImage imageNamed:@"playlistfolder"];
    else
        audioTableCellView.imageView.image = [NSImage imageNamed:@"playlist"];
    
    return audioTableCellView;
}

@end
