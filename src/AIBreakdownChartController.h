//
//  AIBreakdownChartController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AIBreakdownChartController : AITabController {
	
	IBOutlet MQPieGraphView *pieGraph;
	IBOutlet NSTextField *sliceTitle;
	IBOutlet NSTextField *sliceCaption;
	IBOutlet NSTextField *percentField;
	IBOutlet NSImageView *sliceImage;
	
	MQSlice *lastSlice;
	int lastColorUsed;
	
	MAAttachedWindow *infoPop;
	IBOutlet NSView *infoView;
}

- (void)displayPieChart:(NSArray *)gameList;
- (NSColor *)colorForSlice;
- (void)doInfoPopAt:(NSPoint)position withSlice:(MQSlice *)slice;
- (void) closeInfoPop;

@end