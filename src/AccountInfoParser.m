//
//  AccountInfoParser.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 22/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountInfoParser.h"
#import "Xbox Live Friends.h"
#import "LoginController.h"

#define ACCOUNT_PAGE @"https://live.xbox.com:443/en-US/accounts/MyAccount.aspx"

@implementation AccountInfoParser

+ (NSString *)parseAccountPage
{
	NSString *accSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:ACCOUNT_PAGE] encoding:NSUTF8StringEncoding error:nil];
	NSString *tempPoints = [accSource cropFrom:@"<h2>Microsoft Points Balance</h2>" to:@"<img"];
	tempPoints = [MQFunctions flattenHTML:tempPoints];
	
	if ([tempPoints contains:@"No"]) {
		tempPoints = @"0";
	}
	
	return tempPoints;
}

@end
