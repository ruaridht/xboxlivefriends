//
//  ActivityCenterController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 26/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ActivityCenterController.h"
#import "Xbox Live Friends.h"

@implementation ActivityCenterController

- (id)init
{
	if (![super init]) {
		return nil;
	}
	
	/*
	timelinePosts = [[NSMutableArray array] retain];
	timelinePostsTimes = [[NSMutableArray array] retain];
	*/
	
	timelinePosts = [[NSMutableArray alloc] init];
	timelinePostsTimes = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityWithNotification:) name:@"ActivityNotify" object:nil];
	
	return self;
}

- (void)awakeFromNib
{
	[timelineWebview setShouldCloseWithWindow:NO];
}

- (void)dealloc
{
	[timelinePosts release];
	[timelinePostsTimes release];
	
	[super dealloc];
}

- (void)activityWithNotification:(NSNotification *)notification
{
	[self postActivityWithDictionary:[notification object]];
}

- (void)postActivityWithDictionary:(NSDictionary *)dick
{
	// Stick with naming conventions
	[timelinePosts insertObject:dick atIndex:0];
	[timelinePostsTimes insertObject:[MQFunctions humanReadableDate:[NSDate dateWithTimeIntervalSinceNow:0.0]] atIndex:0];
	
	if ([timelineEnabled state]) {
		[self redrawTimelineThreaded];
	} else {
		// Roll one
	}
}

- (void)redrawTimelineThreaded
{
	/*
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(redrawTimeline) object:nil];
	[[[NSApp delegate] operationQueue] addOperation:theOp];
	 */
	
	// THREAD_ATTEMPT
	// We want to work with the webView in a separate thread.
	[NSThread detachNewThreadSelector:@selector(redrawTimeline)
							 toTarget:self		// we are the target
						   withObject:nil];
}

- (void)redrawTimeline
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Redrawing Activity Timeline");

	[[timelineWebview mainFrame] stopLoading];
	
	NSString *theRow = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/activity_row.html"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/activity_body.html"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *allRows = @"<!-- something something -->";
	
	NSMutableString *currentEditRow;
	
	if([timelinePosts count] != 0){
		int i = 0;
		for (NSDictionary *item in timelinePosts){
			@try{
				currentEditRow = [theRow mutableCopy];
				
				[currentEditRow replaceOccurrencesOfString:@"%name%" withString:[item objectForKey:@"GROWL_NOTIFICATION_TITLE"] options:0 range:NSMakeRange(0, [currentEditRow length])];
				[currentEditRow replaceOccurrencesOfString:@"%desc%" withString:[item objectForKey:@"GROWL_NOTIFICATION_DESCRIPTION"] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				[currentEditRow replaceOccurrencesOfString:@"%date%" withString:[timelinePostsTimes objectAtIndex:i] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				allRows = [NSString stringWithFormat:@"%@%@", allRows, currentEditRow];
				
				[currentEditRow release];
			}
			@catch (NSException *exception){
				//				NSLog([exception name]);
				//				NSLog([exception reason]);
				NSLog(@"Couldn't log changes");
			}
			i++;
		}
	}
	
	NSMutableString *theBodyMut = [[theBody mutableCopy] autorelease];
	
	[theBodyMut replaceOccurrencesOfString:@"%items%" withString:allRows options:0 range:NSMakeRange(0, [theBodyMut length])];
	
	[[timelineWebview mainFrame] loadHTMLString:theBodyMut baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	
	[pool drain];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)openTimeline:(id)sender
{
	[activityCenterWindow makeKeyAndOrderFront:nil];
	if ([timelineEnabled state]) {
		[self redrawTimeline];
	} else {
		// Pour a pint
	}
}

- (IBAction)testTimeline:(id)sender
{
	[timelinePosts insertObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"TEST NOTIFICATION", @"TEST TITLE", @"TEST INFO", @"TEST_IMAGE? hah", nil] forKeys:[NSArray arrayWithObjects:@"GROWL_NOTIFICATION_NAME", @"GROWL_NOTIFICATION_TITLE", @"GROWL_NOTIFICATION_DESCRIPTION", @"GROWL_NOTIFICATION_ICON", nil]] atIndex:0];
	
	[timelinePostsTimes insertObject:[MQFunctions humanReadableDate:[NSDate dateWithTimeIntervalSinceNow:0.0]] atIndex:0];
}

- (IBAction)clearTimeline:(id)sender
{
	[timelinePosts removeAllObjects];
	[timelinePostsTimes removeAllObjects];
	[self redrawTimeline];
}

@end
