//
//  AIRecentlyPlayedController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Xbox Live Friends.h"
#import "AITabController.h"

@interface AIRecentlyPlayedController : AITabController {
	IBOutlet NSTableView *recentlyPlayedTable;
	IBOutlet NSTextField *recentCount;
	IBOutlet NSButton *addFriend;
	IBOutlet NSButton *messageGamer;
	
	NSString *myTag;
	
	NSMutableArray *tableViewItems;
	NSArray *recentlyPlayed;
}

- (void)displayRecentlyPlayed;

- (XBFriend *)currentlySelectedGamer;
- (XBFriend *)contextSelectedGamer;

- (void)reloadRecentlyPlayed;

- (IBAction)highlightedGamerInfo:(id)sender;
- (IBAction)fetchButton:(id)sender;
- (IBAction)addCurrentlySelectedGamer:(id)sender;
- (IBAction)messageCurrentlySelectedGamer:(id)sender;

@end
