//
//  Controller.m
//  Xbox Live Friends
//
//  i trip blind kids, what's your anti-drug?
// 
//  © 2006 mindquirk
//  
#import "Xbox Live Friends.h"
#import "Controller.h"
#import "GrowlController.h"
#import "LoginController.h"
#import "StatusItemView.h"
#import "FriendsListController.h"

StayAround *stayArounds;

@implementation Controller

#pragma mark -
#pragma mark Application Delegates

+ (StayAround *)stayArounds {
	if (!stayArounds)
		stayArounds = [[StayAround alloc] init];
	return stayArounds;
}

- (id)init {
	
	if (![super init])
	return nil;
	
	[Controller stayArounds];
	
	//[MQFunctions startDebugLog];

	[NSApp setDelegate:self];
	[XBFriendDefaultsManager setupDefaults];
	
	refreshTimer = nil;
		
	//[[GrowlController alloc] init];
	
	queue = [[NSOperationQueue alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefreshTimer) name:@"StartRefreshTimer" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUnreadMessages:) name:@"StatusMenuUnreadMessages" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStatusMenuStatus:) name:@"StatusMenuChangeStatus" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayStatusMenuFriendsList:) name:@"StatusMenuDisplayFriendsList" object:nil];
	 
	/*
	if (refreshTimer == nil) {
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	}
	 */
	
	tableViewItems = [[NSMutableArray alloc] init];

	return self;
	
}

- (NSOperationQueue *)operationQueue {
	return queue;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InSignInMode"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"friendsListIsLoadedAndReady"];
}

- (void)awakeFromNib {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowDebugMenu"]) {
		[[debugMenu menu] removeItem:debugMenu];
	}
	
	if ([self shouldBeUIElement]) {
		[showStatusItem setEnabled:NO];
	} else {
		[showStatusItem setEnabled:YES];
	}
	
	if ([showStatusItem state]) {
		[showDockIcon setEnabled:YES];
		
		// Create an NSStatusItem.
		float width = 25.0;
		float height = [[NSStatusBar systemStatusBar] thickness];
		NSRect viewFrame = NSMakeRect(0, 0, width, height);
		statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];
		[statusItem setView:[[[StatusItemView alloc] initWithFrame:viewFrame controller:self] autorelease]];
	
		[statusFriendsOnline setDelegate:self];
		[statusFriendsOnline setDataSource:self];
		[statusFriendsOnline setDoubleAction: @selector(doubleAction:)];
		[statusFriendsOnline setTarget: self];
	} else {
		[showDockIcon setState:1];
		[showDockIcon setEnabled:NO];
	}
	
	// Set AutoRefresh State in Preferences
	if ([autoRefresh state]) {
		[autoRefresh setTitle:@"On"];
	} else {
		[autoRefresh setTitle:@"Off"];
	}
}

- (void)dealloc
{
	[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
	[super dealloc];
}

#pragma mark -
#pragma mark Refresh Controls

- (void)startRefreshTimer
{
	if ([autoRefresh state]) {
		int timeInt = [[refreshTime stringValue] intValue];
		NSLog(@"%i", timeInt);
		if (timeInt < 30) {
			timeInt = 30;
		}
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeInt target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	}
}

- (IBAction)toggleRefreshTimer:(id)sender
{
	if ([autoRefresh state]) {
		[autoRefresh setTitle:@"On"];
		int timeInt = [[refreshTime stringValue] intValue];
		if (timeInt < 30) {
			timeInt = 30;
		}
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeInt target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	} else {
		// ![autoRefresh state];
		[autoRefresh setTitle:@"Off"];
		[refreshTimer invalidate];
	}
}

- (IBAction)changeRefreshTime:(id)sender
{
	int timeInt = [[refreshTime stringValue] intValue];
	if (timeInt < 30) {
		timeInt = 30;
	}
	NSLog(@"Changing refresh time to: %i", timeInt);
	if ([autoRefresh state]) {
		NSLog(@"Refresh is on");
		[refreshTimer invalidate];
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeInt target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	}
}

- (void)timedRefresh 
{
	if ([LoginController isLoggedIn]) {
		if (![[NSUserDefaults standardUserDefaults] boolForKey:@"InSignInMode"]) {
			NSLog(@"Timed Refresh");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
		} else {
			NSLog(@"Tried to refresh, but the sign in panel was open.");
		}
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListConnectionError" object:nil];
	}
}

#pragma mark -
#pragma mark StatusItem

- (void)toggleAttachedWindowAtPoint:(NSPoint)pt
{
    // Attach/detach window.
    if (!statusAttWindow) {
        statusAttWindow = [[MAAttachedWindow alloc] initWithView:statusView 
												 attachedToPoint:pt 
														inWindow:nil 
														  onSide:MAPositionBottom 
													  atDistance:1.0];
		
		[statusAttWindow setArrowBaseWidth:40.0];
		[statusAttWindow setArrowHeight:10.0];
        [statusAttWindow orderFrontRegardless];
    } else {
        [statusAttWindow orderOut:self];
        [statusAttWindow release];
        statusAttWindow = nil;
    }    
}

- (void)toggleStatusMenu
{
	[statusItem popUpStatusItemMenu:statusMenu];
}

- (void)changeNumberOfFriendsOnline:(NSString *)onlineCount
{
	NSString *string;
	
	if ([onlineCount isEqualToString:@"1"]) {
		string = [NSString stringWithFormat:@"%@ Friend Online", onlineCount];
	} else {
		string = [NSString stringWithFormat:@"%@ Friends Online", onlineCount];
	}
	[statusMenuFriends setTitle:string];
}

- (void)changeUnreadMessages:(NSNotification *)aNotification
{
	NSString *string;
	
	if ([aNotification object] == 1) {
		string = [NSString stringWithFormat:@"%i New Message", [aNotification object]];
	} else {
		string = [NSString stringWithFormat:@"%i New Messages", [aNotification object]];
	}
	[statusMenuMessages setTitle:string];
}

- (void)changeStatusMenuStatus:(NSNotification *)aNotification
{
	[statusMenuStatus setTitle:[aNotification object]];
	[dockMenuStatus setTitle:[aNotification object]];
}

- (void)displayStatusMenuFriendsList:(NSNotification *)aNotification
{
	onlineFriends = [[aNotification object] copy];
	[tableViewItems removeAllObjects];
	
	for (XBFriend *currentFriend in onlineFriends) {
		NSMutableDictionary *record = [NSMutableDictionary dictionary];
		[record setObject:[currentFriend gamertag] forKey:@"gamertag"];
		[tableViewItems addObject:record];
	}
	[statusFriendsOnline reloadData];
	[self changeNumberOfFriendsOnline:[NSString stringWithFormat:@"%i", [onlineFriends count]]];
	NSString *myGamertag = [FriendsListController myGamertag];
	[myTag setStringValue:myGamertag];
}

#pragma mark Status Item TableView Delegates

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell: (NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *) aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation
{
	XBFriend *currentFriend = [onlineFriends objectAtIndex:row];
	NSString *friendStatus = [currentFriend info];
	return friendStatus;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [tableViewItems count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
	return [[tableViewItems objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}


- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	//[self doRequestPop];
	int theRow = [statusFriendsOnline selectedRow];
	if (theRow != -1){
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListSelectionChanged" object:[friends objectAtIndex:theRow]];
		//[self deleteButtonEnabled:YES];
	}
	else{
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListSelectionChanged" object:nil];
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

- (void)doubleAction:(id)sender
{
	// Lookup currently selected gamer?
	NSString *currentlySelectedTag = [onlineFriends objectAtIndex:[statusFriendsOnline selectedRow]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestLookupWithTag" object:currentlySelectedTag];
}

- (void)clearTableViewSelection
{
	[statusFriendsOnline deselectRow:[statusFriendsOnline selectedRow]];
}

#pragma mark -
#pragma mark Preferences

- (IBAction)setApplicationIsAgent:(id)sender
{
	if ([showDockIcon state]) {
		NSLog(@"Show Dock Icon");
		[self setShouldBeUIElement:NO];
		
	} else {
		NSLog(@"Hide Dock Icon");
		// We don't want the user to be able to hide the dock icon if the status icon is not being displayed.
		if ([showStatusItem state]){
			[self setShouldBeUIElement:YES];
		}
	}
}
		
- (BOOL)shouldBeUIElement {
	return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSUIElement"] boolValue];
}

- (void)setShouldBeUIElement:(BOOL)hidden {
	NSString * plistPath = nil;
	NSFileManager *manager = [NSFileManager defaultManager];
	if (plistPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Info.plist"]) {
		if ([manager isWritableFileAtPath:plistPath]) {
			NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
			[infoDict setObject:[NSNumber numberWithBool:hidden] forKey:@"LSUIElement"];
			[infoDict writeToFile:plistPath atomically:NO];
			[manager setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate] ofItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
			//return YES;
		}
	}
	//return NO;
}

- (IBAction)setHidesStatusItem:(id)sender
{
	if ([showStatusItem state]) {
		[showDockIcon setEnabled:YES];
		NSLog(@"Show the status Item");
		
		float width = 25.0;
		float height = [[NSStatusBar systemStatusBar] thickness];
		NSRect viewFrame = NSMakeRect(0, 0, width, height);
		statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];
		[statusItem setView:[[[StatusItemView alloc] initWithFrame:viewFrame controller:self] autorelease]];
		
		[statusFriendsOnline setDelegate:self];
		[statusFriendsOnline setDataSource:self];
		[statusFriendsOnline setDoubleAction: @selector(doubleAction:)];
		[statusFriendsOnline setTarget: self];
		
	} else {
		NSLog(@"Hide the status Item");
		[showDockIcon setState:1];
		[showDockIcon setEnabled:NO];
		[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
	}
}

@end