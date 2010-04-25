//
//  Profile Editor.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 24/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProfileEditor.h"

#define EDIT_PROFILE_URL @"https://live.xbox.com/en-US/signup/UIPStartPage.aspx?appid=xboxcom_gamerCard"

@implementation ProfileEditor

- (id)init
{
	if (![super init]) {
		return nil;
	}
	
	return self;
}

- (void)awakeFromNib
{
	
}

- (IBAction)openEditProfile:(id)sender
{
	if (!editPanel) {
		[editPanel makeKeyAndOrderFront:nil];
		NSLog(@"Editing Profile");
		//[self parseProfileInfo];
	} else {
		[editPanel makeKeyAndOrderFront:nil];
	}
}

@end
