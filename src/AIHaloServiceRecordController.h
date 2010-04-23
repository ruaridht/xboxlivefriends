//
//  AIHaloServiceRecordController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Xbox Live Friends.h"
#import "AITabController.h"

@interface AIHaloServiceRecordController : AITabController {
	IBOutlet NSImageView *rankImageView;
	IBOutlet NSTextField *rankTitleField;
	IBOutlet NSTextField *experienceField;
	IBOutlet NSTextField *skillField;
	IBOutlet NSTextField *promotionField;
	IBOutlet NSTextField *serviceTagField;
	
	IBOutlet NSTableView *recentGamesTable;
	NSArray *tableViewRecords;
}

- (void)displayServiceRecord:(NSDictionary *)serviceRecord;
- (void)displayRecentGames:(NSArray *)recentGames;

@end
