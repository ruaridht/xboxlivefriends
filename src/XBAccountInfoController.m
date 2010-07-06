//
//  XBAccountInfoController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XBAccountInfoController.h"
#import "Xbox Live Friends.h"
#import "FriendsListController.h"
#import "AccountInfoParser.h"

#define ACCOUNT_PAGE @"https://live.xbox.com:443/en-US/accounts/MyAccount.aspx"

@implementation XBAccountInfoController

@synthesize currentGamertag, currentTabName;

- (id)init
{
	if (![super init]) {
		return nil;
	}
	
	[[Controller stayArounds] addObject:self];
	
	[self setCurrentGamertag: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAccountInfoWindow) name:@"AIOpenAccountWindow" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookupAccountInfo) name:@"AIRequestLookup" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelectionChanged:) name:@"AccountInfoTabChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSpinner:) name:@"AIStartProgressIndicator" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSpinner:) name:@"AIStopProgressIndicator" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paneDoneLoading:) name:@"AIPaneDoneLoading" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:@"AIRequestFailed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamercardLoaded:) name:@"AIGamercardLoaded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLoadStatus:) name:@"AIChangeLoadStatus" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchAccountSettingsInfo) name:@"AIFetchAccountSettingsInfo" object:nil];
	
	return self;
}

- (void)changeLoadStatus:(NSNotification *)notification
{
	if ([notification object]) {
		[currentProgress setStringValue:[notification object]];
	} else {
		NSLog(@"No notification object");
		[currentProgress setStringValue:@""];
	}
	
}

-(void)openAccountInfoWindow {
	if (!accountInfoWindow) {
        if (![NSBundle loadNibNamed:@"AccountInfo" owner:self])  {
            NSLog(@"Failed to load AccountInfo nib");
            NSBeep();
            return;
        }
	}
	
	[accountInfoWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMaxYEdge];
	[accountInfoWindow setContentBorderThickness:50.0 forEdge:NSMaxYEdge];
	
	[accountInfoWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
	[accountInfoWindow setContentBorderThickness:30.0 forEdge:NSMinYEdge];
	
	
	[[gamertag cell] setBackgroundStyle:NSBackgroundStyleRaised];
	
	
	[accountInfoWindow orderFront:nil];
}

- (void)lookupAccountInfo
{
	NSLog(@"Looking up account info");
	currentGamertag = [LoginController myGamertag];
	[self openAccountInfoWindow];
	[self openProgressPanel];
	[self fullLookup];
}

- (void)fullLookup
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIEnableSources" object:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIStartProgressIndicator" object:nil];
	
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(lookupAccountInfoThreaded) object:nil];
	[[[[NSApplication sharedApplication] delegate] operationQueue] addOperation:theOp];
	
}

-(void)gamercardLoaded:(NSNotification *) notification {
	
	XBGamercard *theGamercard = [notification object];
	
	if ([theGamercard gamertag] == nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRequestFailed" object:@"Gamertag Not Found"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIShowErrorTabModal" object:nil];
		[gamertag setStringValue:@""];
		[gamerscore setStringValue:@""];
		[tile setImage:nil];
		return;
	}
	
	[self setCurrentGamertag:[theGamercard gamertag]];
	[gamertag setStringValue:[theGamercard gamertag]];
	[gamerscore setStringValue:[theGamercard gamerscore]];
	[motto setStringValue:[MQFunctions flattenHTML:[theGamercard motto]]];
	[tile setImage:[theGamercard gamertileImage]];
	
	/*
	if ([[[theGamercard gamertileURL] absoluteString] isEqualToString:@"http://tiles.xbox.com/tiles/8y/ov/0Wdsb2JhbC9EClZWVEoAGAFdL3RpbGUvMC8yMDAwMAAAAAAAAAD+ACrT.jpg"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRequestFailed" object:@"No Gamer Info for Original Xbox Accounts"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIShowErrorTabModal" object:nil];
		return;
	}
	*/
	
	[self loadCurrentTab];
}

- (void)lookupAccountInfoThreaded
{
	XBGamercard *theGamercard = [XBGamercard cardForSelf];
	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIGamercardLoaded" object:theGamercard];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIFetchAccountSettingsInfo" object:nil];
	
}

- (void)fetchAccountSettingsInfo
{
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchAccountSettingsInfoThreaded) object:nil];
	[[[[NSApplication sharedApplication] delegate] operationQueue] addOperation:theOp];
}

- (void)fetchAccountSettingsInfoThreaded
{
	NSString *tempPoints = [AccountInfoParser parseAccountPage];
	[mspoints setStringValue:tempPoints];
}

- (void)tabSelectionChanged:(NSNotification *)notification
{
	[self setCurrentTabName:[notification object]];
	if (currentGamertag) {
		[self loadCurrentTab];
	}
}

- (void)loadCurrentTab
{
	[self startSpinner:nil];
	[progressPanelText setStringValue:[NSString stringWithFormat:@"Loading %@...", currentTabName]];
	
	if ([currentTabName isEqual:@"Achievements"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIAchievementsLoadNotification" object:currentGamertag];
	}
	if ([currentTabName isEqual:@"Breakdown"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIBreakdownChartLoadNotification" object:currentGamertag];
	}
	if ([currentTabName isEqual:@"Service Record"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIHaloServiceRecordLoadNotification" object:currentGamertag];
	}
	if ([currentTabName isEqual:@"Screenshots"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIHaloScreenshotLoadNotification" object:currentGamertag];
	}
	if ([currentTabName isEqual:@"Details"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIDetailsLoadNotification" object:currentGamertag];
	}
	if ([currentTabName isEqual:@"Last Played"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRecentlyPlayedLoadNotification" object:currentGamertag];
	}
	if ([currentTabName isEqual:@"Summary"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIAccountSummaryLoadNotification" object:currentGamertag];
	}
	if ([currentTabName isEqual:@"Purchases"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIPurchaseHistoryLoadNotification" object:currentGamertag];
	}
}

- (void)startSpinner:(NSNotification *)notification
{
	[progressPanelIndicator setUsesThreadedAnimation:YES];
	[spinner startAnimation:nil];
	[progressPanelIndicator startAnimation:nil];
}

- (void)stopSpinner:(NSNotification *)notification
{
	[spinner stopAnimation:nil];
	[progressPanelIndicator stopAnimation:nil];
}

- (void)paneDoneLoading:(NSNotification *)notification
{
	[self stopSpinner:nil];
	[self closeProgressPanel];
}

- (void)openProgressPanel
{
	[NSApp beginSheet:progressPanel modalForWindow:accountInfoWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)  contextInfo:nil];
}

- (void)closeProgressPanel
{
	if ([progressPanel isVisible]) {
		[NSApp endSheet:progressPanel];
	}
}

- (void)openErrorPanel
{
	[NSApp beginSheet:errorPanel modalForWindow:accountInfoWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)  contextInfo:nil];
}

- (IBAction)closeErrorPanel:(id)sender
{
	[NSApp endSheet:errorPanel];
	//[self openLookupPanel:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
	if (returnCode == CloseWindowPanelReturnCode) {
		[accountInfoWindow orderOut:nil];
	}
	if (returnCode == OpenProgressBarPanelReturnCode) {
		[self openProgressPanel];
	}
	if (returnCode == ErrorPanelReturnCode) {
		[self openErrorPanel];
	}
}

@end
