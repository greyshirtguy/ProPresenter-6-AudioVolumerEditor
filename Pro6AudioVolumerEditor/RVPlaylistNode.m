//
//  RVPlaylistNode.m
//  Pro6AudioVolumeEditor
//
//  Created by Dan on 26/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import "RVPlaylistNode.h"
#import "RVAudioCue.h"
#import "RVAudioElement.h"

@interface RVPlaylistNode ()

@end

@implementation RVPlaylistNode
NSMutableArray *currentRVPlaylistNodesBeingimported; // This is a simple stack used to process hierarchical playlist XML data
extern RVAudioCue *currentRVAudioCueBeingImported; // I'm sure I'm doing something wrong-ish here....(needed extern to avoid duplicate symbols when linking)
extern RVAudioElement *currentRVAudioElementBeingImported;

- (NSString *) type {
    // New RVPlaylistNode default to type 0 (Root Node)
    if (!_type)
        _type = @"0";
    return _type;
}

- (NSMutableArray *) children {
    if (!_children)
        _children = [[NSMutableArray alloc] init];
    return _children;
}


-(void)loadAudioPlaylistNodesFromFile:(NSString *)audioPlayListsFilePath {
    currentRVPlaylistNodesBeingimported = [[NSMutableArray alloc] init];
    
    // open file, parse XML and populate RVPlaylistNode children
    NSURL *xmlURL = [NSURL fileURLWithPath:audioPlayListsFilePath];
    NSXMLParser *parser = [[ NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    //[parser setShouldProcessNamespaces:YES];
    //[parser setShouldReportNamespacePrefixes:YES];
    //[parser setShouldResolveExternalEntities:YES];
    [parser setDelegate:self];
    BOOL success = [parser parse];
    
    //NSError *fileRearError;
    //NSLog(@"Contents of file: %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileRearError]);
    
    if(success == YES){
        NSLog(@"loadAudioPlatlistNodesFromFile Parse Succeeded");
    } else {
        NSLog(@"loadAudioPlatlistNodesFromFile Parse Failed");
    }
    
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"RVPlaylistNode"]){
        NSLog(@"Got RVPlaylistNode %@", [attributeDict objectForKey:@"displayName"]);
        RVPlaylistNode *currentRVPlaylistNodeBeingImported = [[RVPlaylistNode alloc] init];
        currentRVPlaylistNodeBeingImported.type =[attributeDict objectForKey:@"type"];
        currentRVPlaylistNodeBeingImported.displayName = [attributeDict objectForKey:@"displayName"];
        currentRVPlaylistNodeBeingImported.UUID = [attributeDict objectForKey:@"UUID"];
        
        if ([currentRVPlaylistNodesBeingimported count] == 0) {
            [self.children addObject:currentRVPlaylistNodeBeingImported];
        } else {
            RVPlaylistNode *currentParentNode = [currentRVPlaylistNodesBeingimported lastObject];
            [currentParentNode.children addObject:currentRVPlaylistNodeBeingImported];
        }
        
        [currentRVPlaylistNodesBeingimported addObject:currentRVPlaylistNodeBeingImported];
        
        
    } else if ([elementName isEqualToString:@"RVAudioCue"]){
        //NSLog(@"Got RVAudioCue %@", [attributeDict objectForKey:@"displayName"]);
        currentRVAudioCueBeingImported = [[RVAudioCue alloc] init];
        currentRVAudioCueBeingImported.UUID = [attributeDict objectForKey:@"UUID"];
        currentRVAudioCueBeingImported.displayName = [attributeDict objectForKey:@"displayName"];
    } else if ([elementName isEqualToString:@"RVAudioElement"]){
        currentRVAudioElementBeingImported = [[RVAudioElement alloc] init];
        currentRVAudioElementBeingImported.source = [attributeDict objectForKey:@"source"];
        currentRVAudioElementBeingImported.volume = [attributeDict objectForKey:@"volume"];
        currentRVAudioElementBeingImported.parentRVAudioCueUUID = currentRVAudioCueBeingImported.UUID;
    }
    
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"RVPlaylistNode"]){
        if (currentRVPlaylistNodesBeingimported) {
            [currentRVPlaylistNodesBeingimported removeLastObject];
        }
    } else if ([elementName isEqualToString:@"RVAudioCue"]) {
        if (currentRVAudioCueBeingImported) {
            if (currentRVPlaylistNodesBeingimported) {
                RVPlaylistNode *currentRVPlaylistNodeBeingImported = [currentRVPlaylistNodesBeingimported lastObject];
                [currentRVPlaylistNodeBeingImported.children addObject:currentRVAudioCueBeingImported];
            }
            currentRVAudioCueBeingImported = nil;
        }
    } else if ([elementName isEqualToString:@"RVAudioElement"]) {
        if (currentRVAudioCueBeingImported && currentRVAudioElementBeingImported) {
            currentRVAudioCueBeingImported.rvAudioElement =  currentRVAudioElementBeingImported;
        }
        if (currentRVAudioElementBeingImported)
            currentRVAudioElementBeingImported = nil;
    }
}

@end
