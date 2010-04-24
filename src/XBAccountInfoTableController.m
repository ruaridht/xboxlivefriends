//
//  XBAccountInfoTableController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XBAccountInfoTableController.h"
#import "NSVTextFieldCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation XBAccountInfoTableController

- (id)init	{
	if (![super init])
		return nil;
	
	
	return self;
}

- (void)awakeFromNib {
	
	records = [[NSMutableArray alloc] init];
	
	[infoTable setDataSource:self];
	[infoTable setDelegate:self];
	[infoTable setTarget: self];
	
    NSVTextFieldCell *cell;
    cell = [[NSVTextFieldCell alloc] init];
    [cell setVerticalAlignment:YES];
    NSTableColumn *column = [infoTable tableColumnWithIdentifier:@"name"];
    [column setDataCell:cell];
    [cell release];
	
	[theContentView setAutoresizesSubviews:YES];
	
	//	NSView *theView = [[gamerInfoContentView selectedTabViewItem] view];
	//	[theContentView setWantsLayer:YES];
	
	//    [gamerInfoContentView addSubview:[self currentView]];
	//	CATransition *transition;
	//
	//    transition = [CATransition animation];
	//    [transition setType:kCATransitionMoveIn];
	//    [transition setSubtype:kCATransitionFromLeft];
	//	[transition setDuration:0];
	//    
	//	
	//    NSDictionary *ani = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:transition, nil]  forKeys:[NSArray arrayWithObjects:@"subviews", nil]];
	//
	//
	//	
	//	NSDictionary *NOANNIE = [NSDictionary dictionaryWithObject:(id)kCFBooleanTrue
	//					 forKey:kCATransactionDisableActions];
	//
	//	
	//    [theContentView setAnimations:ani];
	
	
	//add items
	[records addObject:[self tableViewRecordForTab:@" XBOX LIVE" icon:[NSNull null] view:[NSNull null]]];
	[records addObject:[self tableViewRecordForTab:@"Achievements" icon:[NSImage imageNamed:@"achievement_tab"] view:accountInfoAchievementView]];
	[records addObject:[self tableViewRecordForTab:@"Breakdown" icon:[NSImage imageNamed:@"pie_tab"] view:accountInfoPieView]];
	[records addObject:[self tableViewRecordForTab:@"Details" icon:[NSImage imageNamed:@"details_tab"] view:accountInfoDetailsView]];
	[records addObject:[self tableViewRecordForTab:@"Last Played" icon:[NSImage imageNamed:@"defaultfriend"] view:accountInfoRecentlyPlayed]];
	[records addObject:[self tableViewRecordForTab:@" HALO 3" icon:[NSNull null] view:[NSNull null]]];
	[records addObject:[self tableViewRecordForTab:@"Service Record" icon:[NSImage imageNamed:@"halo_service_record_tab"] view:accountInfoHaloMultiplayerSRView]];
	[records addObject:[self tableViewRecordForTab:@"Screenshots" icon:[NSImage imageNamed:@"tab_halo_screenshot"] view:accountInfoHaloScreenshotsView]];
	[records addObject:[self tableViewRecordForTab:@" ACCOUNT MGMT" icon:[NSNull null] view:[NSNull null]]];
	[records addObject:[self tableViewRecordForTab:@"Summary" icon:[NSImage imageNamed:@"account_tab"] view:accountInfoAccSummaryView]];
	
	[infoTable reloadData];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AccountInfoTabChanged" object:[[records objectAtIndex:[infoTable selectedRow]] objectForKey:@"name"]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorTab:) name:@"AIShowErrorTab" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorTabModal:) name:@"AIShowErrorTabModal" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSources:) name:@"AIEnableSources" object:nil];
	
}

- (void)setCurrentView:(NSView *)newView {
	
	[newView setFrameSize:[theContentView frame].size];
	[newView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	
    if (!currentView) {
		[theContentView addSubview:newView];
		currentView = newView;
        return;
    }
	
    [[theContentView animator] replaceSubview:currentView with:newView];
	
    currentView = newView;
}


- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	
	if (tableColumn == nil && [[records objectAtIndex:row] objectForKey:@"icon"] == [NSNull null]) {
		return [[NSTextFieldCell alloc] init];
	}
	
	return [tableColumn dataCellForRow:row];
	
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	if ([[records objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return YES;
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if ([[records objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null])
		return NO;
	
	return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if ([[records objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return 20.0;
	
	return 32.0;
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [records count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
	id theRecord, theValue;
	
	if (aTableColumn == nil && [[records objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null]) {
		theValue = [[records objectAtIndex:rowIndex] objectForKey:@"name"];
	}
	else {
		theRecord = [records objectAtIndex:rowIndex];
		theValue = [theRecord objectForKey:[aTableColumn identifier]];
	}
	
	if (theValue == [NSNull null])
		return nil;
	
	return theValue;
}


- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int theRow = [infoTable selectedRow];
	if (theRow != -1){
		id theRecord;
		theRecord = [records objectAtIndex:theRow];
		if ([theRecord objectForKey:@"icon"] != [NSNull null]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AccountInfoTabWillChange" object:[theRecord objectForKey:@"name"]];
			[self setCurrentView:[theRecord objectForKey:@"view"]];
			//[[gamerInfoContentView selectedTabViewItem] setView:[theRecord objectForKey:@"view"]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AccountInfoTabChanged" object:[theRecord objectForKey:@"name"]];
		}
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

- (NSDictionary *)tableViewRecordForTab:(NSString *)tabName icon:(id)icon view:(id)view
{
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	[record setObject:icon forKey:@"icon"];
	[record setObject:tabName forKey:@"name"];
	[record setObject:view forKey:@"view"];
	
	return record;
}

- (void)showErrorTab:(NSNotification *)notification
{
	if ([notification object])
		[accountInfoErrorText setStringValue:[notification object]];
	[self setCurrentView:accountInfoTextView];
	//[[gamerInfoContentView selectedTabViewItem] setView:gamerInfoTextView];
}

- (void)showErrorTabModal:(NSNotification *)notification
{
	if ([notification object])
		[accountInfoErrorText setStringValue:[notification object]];
	//[[gamerInfoContentView selectedTabViewItem] setView:gamerInfoTextView];
	[self setCurrentView:accountInfoTextView];
	[infoTable setEnabled:NO];
}

- (void)enableSources:(NSNotification *)notification {
	[infoTable setEnabled:YES];
	[self tableViewSelectionDidChange:nil];
}

@end
