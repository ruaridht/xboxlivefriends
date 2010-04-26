//
//  Profile Editor.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 24/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProfileEditor.h"
#import "MQFunctions.h"
#include <WebKit/WebKit.h>

#define EDIT_PROFILE_URL @"https://live.xbox.com/en-US/signup/UIPStartPage.aspx?appid=xboxcom_gamerCard"

@implementation ProfileEditor

- (id)init
{
	if (![super init]) {
		return nil;
	}
	
	lockEditProfile = nil;
	
	return self;
}

- (void)awakeFromNib
{
	
}

- (void)fetchCurrentProfileInfo
{
	[cancelButton setTitle:@"Cancel"];
	[saveButton setTitle:@"Save"];
	[saveButton setEnabled:NO];
	[editName setEnabled:NO];
	[editBio setEnabled:NO];
	[editLocation setEnabled:NO];
	[editMotto setEnabled:NO];
	
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchCurrentProfileInfoThreaded) object:nil];
	[[[[NSApplication sharedApplication] delegate] operationQueue] addOperation:theOp];
}

- (void)fetchCurrentProfileInfoThreaded
{
	// NOTE: This is the way we will execute our login and logout.
	
	editProfileSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:EDIT_PROFILE_URL] encoding:NSUTF8StringEncoding error:nil];
	
	NSString *currentMotto = [editProfileSource cropFrom:@"Motto\" type=\"text\" value=\"" to:@"\""];
	NSString *currentBio = [editProfileSource cropFrom:@"class=\"XbcPersonalProfile\">" to:@"</textarea>"];
	NSString *currentLocation = [editProfileSource cropFrom:@"ctl00$MainContent$personalProfile$ctl01$txtLocation\" type=\"text\" value=\"" to:@"\""];
	NSString *currentRealName = [editProfileSource cropFrom:@"\"ctl00$MainContent$personalProfile$ctl01$txtName\" type=\"text\" value=\"" to:@"\""];
	
	prevBio = currentBio;
	prevMotto = currentMotto;
	prevName = currentRealName;
	prevLocation = currentLocation;
	
	[editName setStringValue:currentRealName];
	[editBio setStringValue:currentBio];
	[editLocation setStringValue:currentLocation];
	[editMotto setStringValue:currentMotto];
	
	[editName setEnabled:YES];
	[editBio setEnabled:YES];
	[editLocation setEnabled:YES];
	[editMotto setEnabled:YES];
	
	[saveButton setEnabled:YES];
}

- (void)profileInfoSaved
{
	[saveButton setTitle:@"Saved!"];
	[saveButton setEnabled:NO];
	[cancelButton setTitle:@"Close"];
	[editName setEnabled:NO];
	[editBio setEnabled:NO];
	[editLocation setEnabled:NO];
	[editMotto setEnabled:NO];
	
	[editProfileButton setEnabled:NO];
	lockEditProfile = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(unlockEditProfile) userInfo:nil repeats:NO];
}

- (void)unlockEditProfile
{
	[editProfileButton setEnabled:YES];
}

- (IBAction)openEditProfile:(id)sender
{
	if ([editPanel isVisible]) {
		[editPanel makeKeyAndOrderFront:nil];
		
	} else {
		[editPanel makeKeyAndOrderFront:nil];
		NSLog(@"Editing Profile");
		[self fetchCurrentProfileInfo];
	}
} 

- (IBAction)saveEditedProfile:(id)sender
{
	NSString *formSource = editProfileSource;
	
	NSString* script = [NSString stringWithFormat: 
						@"<script language='javascript' type='text/javascript'>function XLF() {document.getElementById('ctl00_MainContent_personalProfile_ctl00_txtMotto').value = decodeURIComponent('%@');document.getElementById('ctl00_MainContent_personalProfile_ctl01_txtName').value = decodeURIComponent('%@');document.getElementById('ctl00_MainContent_personalProfile_ctl01_txtLocation').value = decodeURIComponent('%@');document.getElementById('ctl00_MainContent_personalProfile_ctl01_txtBio').value = decodeURIComponent('%@');document.getElementById('ctl00_MainContent_personalProfile_buttonBoxXboxAM_ctl00').disabled = false;document.getElementById('ctl00_MainContent_personalProfile_buttonBoxXboxAM_ctl00').click();}window.onload = XLF;</script></body>",
						[[editMotto stringValue] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
						[[editName stringValue] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
						[[editLocation stringValue] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
						[[editBio stringValue] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
	
	// Motto, Name, Location
	//ctl00_MainContent_personalProfile_ctl01_txtBio
	
	formSource = [formSource replace:@"</body>" with:script];
	
	[[editProfileWebView mainFrame] loadHTMLString:formSource baseURL:[NSURL URLWithString:@"https://live.xbox.com/en-US/accounts/"]];
	[self profileInfoSaved];
}

- (IBAction)cancelEditProfile:(id)sender
{
	[editPanel close];
}

@end
