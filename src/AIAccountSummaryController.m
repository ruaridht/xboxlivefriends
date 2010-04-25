//
//  AIAccountSummaryController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 24/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AIAccountSummaryController.h"
#import "Xbox Live Friends.h"

#define ACCOUNT_SUMMARY_PAGE @"https://live.xbox.com:443/en-US/accounts/MyAccount.aspx"

@implementation AIAccountSummaryController

- (NSString *)notificationName
{
	return @"AIAccountSummaryLoadNotification";
}

- (void)clearTab {
	[accountName setStringValue:@""];
	[addressLine1 setStringValue:@""];
	[addressLine2 setStringValue:@""];
	[addressLine3 setStringValue:@""];
	[billingStatus setStringValue:@""];
	[membershipType setStringValue:@""];
	[membershipRenewal setStringValue:@""];
	[billingCompleteLogo setImage:nil];
}

- (void)displayAccountInfo:(NSString *)gamertag
{
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayAccountInfoThreaded) object:nil];
	[[[[NSApplication sharedApplication] delegate] operationQueue] addOperation:theOp];
}

- (void)displayAccountInfoThreaded
{	
	NSString *summarySource = [NSString stringWithContentsOfURL:[NSURL URLWithString:ACCOUNT_SUMMARY_PAGE] encoding:NSUTF8StringEncoding error:nil];
	
	NSString *tempComplete = [summarySource cropFrom:@"class=\"XbcMktBillingInfoComplete\">" to:@"</span>"];
	
	if ([tempComplete isEqualToString:@"Complete"]) {
		[billingCompleteLogo setImage:[NSImage imageNamed:@"success_checkmark"]];
		[billingStatus setStringValue:tempComplete];
	} else {
		[billingCompleteLogo setImage:[NSImage imageNamed:@"error_exclamation"]];
		[billingStatus setStringValue:@"Incomplete"];
	}
	
	NSString *tempName = [summarySource cropFrom:@"Name\" class=\"XbcMktMyAccountAddressLine\">" to:@"</span>"];
	NSString *tempALine1 = [summarySource cropFrom:@"AddressLine1\" class=\"XbcMktMyAccountAddressLine\">" to:@"</span>"];
	NSString *tempALine2 = [summarySource cropFrom:@"AddressLine2\" class=\"XbcMktMyAccountAddressLine\">" to:@"</span>"];
	NSString *tempALine3 = [summarySource cropFrom:@"AddressLine3\" class=\"XbcMktMyAccountAddressLine\">" to:@"</span>"];
	
	[accountName setStringValue:tempName];
	[addressLine1 setStringValue:tempALine1];
	[addressLine2 setStringValue:tempALine2];
	[addressLine3 setStringValue:tempALine3];
	
	NSString *tempMemLvl = [summarySource cropFrom:@"Membership Level</h2>" to:@"</p>"];
	tempMemLvl = [tempMemLvl cropFrom:@"<strong>" to:@"</strong>"];
	NSString *tempRenew = [summarySource cropFrom:@"MembershipAutoRenewalPanel\">" to:@"</div>"];
	tempRenew = [tempRenew cropFrom:@"<p>" to:@"</p>"];
	
	[membershipType setStringValue:tempMemLvl];
	[membershipRenewal setStringValue:tempRenew];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIPaneDoneLoading" object:nil];
}

@end
