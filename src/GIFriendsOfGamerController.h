//
//  GIFriendsOfGamerController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 20/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITabController.h"
#import "Xbox Live Friends.h"

@interface GIFriendsOfGamerController : GITabController {
	
	IBOutlet NSTableView *gamerFriendsTable;
	IBOutlet NSTextField *friendsCount;
	IBOutlet NSButton *addFriend;
	IBOutlet NSButton *messageGamer;
	
	NSString *myTag;
	NSString *currentTag;
	
	NSMutableArray *tableViewItems;
	NSArray *gamerFriends;
}

- (void)displayGamerFriends;

- (XBFriend *)currentlySelectedFriend;
- (XBFriend *)contextSelectedFriend;

- (void)reloadFriendsList;

- (IBAction)highlightedGamerInfo:(id)sender;
- (IBAction)fetchButton:(id)sender;
- (IBAction)addCurrentlySelectedFriend:(id)sender;
- (IBAction)messageCurrentlySelectedGamer:(id)sender;

@end
