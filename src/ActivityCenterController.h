//
//  ActivityCenterController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 26/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Xbox Live Friends.h"

@interface ActivityCenterController : NSObject {
	
	IBOutlet NSWindow *activityCenterWindow;
	IBOutlet WebView *timelineWebview;
	
	IBOutlet NSButton *timelineEnabled;
	
	NSMutableArray *timelinePosts;
	NSMutableArray *timelinePostsTimes;
}

- (void)activityWithNotification:(NSNotification *)notification;
- (void)postActivityWithDictionary:(NSDictionary *)dick;

// IBActions
- (IBAction)openTimeline:(id)sender;
- (IBAction)testTimeline:(id)sender;
- (IBAction)clearTimeline:(id)sender;
   
// Drawing Methods
- (void)redrawTimeline;
- (void)redrawTimelineThreaded;

@end
