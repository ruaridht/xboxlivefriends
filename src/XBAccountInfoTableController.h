//
//  XBAccountInfoTableController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBAccountInfoTableController : NSObject {
	IBOutlet NSTableView *infoTable;
	
	IBOutlet NSTabView *accountInfoContentView;
	
	IBOutlet NSView *theContentView;
    NSView *currentView;
	
	
	//tabs
	IBOutlet NSView *accountInfoTextView;
	IBOutlet NSView *accountInfoAchievementView;
	IBOutlet NSView *accountInfoPieView;
	IBOutlet NSView *accountInfoHaloMultiplayerSRView;
	IBOutlet NSView *accountInfoHaloScreenshotsView;
	IBOutlet NSView *accountInfoDetailsView;
	IBOutlet NSView *accountInfoRecentlyPlayed;
	
	IBOutlet NSTextField *accountInfoErrorText;
	
	NSMutableArray *records;
}

- (NSDictionary *)tableViewRecordForTab:(NSString *)tabName icon:(id)icon view:(id)view;

- (void)showErrorTab:(NSNotification *)notification;

@end
