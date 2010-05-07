//
//  GIFriendsOfGamerController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 20/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GIFriendsOfGamerController.h"
#import "Xbox Live Friends.h"
#import "GITabController.h"
#import "FriendStatusCell.h"
#import "GamerFriendsParser.h"
#import "LoginController.h"


@implementation GIFriendsOfGamerController

- (id)init
{
	if (![super init]) {
		return nil;
	}
	
	tableViewItems = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFriendsList) name:@"GamerFriendsNeedsRefresh" object:nil];
	
	return self;
}

- (void)awakeFromNib
{
	[gamerFriendsTable setDelegate:self];
	[gamerFriendsTable setDataSource:self];
	[gamerFriendsTable setDoubleAction: @selector(doubleAction:)];
	[gamerFriendsTable setTarget: self];
	
	
	FriendStatusCell *statusCell = [[FriendStatusCell alloc] init];
	[statusCell setControlView:gamerFriendsTable];
	[[gamerFriendsTable tableColumnWithIdentifier:@"gt_and_status"] setDataCell:statusCell];
}

- (NSString *)notificationName
{
	return @"GIFriendsLoadNotification";
}

- (void)displayGamerInfo:(NSString *)gamertag
{
	myTag = [LoginController myGamertag];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIChangeLoadStatus" object:@"Fetching Friends..."]];
	
	[friendsCount setStringValue:@""];
	currentTag = gamertag;
	gamerFriends = [GamerFriendsParser parseFriendsForTag:currentTag];
	
	if (gamerFriends) {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIChangeLoadStatus" object:@"Friends Loaded."]];
		[self displayGamerFriends];
	} else {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIChangeLoadStatus" object:@""]];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIPaneDoneLoading" object:nil]];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIShowErrorTab" object:[NSString stringWithFormat:@"You are not able to view %@'s friends.", currentTag]]];
	}
}

- (void)clearTab
{
	[tableViewItems removeAllObjects];
	[gamerFriends release];
	[gamerFriendsTable reloadData];
}

- (void)displayGamerFriends
{
	NSLog(@"displayFriendsList");
	[tableViewItems removeAllObjects];
	int currentFriendCount = 1;
	for (XBFriend *currentFriend in gamerFriends) {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIChangeLoadStatus" object:[NSString stringWithFormat:@"Loading friend %i/%i", currentFriendCount, [gamerFriends count]]]];
		[tableViewItems addObject:[currentFriend tableViewRecord]];
		currentFriendCount += 1;
		
		// As long as this isn't a problem, it might be better for the user
		// if we reload the table data each time we fetch the friend's tableViewRecord
		[gamerFriendsTable reloadData];
	}
	[friendsCount setStringValue:[NSString stringWithFormat:@"%i Friends", [gamerFriends count]]];
	//[gamerFriendsTable reloadData];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIPaneDoneLoading" object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIChangeLoadStatus" object:@""]];
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
	
	int theRow = [gamerFriendsTable selectedRow];
	
	
	if ((theRow != -1) && [[[self currentlySelectedFriend] gamertag] isNotEqualTo:myTag]){
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
	[gamerFriendsTable deselectRow:[gamerFriendsTable selectedRow]];
}


- (XBFriend *)currentlySelectedFriend
{
	XBFriend *currentFriend = nil;
	int theRow = [gamerFriendsTable selectedRow];
	if (theRow != -1){
		currentFriend = [gamerFriends objectAtIndex:theRow];
	}
	return currentFriend;
}

- (XBFriend *)contextSelectedFriend
{
	XBFriend *currentFriend = nil;
	int theRow = [gamerFriendsTable clickedRow];
	if (theRow != -1){
		currentFriend = [gamerFriends objectAtIndex:theRow];
	}
	return currentFriend;
}

- (void)reloadFriendsList
{
	[self displayGamerInfo:currentTag];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)highlightedGamerInfo:(id)sender
{
	if ([self currentlySelectedFriend]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestLookupWithTag" object:[[self currentlySelectedFriend] gamertag]];
	}
}

- (IBAction)fetchButton:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GamerFriendsNeedsRefresh" object:nil];
}

- (IBAction)addCurrentlySelectedFriend:(id)sender
{
	if ([self currentlySelectedFriend]) {
		if ([[[self currentlySelectedFriend] gamertag] isEqualToString:myTag]) {
			NSLog(@"User tried to add themself as a friend...");
		} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AddFriendFromNotification" object:[[self currentlySelectedFriend] gamertag]];
		}
	}
}

- (IBAction)messageCurrentlySelectedGamer:(id)sender
{
	if ([self currentlySelectedFriend]) {
		if ([[[self currentlySelectedFriend] gamertag] isEqualToString:myTag]) {
			NSLog(@"User tried to send themself a message ...");
		} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessageToFriend" object:[[self currentlySelectedFriend] gamertag]];
		}
	}
}

@end
