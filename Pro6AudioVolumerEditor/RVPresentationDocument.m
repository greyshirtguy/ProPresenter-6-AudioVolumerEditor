//
//  RVPresentationDocument.m
//  External Display Test
//
//  Created by Daniel Owen on 9/3/18.
//  Copyright © 2018 greyshirtguy. All rights reserved.
//

#import "RVPresentationDocument.h"
#import "RVSlideGrouping.h"
#import "RVDisplaySlide.h"
#import "RVMediaCue.h"
#import "RVAudioCue.h"
#import "RVImageElement.h"
#import "RVVideoElement.h"


@implementation RVPresentationDocument
RVSlideGrouping *currentRVSlideGroupingBeingImported;
RVDisplaySlide *currentRVDisplaySlideBeingImported;
RVMediaCue *currentRVMediaCueBeingImported;
RVAudioCue *currentRVAudioCueBeingImported;
RVImageElement *currentRVImageElementBeingImported;
RVVideoElement *currentRVVideoElementBeingImported;
RVAudioElement *currentRVAudioElementBeingImported;

BOOL importingSlideRTF = NO;

- (NSMutableArray *) groups {
    if (!_groups)
        _groups = [[NSMutableArray alloc] init];
    return _groups;
}

- (NSMutableArray *) arrangements {
    if (!_arrangements)
        _arrangements = [[NSMutableArray alloc] init];
    return _arrangements;
}

- (void) loadFromFile:(NSString *)filePath {
    //RVPresentationDocument *document = [[RVPresentationDocument alloc] init];
    // open file, parse XML and create a new RVPResentation document....
    
    NSURL *xmlURL = [NSURL fileURLWithPath:filePath];
    NSXMLParser *parser = [[ NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [parser setDelegate:self];
    BOOL success = [parser parse];
    
    //NSError *fileRearError;
    //NSLog(@"Contents of file: %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileRearError]);
   
    
    if(success == YES){
        NSLog(@"loadFromFile Parse Succeeded");
    } else {
        NSLog(@"loadFromFile Parse Failed");
    }
            
    //return self;
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //NSLog(@"found string: %@",string);
    if (importingSlideRTF)
    {
        
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSError *err;
        NSAttributedString *as = [[NSAttributedString alloc] initWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType } documentAttributes:nil error:&err];
        
        if (![as.string isEqualToString:@"Double-click to edit"])
            [currentRVDisplaySlideBeingImported.text appendString:as.string];
        //NSAttributedString *as = [[NSAttributedString alloc] initWithString:decodedString attributes:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType}];
        
    }
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    //NSLog(@"Start Element %@", elementName);
    
    if ([elementName isEqualToString:@"RVSlideGrouping"]){
        // Create new RVSlideGrouping object (currentRVSlideGroupingBeingImported)
        currentRVSlideGroupingBeingImported = [[RVSlideGrouping alloc] init];
        // Update attributes
        currentRVSlideGroupingBeingImported.uuid = [attributeDict objectForKey:@"uuid"];
        currentRVSlideGroupingBeingImported.name = [attributeDict objectForKey:@"name"];
        NSArray *colorParts = [[attributeDict objectForKey:@"color"] componentsSeparatedByString:@" "];
        currentRVSlideGroupingBeingImported.color = [NSColor colorWithRed:[colorParts[0] floatValue] green:[colorParts[1] floatValue] blue:[colorParts[2] floatValue] alpha:[colorParts[3] floatValue]];
        
    } else if ([elementName isEqualToString:@"RVDisplaySlide"]) {
        currentRVDisplaySlideBeingImported = [[RVDisplaySlide alloc] init];
        currentRVDisplaySlideBeingImported.text = [NSMutableString stringWithFormat:@""];
        currentRVDisplaySlideBeingImported.label = [attributeDict objectForKey:@"label"];
        NSArray *colorParts = [[attributeDict objectForKey:@"highlightColor"] componentsSeparatedByString:@" "];
        currentRVDisplaySlideBeingImported.highlightColor = [NSColor colorWithRed:[colorParts[0] floatValue] green:[colorParts[1] floatValue] blue:[colorParts[2] floatValue] alpha:[colorParts[3] floatValue]];
    } else if ([elementName isEqualToString:@"NSString"]) {
        if ([[attributeDict objectForKey:@"rvXMLIvarName"] isEqualToString:@"RTFData"])
            importingSlideRTF = YES;
    } else if ([elementName isEqualToString:@"RVMediaCue"]) {
        currentRVMediaCueBeingImported = [[RVMediaCue alloc] init];
        currentRVMediaCueBeingImported.displayName = [attributeDict objectForKey:@"displayName"];
        currentRVMediaCueBeingImported.UUID = [attributeDict objectForKey:@"UUID"];
    } else if ([elementName isEqualToString:@"RVAudioCue"]) {
        currentRVAudioCueBeingImported = [[RVAudioCue alloc] init];
        currentRVAudioCueBeingImported.UUID = [attributeDict objectForKey:@"UUID"];
    } else if ([elementName isEqualToString:@"RVImageElement"]) {
        currentRVImageElementBeingImported = [[RVImageElement alloc] init];
        currentRVImageElementBeingImported.source = [attributeDict objectForKey:@"source"];
        
        //NSString *fileName = [[currentRVImageElementBeingImported.source lastPathComponent] stringByRemovingPercentEncoding];
        // Attempt to load local filename as UIImage and set .image
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString *documentsDirectory = [paths objectAtIndex:0];
        //NSLog(@"%@",[NSString pathWithComponents:@[documentsDirectory,fileName]]);
    } else if ([elementName isEqualToString:@"RVVideoElement"]) {
        currentRVVideoElementBeingImported = [[RVVideoElement alloc] init];
        currentRVVideoElementBeingImported.source = [attributeDict objectForKey:@"source"];
        
        // = [attributeDict objectForKey:@"audioVolume"];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        nf.numberStyle = NSNumberFormatterDecimalStyle;
        currentRVVideoElementBeingImported.audioVolume = [nf numberFromString:[attributeDict objectForKey:@"audioVolume"]];
        //currentRVVideoElementBeingImported.playbackBehavior = [attributeDict objectForKey:@"playbackBehavior"];
    } else if ([elementName isEqualToString:@"RVAudioElement"]) {
        currentRVAudioElementBeingImported = [[RVAudioElement alloc] init];
        currentRVAudioElementBeingImported.source = [attributeDict objectForKey:@"source"];
        currentRVAudioElementBeingImported.volume = [attributeDict objectForKey:@"volume"];
        currentRVAudioElementBeingImported.parentRVAudioCueUUID = currentRVAudioCueBeingImported.UUID;
        
        // = [attributeDict objectForKey:@"audioVolume"];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        nf.numberStyle = NSNumberFormatterDecimalStyle;
        //currentRVVideoElementBeingImported.audioVolume = [nf numberFromString:[attributeDict objectForKey:@"audioVolume"]];
        //currentRVVideoElementBeingImported.playbackBehavior = [attributeDict objectForKey:@"playbackBehavior"];
    } else if ([elementName isEqualToString:@"RVTransition"]) {
        self.transitionDuration = [[attributeDict objectForKey:@"transitionDuration"] doubleValue];
    }
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"RVSlideGrouping"]){
        // add currentRVSlideGroupingBeingImported to self.groups array
        [self.groups addObject:currentRVSlideGroupingBeingImported];
        
        // Update currentRVSlideGroupingBeingImported pointer to nil
        currentRVSlideGroupingBeingImported = nil;
    } else if ([elementName isEqualToString:@"RVDisplaySlide"]) {
        // if we have a currentRVSlideGroupBeingImported...add slide
        if (currentRVSlideGroupingBeingImported) {
            // add currentRVDisplaySlideBeingImported to currentRVSlideGroupingBeingImported.slides array
            [currentRVSlideGroupingBeingImported.slides addObject:currentRVDisplaySlideBeingImported];
            // Update currentRVDisplaySlideBeingImported pointer to nil
            currentRVDisplaySlideBeingImported = nil;
        }
    } else if ([elementName isEqualToString:@"NSString"]) {
        importingSlideRTF = NO;
    }  else if ([elementName isEqualToString:@"RVMediaCue"]) {
        if (currentRVMediaCueBeingImported) {
            [currentRVDisplaySlideBeingImported.cues addObject:currentRVMediaCueBeingImported];
            currentRVMediaCueBeingImported = nil;
        }
    } else if ([elementName isEqualToString:@"RVAudioCue"]) {
        if (currentRVAudioCueBeingImported) {
            [currentRVDisplaySlideBeingImported.cues addObject:currentRVAudioCueBeingImported];
            currentRVAudioCueBeingImported = nil;
        }
    } else if ([elementName isEqualToString:@"RVImageElement"]) {
        if (currentRVMediaCueBeingImported && currentRVImageElementBeingImported) {
            currentRVMediaCueBeingImported.rvImageElement =  currentRVImageElementBeingImported;
        } // TODO: else handle slide image
        if (currentRVImageElementBeingImported)
            currentRVImageElementBeingImported = nil;
    } else if ([elementName isEqualToString:@"RVVideoElement"]) {
        if (currentRVMediaCueBeingImported && currentRVVideoElementBeingImported) {
            currentRVMediaCueBeingImported.rvVideoElement =  currentRVVideoElementBeingImported;
        } // TODO: else handle slide video
        if (currentRVVideoElementBeingImported)
            currentRVVideoElementBeingImported = nil;
    } else if ([elementName isEqualToString:@"RVAudioElement"]) {
        if (currentRVAudioCueBeingImported && currentRVAudioElementBeingImported) {
            currentRVAudioCueBeingImported.rvAudioElement =  currentRVAudioElementBeingImported;
        }
        if (currentRVAudioElementBeingImported)
            currentRVAudioElementBeingImported = nil;
    }
    
    
    
    //
}
@end
