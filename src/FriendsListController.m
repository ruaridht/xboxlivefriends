//
//  FriendsListController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MAAttachedWindowNonActivating.h"
#include "Xbox Live Friends.h"
#include "FriendsListController.h"
#include "GrowlController.h"
#include "FriendsListParser.h"
#include "FriendStatusCell.h"
#include "LoginController.h"
#import "StatusItemView.h"

#define SHELLGAMERCARD	@"http://live.xbox.com:80/Handlers/ShellData.ashx"
#define FRIENDS_REF		@"http://live.xbox.com:80/en-US/friendcenter/Friends"
#define	FRIENDS_PAGE	@"http://live.xbox.com:80/en-US/friendcenter?xr=shellnav"

static BOOL loadThreaded = true;

@implementation FriendsListController

@synthesize friends;

- (id)init {
	if (![super init])
		return nil;

	tableViewItems = [[NSMutableArray alloc] init];
	friendsOnline = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsListNeedsRefresh:) name:@"FriendsListNeedsRefresh" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsListNeedsRedraw:) name:@"FriendsListNeedsRedraw" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendsList:) name:@"ShowFriendsList" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstFriendsListLoad:) name:NSApplicationDidFinishLaunchingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstFriendsListLoad:) name:@"InitialSignIn" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendFromNotification:) name:@"AddFriendFromNotification" object:nil];
	
	return self;
}

- (void)awakeFromNib {

	[friendsListWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMaxYEdge];
	[friendsListWindow setContentBorderThickness:40.0 forEdge:NSMaxYEdge];
	
	[friendsListWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
	[friendsListWindow setContentBorderThickness:36.0 forEdge:NSMinYEdge];

	[[myTag cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[[myMessage cell] setBackgroundStyle:NSBackgroundStyleRaised];
	
	[friendsTable setDelegate:self];
	[friendsTable setDataSource:self];
	[friendsTable setDoubleAction: @selector(doubleAction:)];
	[friendsTable setTarget: self];

	FriendStatusCell *statusCell = [[FriendStatusCell alloc] init];
	[statusCell setControlView:friendsTable];
	[[friendsTable tableColumnWithIdentifier:@"gt_and_status"] setDataCell:statusCell];
	firstLoad = YES;
	
}

- (void)dealloc
{
	[super dealloc];
}

- (void)firstFriendsListLoad:(NSNotification *)notification
{
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(firstFriendsListLoadThread) object:nil];
	[[[NSApp delegate] operationQueue] addOperation:theOp];
	/*
	// THREAD_ATTEMPT
	// We want to work with the webView in a separate thread.
	[NSThread detachNewThreadSelector:@selector(firstFriendsListLoadThread)
							 toTarget:self		// we are the target
						   withObject:nil];
	 */
}

- (void)firstFriendsListLoadThread {
	[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
	/*
	if ([self downloadFriendsList]) {
		[self displayFriendsList];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstFriendsLoaded" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StatusMenuChangeStatus" object:@"You Are Online"];
	}
	 */
	[self downloadFriendsList];
}

- (void)friendsListLocked:(NSNumber *)lockedNum {
	BOOL locked = [lockedNum boolValue];
	if (locked) {
		[myBead setImage:[NSImage imageNamed:@"red_bead"]];
		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"friendsListIsLoadedAndReady"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"friendsListIsLoadedAndReady"];
		[myBead setImage:[NSImage imageNamed:@"green_bead"]];
	}
}


- (void)friendsListNeedsRefresh:(NSNotification *)notification {
	if (loadThreaded) {
		/*
		NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(refreshFriendsListThread) object:nil];
		[[[NSApp delegate] operationQueue] addOperation:theOp];
		 */
		
		// THREAD_ATTEMPT
		// We want to work with the webView in a separate thread.
		[NSThread detachNewThreadSelector:@selector(refreshFriendsListThread)
								 toTarget:self		// we are the target
							   withObject:nil];
	}
   else {
	   /*
		if ([self downloadFriendsList])
			[self displayFriendsList];
		*/
	   [self downloadFriendsList];
   }
}

- (void)showFriendsList:(NSNotification *)notification {
	[friendsListWindow makeKeyAndOrderFront:nil];
}

- (void)friendsListNeedsRedraw:(NSNotification *)notification {
	if (loadThreaded) {
		/*
		NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayFriendsListThread) object:nil];
		[[[NSApp delegate] operationQueue] addOperation:theOp];
		 */
		// THREAD_ATTEMPT
		// We want to work with the webView in a separate thread.
		[NSThread detachNewThreadSelector:@selector(displayFriendsListThread)
								 toTarget:self		// we are the target
							   withObject:nil];
	}
   else
		[self displayFriendsList];
}

- (BOOL)downloadFriendsList
{
	NSLog(@"downloadFriendsList");
	oldFriends = friends;
	
	[self performSelectorOnMainThread:@selector(getFriendListSource) withObject:nil waitUntilDone:YES];
	
	/*
	friends = [FriendsListParser friendsWithSource:friendListSource];
	
	BOOL success = NO;
	if (friends) {
	
		success = YES;
		[self checkFriendsForStatusChange:friends oldFriends:oldFriends];
		[self displayMyGamercard];
		[self displayFriendsList];
		//[self showDockMenu];
		//[self performSelectorOnMainThread:@selector(showDockMenu) withObject:nil waitUntilDone:NO];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"friends"];

		[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
		
	}
	else {
		NSLog(@"Friends = nil");
		[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListConnectionError" object:nil];
		
	}
	
	if (firstLoad) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstFriendsLoaded" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StatusMenuChangeStatus" object:@"You Are Online"];
		firstLoad = NO;
	}
	*/

	[[NSGarbageCollector defaultCollector] collectIfNeeded];
	return YES;
}

- (void)parseAndDisplayFriendsList
{
	NSLog(@"ParsingAndDisplay");
	friends = [FriendsListParser friendsWithSource:friendListSource];
	
	BOOL success = NO;
	if (friends) {
		
		success = YES;
		[self checkFriendsForStatusChange:friends oldFriends:oldFriends];
		[self displayMyGamercard];
		[self displayFriendsList];
		//[self showDockMenu];
		//[self performSelectorOnMainThread:@selector(showDockMenu) withObject:nil waitUntilDone:NO];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"friends"];
		
		[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
		
	}
	else {
		NSLog(@"Friends = nil");
		[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListConnectionError" object:nil];
		
	}
	
	if (firstLoad) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstFriendsLoaded" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StatusMenuChangeStatus" object:@"You Are Online"];
		firstLoad = NO;
	}
}

- (void)getFriendListSource
{
	theData = nil;
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FRIENDS_REF] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[theRequest setMainDocumentURL:[NSURL URLWithString:FRIENDS_PAGE]];
	/*
	[theRequest addValue:@"text/html, * /*" forHTTPHeaderField:@"Accept"];
	[theRequest addValue:@"http://live.xbox.com:80/en-US/friendcenter?xr=shellnav" forHTTPHeaderField:@"Referer"];
	[theRequest addValue:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-us) AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5" forHTTPHeaderField:@"User-Agent"];
	*/
	[theRequest addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	 
	if (theConnection) {
		NSLog(@"Connection succeeded");
		theData = [[NSMutableData data] retain];
	} else {
		NSLog(@"FLC Connection Failed");
	}
}

- (void)showDockMenu {
//
//	for (NSMenuItem *item in [dockMenu itemArray]) {
//		if ([item tag] == 1)
//			[dockMenu removeItem:item];
//	}
//	
//	int index = 0;		
//	for (XBFriend *friend in friends) {
//		
//		if ([[friend status] isEqual:@"Offline"])
//			continue;
//		
//		NSMenuItem *thisItem = [[NSMenuItem alloc] init];
//		//[thisItem setAttributedTitle:[friend dockMenuString]];
//		[thisItem setTitle:[NSString stringWithFormat:@"%@: %@", [friend gamertag], [friend info]]];
//		//[thisItem setImage:[[friend bead] copy]];
//		[thisItem setTag:1];
//		[thisItem setAction:@selector(openURLDonate:)];
//		[dockMenu insertItem:thisItem atIndex:index];
//		index++;
//	}
//	
//	if (index == 0) {
//		NSMenuItem *thisItem = [[NSMenuItem alloc] init];
//		[thisItem setTitle:@"Nobody Online"];
//		[thisItem setTag:1];
//		[dockMenu insertItem:thisItem atIndex:0];
//	}

}

- (void)checkFriendsForStatusChange:(NSArray *)newFriends oldFriends:(NSArray *)oldFriends {
		

	NSMutableDictionary *oldFriendsDict = [NSMutableDictionary dictionary];
	for (XBFriend *friend in oldFriends) {
		[oldFriendsDict setObject:friend forKey:[friend gamertag]];
	}

	
	int differences = 0;

	newFriends = friends;
	for (XBFriend *newFriend in newFriends) {
		
		XBFriend *correspondingOldFriend = [oldFriendsDict objectForKey:[newFriend gamertag]];
		if (correspondingOldFriend) {
			//NSLog(@"%@ (new) corresponds to %@ (old)", [newFriend gamertag], [correspondingOldFriend gamertag]);

			NSString *notificationTitle;
			NSString *notificationName;

			if ([newFriend statusHasChangedFromFriend:correspondingOldFriend]) {

				differences++;
				
				if ([[correspondingOldFriend status] isEqual:@"Offline"]) {
					if ([[newFriend status] isNotEqualTo:@"Offline"]) {
						notificationTitle = @" is now online";
						notificationName = @"Friend Signed In";
					}
				}
				else if ([[correspondingOldFriend status] isNotEqualTo:@"Offline"]) {
					if ([[newFriend status] isEqual:@"Offline"]) {
						notificationTitle = @" went offline";
						notificationName = @"Friend Signed Out";
					}
				}
				
				notificationTitle = [NSString stringWithFormat:@"%@ %@", [newFriend realNameWithFormat:XBUnknownNameDisplayStyle], notificationTitle];
			
				if (notificationName && notificationTitle) { 
					[[NSNotificationCenter defaultCenter] postNotificationName:@"GrowlNotify" object:
					
					[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:notificationName, notificationTitle, [newFriend info], [[newFriend tileImage] TIFFRepresentation], nil] forKeys:[NSArray arrayWithObjects:@"GROWL_NOTIFICATION_NAME", @"GROWL_NOTIFICATION_TITLE", @"GROWL_NOTIFICATION_DESCRIPTION", @"GROWL_NOTIFICATION_ICON", nil]]

					];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:@"ActivityNotify" object:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:notificationName, notificationTitle, [newFriend info], [[newFriend tileImage] TIFFRepresentation], nil] forKeys:[NSArray arrayWithObjects:@"GROWL_NOTIFICATION_NAME", @"GROWL_NOTIFICATION_TITLE", @"GROWL_NOTIFICATION_DESCRIPTION", @"GROWL_NOTIFICATION_ICON", nil]]];
				}
				
			}

			if ([newFriend currentGameHasChangedFromFriend:correspondingOldFriend]) {
				NSLog(@"currentGameHasChangedFromFriend %@ to %@", [newFriend gamertag], [newFriend info]);

				differences++;
				
				notificationName = @"Friend Switched Game";
				notificationTitle = [newFriend realNameWithFormat:XBUnknownNameDisplayStyle];

				if ([[correspondingOldFriend info] rangeOfString:@"Joinable"].location == NSNotFound) {
					if ([[newFriend info] rangeOfString:@"Joinable"].location != NSNotFound) {
						notificationTitle = [NSString stringWithFormat:@"%@ is Joinable", [newFriend realNameWithFormat:XBUnknownNameDisplayStyle]];
						notificationName = @"Friend Is Joinable";
					}
				}
							
				[[NSNotificationCenter defaultCenter] postNotificationName:@"GrowlNotify" object:
				
				[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:notificationName, notificationTitle, [newFriend info], [[newFriend tileImage] TIFFRepresentation], nil] forKeys:[NSArray arrayWithObjects:@"GROWL_NOTIFICATION_NAME", @"GROWL_NOTIFICATION_TITLE", @"GROWL_NOTIFICATION_DESCRIPTION", @"GROWL_NOTIFICATION_ICON", nil]]
				
				];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ActivityNotify" object:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:notificationName, notificationTitle, [newFriend info], [[newFriend tileImage] TIFFRepresentation], nil] forKeys:[NSArray arrayWithObjects:@"GROWL_NOTIFICATION_NAME", @"GROWL_NOTIFICATION_TITLE", @"GROWL_NOTIFICATION_DESCRIPTION", @"GROWL_NOTIFICATION_ICON", nil]]];
			}
			
		}
		
	}
	
}

- (void)displayFriendsList {
	NSLog(@"displayFriendsList");
	[tableViewItems removeAllObjects];
	[friendsOnline removeAllObjects];
	/*
	for (XBFriend *currentFriend in friends) {
		[tableViewItems addObject:[currentFriend tableViewRecord]];
		
		if ([[currentFriend status] isNotEqualTo:@"Offline"]){
			[friendsOnline addObject:currentFriend];
		}
	}
	[friendsTable reloadData];
	 */
	
	// THREAD_ATTEMPT
	// We want to work with the webView in a separate thread.
	[NSThread detachNewThreadSelector:@selector(displayFriendsListOnSeparateThread)
							 toTarget:self		// we are the target
						   withObject:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StatusMenuDisplayFriendsList" object:friendsOnline];
}

- (void)displayFriendsListOnSeparateThread 
{
	for (XBFriend *currentFriend in friends) {
		[tableViewItems addObject:[currentFriend tableViewRecord]];
		
		if ([[currentFriend status] isNotEqualTo:@"Offline"]){
			[friendsOnline addObject:currentFriend];
		}
	}
	[friendsTable reloadData];
}

- (void)displayFriendsListThread {
	[self displayFriendsList];	
}


- (void)refreshFriendsListThread {
	/*
	if ([self downloadFriendsList])
		[self displayFriendsList];
	 */
	[self downloadFriendsList];
	
}



- (void)displayMyGamercard {

	//Download my Gamercard
	XBGamercard *myCard = [XBGamercard cardForSelf];
	
	[myTag setObjectValue:[myCard gamertag]];
	[myMessage setObjectValue:[myCard motto]];
	[myScore setStringValue:[myCard gamerscore]];
	[myTile setImage:[myCard gamertileImage]];
}

- (void)addFriendFromNotification:(NSNotification *)notification
{
	if ([notification object]) {
		//[self addFriendWithTag:[notification object]];
		/*
		NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addFriendWithTag:) object:[notification object]];
		[[[NSApp delegate] operationQueue] addOperation:theOp];
		 */
		// THREAD_ATTEMPT
		// We want to work with the webView in a separate thread.
		[NSThread detachNewThreadSelector:@selector(addFriendWithTag:)
								 toTarget:self		// we are the target
							   withObject:[notification object]];
	}
}

- (void)addFriendWithTag:(NSString *)theGamertag
{	
	[XBFriend friendWithTag:theGamertag];
	
	NSString *theURLBase = @"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?act=Add&gt=";
	NSMutableString *mutableGamerTag = [theGamertag mutableCopy];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	NSString *theStringURL = [NSString stringWithFormat:@"%@%@", theURLBase, mutableGamerTag];
	//[NSApp endSheet:addFriendSheet];
	//querys xbox.com and gets a response
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL] encoding:NSUTF8StringEncoding error:nil];
	NSRange errorRange = [response rangeOfString:@"The gamertag you entered does not exist on Xbox Live."];
	if (errorRange.location != NSNotFound){
		//gamertag doesn't exist
		NSString *theError = [NSString stringWithFormat:@"The gamertag \"%@\" does not exist on Xbox Live.", theGamertag];
		[self displaySimpleErrorMessage:@"Gamertag Doesn't Exist" withMessage:theError attachedTo:friendsListWindow];
	}
	[NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL] encoding:NSUTF8StringEncoding error:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
}

#pragma mark -
#pragma mark IB Actions

- (IBAction)OpenAddFriendPanel:(id)sender
{
	[NSApp beginSheet:addFriendSheet modalForWindow:friendsListWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)  contextInfo:nil];
}

- (IBAction)AddFriend:(id)sender
{
	NSString *theGamertag = [addFriendTag stringValue];
	NSString *theRealName = [addFriendRealName stringValue];
	
	[[XBFriend friendWithTag:theGamertag] setRealName:theRealName];

	NSString *theURLBase = @"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?act=Add&gt=";
	NSMutableString *mutableGamerTag = [theGamertag mutableCopy];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	NSString *theStringURL = [NSString stringWithFormat:@"%@%@", theURLBase, mutableGamerTag];
	[NSApp endSheet:addFriendSheet];
	//querys xbox.com and gets a response
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL] encoding:NSUTF8StringEncoding error:nil];
	NSRange errorRange = [response rangeOfString:@"The gamertag you entered does not exist on Xbox Live."];
	if (errorRange.location != NSNotFound){
		//gamertag doesn't exist
		NSString *theError = [NSString stringWithFormat:@"The gamertag \"%@\" does not exist on Xbox Live.", theGamertag];
		[self displaySimpleErrorMessage:@"Gamertag Doesn't Exist" withMessage:theError attachedTo:friendsListWindow];
	}
	[NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL] encoding:NSUTF8StringEncoding error:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
}

- (IBAction)RemoveSelectedFriend:(id)sender
{
	int theRow = [friendsTable selectedRow];
	if (theRow != -1){

		XBFriend *currentFriend = [friends objectAtIndex:theRow];
		
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Remove"];
		[alert addButtonWithTitle:@"Don't Remove"];
		[alert setMessageText:@"Remove Friend"];
		[alert setInformativeText:[NSString stringWithFormat:@"Do you want to remove %@ from your friends list?", [currentFriend gamertag]]];
		[alert setAlertStyle:NSWarningAlertStyle];

		NSArray *context = [NSArray arrayWithObjects:@"remove_friend", [currentFriend gamertag], nil];
		CFRetain(context);
		[alert beginSheetModalForWindow:friendsListWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:context];

		
	}
}

- (IBAction)CancelParentSheet:(id)sender;
{
	[NSApp endSheet:[sender window]];
}

- (IBAction)FetchButton:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
}

- (IBAction)updateTableView:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRedraw" object:nil];
}

- (void)deleteButtonEnabled:(BOOL)isEnabled
{
	[deleteFriendMenu setEnabled:isEnabled];
}

- (IBAction)forceWindowToFront:(id)sender
{
	// For some reason makeKeyAndOrderFront doesn't work as I would hope
	[friendsListWindow orderFrontRegardless];
	[friendsListWindow makeKeyWindow];
}

#pragma mark -
#pragma mark TableView Methods

// May add a hover functionality later
/*
- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell: (NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *) aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation
{
	return @"Hovering";
}
*/

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
	[self doRequestPop];
	int theRow = [friendsTable selectedRow];
	if (theRow != -1){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListSelectionChanged" object:[friends objectAtIndex:theRow]];
		[self deleteButtonEnabled:YES];
	}
	else{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListSelectionChanged" object:nil];
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

- (void)doubleAction:(id)sender
{
	[self highlightedGamerInfo:nil];
}

- (void)clearTableViewSelection
{
	[friendsTable deselectRow:[friendsTable selectedRow]];
}


- (XBFriend *)currentlySelectedFriend {
	XBFriend *currentFriend = nil;
	int theRow = [friendsTable selectedRow];
	if (theRow != -1){
		currentFriend = [friends objectAtIndex:theRow];
	}
	return currentFriend;
}

- (XBFriend *)contextSelectedFriend {
	XBFriend *currentFriend = nil;
	int theRow = [friendsTable clickedRow];
	if (theRow != -1){
		currentFriend = [friends objectAtIndex:theRow];
	}
	return currentFriend;
}

#pragma mark -
#pragma mark NSWindow Delegates


- (void)windowDidResignKey:(NSNotification *)aNotification
{
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
	if (contextInfo)
		CFRelease(contextInfo);
}

#pragma mark -
#pragma mark Panel Methods


- (void)displaySimpleErrorMessage:(NSString *)headline withMessage:(NSString *)message attachedTo:(NSWindow *)theWindow
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:headline];
	[alert setInformativeText:message];
	[alert setAlertStyle:NSWarningAlertStyle];
	if (theWindow == nil){
		[alert runModal];
	}else{
		[alert beginSheetModalForWindow:theWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(id)contextInfo
{	
	if ([contextInfo objectAtIndex:0] == @"remove_friend"){
		if (returnCode == NSAlertFirstButtonReturn) {
			NSString *theURLBase = @"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?act=Delete&gt=";
			NSMutableString *mutableGamerTag = [[contextInfo objectAtIndex:1] mutableCopy];
			[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
			NSString *theStringURL = [NSString stringWithFormat:@"%@%@", theURLBase, mutableGamerTag];
			// NOTE: Attemp to stop EXEC_BAD_ACCESS
			//[mutableGamerTag release];
			//querys xbox.com and gets a response
			[NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL] encoding:NSUTF8StringEncoding error:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
		}
	}
	// NOTE: Attempt to stop EXEC_BAD_ACCESS
	//[contextInfo release];
}

#pragma mark -
#pragma mark Panel Methods

- (IBAction)openAccountInfo:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRequestLookup" object:nil];
}

- (IBAction)contextualGamerInfo:(id)sender{
	if ([self contextSelectedFriend])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestLookupWithTag" object:[[self contextSelectedFriend] gamertag]];
}

- (IBAction)normalGamerInfo:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIOpenLookupWindow" object:nil];
}

- (IBAction)highlightedGamerInfo:(id)sender{
	if ([self currentlySelectedFriend])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestLookupWithTag" object:[[self currentlySelectedFriend] gamertag]];
}

- (IBAction)contextSendMessageToFriend:(id)sender{
	if ([self contextSelectedFriend])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessageToFriend" object:[[self contextSelectedFriend] gamertag]];
}

- (IBAction)contextualXboxProfile:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/profile.aspx?GamerTag=%@", [[self contextSelectedFriend] urlEscapedGamertag]]]];
}

- (IBAction)contextualMyGamercardProfile:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://profile.mygamercard.net/%@", [[self contextSelectedFriend] urlEscapedGamertag]]]];
}

- (IBAction)contextualBungieNetProfile:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/Stats/Halo3/Default.aspx?player=%@", [[self contextSelectedFriend] urlEscapedGamertag]]]];
}

- (IBAction)openURLMindquirk:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mindquirk.com"]];
}

- (IBAction)openURLDonate:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mindquirk.com/donate"]];
}

- (IBAction)openURLEmailUs:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:lifeupnorth@me.com"]];
}


#pragma mark -
#pragma mark Accept/Reject Friends


- (void)doRequestPop {

	XBFriend *theFriend = [self currentlySelectedFriend];

    if (theFriend && [theFriend requestType] != XBNoFriendRequestType) {
	
	
//		if ([[mImageBrowser selectionIndexes] count] == 0)
//			return;
//
//		NSUInteger selectedIndex =  [[mImageBrowser selectionIndexes] firstIndex];
//
//		NSRect frame = [mImageBrowser itemFrameAtIndex:selectedIndex];
//		frame = [mImageBrowser convertRectToBase:frame];
//		
//		NSRect browserRect = [[mImageBrowser superview] frame];
//		browserRect.origin = [[mImageBrowser window] convertBaseToScreen:browserRect.origin];
//		
//		NSPoint point = [[mImageBrowser window] convertBaseToScreen:frame.origin];
//		point.x += frame.size.width;
//		point.y += frame.size.height / 2;
//		
//		if (point.y > browserRect.origin.y + browserRect.size.height + [infoWindowView frame].size.height + 10 || point.y < browserRect.origin.y  + [infoWindowView frame].size.height + 10) {
//		
//			[self closeInfoPop];
//			return;
//
//		}
//
		if (!requestPop) {
			NSView *theView;
			if ([theFriend requestType] == XBYouSentFriendRequestType)
				theView = youRequestedView;
			else
				theView = wantsToBeView;
			
			NSRect rowRect = [friendsTable rectOfRow:[friendsTable selectedRow]];
			
			NSPoint point = [friendsTable convertRectToBase:rowRect].origin;
			point = [friendsListWindow convertBaseToScreen:point];
			
			point.y += rowRect.size.height / 2;
			point.x += rowRect.size.width - 10;

			requestPop = [[MAAttachedWindowNonActivating alloc] initWithView:theView attachedToPoint:point onSide:MAPositionRight];
			[requestPop setViewMargin:15.0];
			[requestPop setBackgroundColor:[NSColor colorWithCalibratedHue:0.6273 saturation:0.9 brightness:0 alpha:0.95]];
			[friendsListWindow addChildWindow:requestPop ordered:NSWindowAbove];

		}
//				
//		[infoPopTitle setStringValue:[myImageTitles objectAtIndex:selectedIndex]];
//		[infoPopDescription setStringValue:[myImageDescriptions objectAtIndex:selectedIndex]];
//
//		[infoPop setPoint:point side:MAPositionRight];
	

		
		
    } else {
		[self closeRequestPop];
    }

}

- (IBAction)cancelFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Retract", [[self currentlySelectedFriend] urlEscapedGamertag]]];
	[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	[friendsTable selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	[self closeRequestPop];
}

- (IBAction)acceptFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Accept", [[self currentlySelectedFriend] urlEscapedGamertag]]];
	[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	[friendsTable selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	[self closeRequestPop];
}

- (IBAction)denyFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Reject", [[self currentlySelectedFriend] urlEscapedGamertag]]];
	[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	[friendsTable selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	[self closeRequestPop];
}


- (void)closeRequestPop {
	if (requestPop) {
		[friendsListWindow removeChildWindow:requestPop];
		[requestPop orderOut:self];
		[requestPop release];
		requestPop = nil;
	}
}

+ (NSString *)myGamertag
{
	NSString *shellCard = [NSString stringWithContentsOfURL:[NSURL URLWithString:SHELLGAMERCARD] encoding:NSUTF8StringEncoding error:nil];
	NSString *tempGamertag = [shellCard cropFrom:@"gamertag\": \"" to:@"\""];
	
	return tempGamertag;
}

#pragma mark -
#pragma mark NSURLConnection delegates

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	NSLog(@"URLConnection can authenticate against protection space: YES");
	return [protectionSpace receivesCredentialSecurely];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"URLConnection cancelled authentication");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"URLConnection Failed");
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Receieved Authentication Challenge");
	//[[challenge sender] useCredential:[NSURLCredential credentialWithUser:[email stringValue] password:[password stringValue] persistence:NSURLCredentialPersistenceForSession] forAuthenticationChallenge:challenge];
	/*
	if ([challenge previousFailureCount] == 0) {
		NSURLCredential *newCredential;
		newCredential = [NSURLCredential credentialWithUser:[email stringValue]
												   password:[password stringValue]
												persistence:NSURLCredentialPersistenceForSession];
		[[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
	} else {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
		NSLog(@"Bad Username Or Password");
	}*/
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//NSLog(@"URLConnection received data");
	//NSLog(@"Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	[theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"URLConnection received response");
	//NSLog(@"URL: %@", [[response URL] absoluteString]);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"URLConnection finished loading");
	//NSLog(@"Data: %@", [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
	friendListSource = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
	[self parseAndDisplayFriendsList];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
	//NSLog(@"URLConnection should use credential storage: YES");
	return YES;
}

@end
