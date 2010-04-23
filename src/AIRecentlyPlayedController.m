//
//  AIRecentlyPlayedController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AIRecentlyPlayedController.h"
#import "Xbox Live Friends.h"
#import "AITabController.h"
#import "FriendStatusCell.h"
#import "RecentlyPlayedParser.h"
#import "LoginController.h"

@implementation AIRecentlyPlayedController
- (id)init
{
	if (![super init]) {
		return nil;
	}
	
	tableViewItems = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecentlyPlayed) name:@"AIRecentlyPlayedNeedsRefresh" object:nil];
	
	return self;
}

- (void)awakeFromNib
{
	[recentlyPlayedTable setDelegate:self];
	[recentlyPlayedTable setDataSource:self];
	[recentlyPlayedTable setDoubleAction: @selector(doubleAction:)];
	[recentlyPlayedTable setTarget: self];
	
	
	FriendStatusCell *statusCell = [[FriendStatusCell alloc] init];
	[statusCell setControlView:recentlyPlayedTable];
	[[recentlyPlayedTable tableColumnWithIdentifier:@"gt_and_status"] setDataCell:statusCell];
}

- (NSString *)notificationName
{
	return @"AIRecentlyPlayedLoadNotification";
}

- (void)displayAccountInfo:(NSString *)gamertag
{
	myTag = gamertag;
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIChangeLoadStatus" object:@"Fetching Gamers..."]];
	
	[recentCount setStringValue:@""];
	recentlyPlayed = [RecentlyPlayedParser parseRecent];
	
	if (recentlyPlayed) {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIChangeLoadStatus" object:@"Gamers Loaded."]];
		[self displayRecentlyPlayed];
	} else {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIChangeLoadStatus" object:@""]];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIPaneDoneLoading" object:nil]];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIShowErrorTab" object:@"You have no recently played."]];
	}
}

- (void)clearTab
{
	[tableViewItems removeAllObjects];
	[recentlyPlayed release];
	[recentlyPlayedTable reloadData];
}

- (void)displayRecentlyPlayed
{
	NSLog(@"displayRecentPlayers");
	[tableViewItems removeAllObjects];
	int currentGamerCount = 1;
	for (XBFriend *currentGamer in recentlyPlayed) {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIChangeLoadStatus" object:[NSString stringWithFormat:@"Loading friend %i/%i", currentGamerCount, [recentlyPlayed count]]]];
		[tableViewItems addObject:[currentGamer tableViewRecordWithZone]];
		currentGamerCount += 1;
	}
	[recentCount setStringValue:[NSString stringWithFormat:@"%i Gamers", [recentlyPlayed count]]];
	[recentlyPlayedTable reloadData];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIPaneDoneLoading" object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIChangeLoadStatus" object:@""]];
}

#pragma mark -
#pragma mark TableView Methods

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
	
	int theRow = [recentlyPlayedTable selectedRow];
	
	// It's unlikely that you'll be able to play against yourself =/
	if ((theRow != -1) /* && [[[self currentlySelectedFriend] gamertag] isNotEqualTo:myTag] */){
		[addFriend setEnabled:YES];
		[messageGamer setEnabled:YES];
	} else {
		[addFriend setEnabled:NO];
		[messageGamer setEnabled:NO];
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
	[recentlyPlayedTable deselectRow:[recentlyPlayedTable selectedRow]];
}


- (XBFriend *)currentlySelectedGamer
{
	XBFriend *currentGamer = nil;
	int theRow = [recentlyPlayedTable selectedRow];
	if (theRow != -1){
		currentGamer = [recentlyPlayed objectAtIndex:theRow];
	}
	return currentGamer;
}

// In preparation for the context menu
- (XBFriend *)contextSelectedGamer
{
	XBFriend *currentGamer = nil;
	int theRow = [recentlyPlayedTable clickedRow];
	if (theRow != -1){
		currentGamer = [recentlyPlayed objectAtIndex:theRow];
	}
	return currentGamer;
}

- (void)reloadRecentlyPlayed
{
	[self displayAccountInfo:myTag];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)highlightedGamerInfo:(id)sender
{
	if ([self currentlySelectedGamer]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestLookupWithTag" object:[[self currentlySelectedGamer] gamertag]];
	}
}

// Though we won't likely use this, it is here anyway
- (IBAction)fetchButton:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRecentlyPlayedNeedsRefresh" object:nil];
}

- (IBAction)addCurrentlySelectedGamer:(id)sender
{
	if ([self currentlySelectedGamer]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AddFriendFromNotification" object:[[self currentlySelectedGamer] gamertag]];
	}
}

- (IBAction)messageCurrentlySelectedGamer:(id)sender
{
	if ([self currentlySelectedGamer]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessageToFriend" object:[[self currentlySelectedGamer] gamertag]];
	}
}

@end
