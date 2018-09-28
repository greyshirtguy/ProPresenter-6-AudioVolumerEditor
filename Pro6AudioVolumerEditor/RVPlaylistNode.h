//
//  RVPlaylistNode.h
//  Pro6AudioVolumeEditor
//
//  Created by Dan on 26/9/18.
//  Copyright © 2018 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVPlaylistNode : NSObject <NSXMLParserDelegate>
@property (strong, nonatomic) NSString *displayName;
//@property (strong, nonatomic) NSString *UUID;
@property (strong, nonatomic) NSString *type;  // "0" = root, "2" = Group Folder (Parent Node with Children), "3" = Playlist (Leaf node), "1"=????
@property (nonatomic, strong) NSMutableArray *children; // 0 and 2 have more RVPlaylistNode(s) as children, 3 has RVAudioCues as children
-(void)loadAudioPlaylistNodesFromFile:(NSString *)audioPlayListsFilePath;
@end
