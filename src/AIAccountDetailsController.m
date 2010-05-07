//
//  AIAccountDetailsController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AIAccountDetailsController.h"
#import "Xbox Live Friends.h"
#import "AITabController.h"
#import "LoginController.h"

@implementation AIAccountDetailsController

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAccountDetails:) name:@"AccountInfoReloadAccountDetails" object:nil];
}

- (NSString *)notificationName
{
	return @"AIDetailsLoadNotification";
}

- (void)clearTab {
	[avatar setImageAlignment:NSImageAlignBottom];
	[avatar setImage:[NSImage imageNamed:@"no_avatar"]];
	[bio setStringValue:@""];
	[location setStringValue:@""];
	[name setStringValue:@""];
	[zone setStringValue:@""];
	[reputation setReputationPercentage:0];
	[repStars setImage:nil];
}

- (void)displayAccountInfo:(NSString *)gamertag
{	
	//Again, we're fetching the gamercard.  Waste of resource time.
	XBGamercard *gamercard = [XBGamercard cardForSelf];
	[gamercard retrieveEditProfileDetails];
	
	//NSString *URLtag = [gamertag replace:@" " with:@"%20"];
	NSString *URLtag = [gamercard gamertag];
	URLtag = [URLtag replace:@" " with:@"%20"];
	
	[bio setStringValue:[gamercard bio]];
	[location setStringValue:[gamercard location]];
	[name setStringValue:[gamercard realName]];
	//[zone setStringValue:[gamercard gamerzone]];
	[reputation setReputationPercentage:[gamercard rep]];
	[repStars setImage:[gamercard repStars]];
	
	NSImage *avatarImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://avatar.xboxlive.com/avatar/%@/avatar-body.png", URLtag]]];
	if (avatarImage) {
		[avatar setImage:avatarImage];
	}
}

- (void)reloadAccountDetails:(id)sender
{
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayAccountInfo:) object:nil];
	[[[[NSApplication sharedApplication] delegate] operationQueue] addOperation:theOp];
}

@end
