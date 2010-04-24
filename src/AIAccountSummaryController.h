//
//  AIAccountSummaryController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 24/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AITabController.h"

@interface AIAccountSummaryController : AITabController {
	// Contact Info
	IBOutlet NSTextField *accountName;
	IBOutlet NSTextField *addressLine1;
	IBOutlet NSTextField *addressLine2;
	IBOutlet NSTextField *addressLine3;
	
	// Billing Status
	BOOL billingInfoComplete;
	IBOutlet NSTextField *billingStatus;
	IBOutlet NSImageView *billingCompleteLogo;
	
	// Membership Level
	IBOutlet NSTextField *membershipType;
	IBOutlet NSTextField *membershipRenewal;
}

- (void)displayAccountInfoThreaded;

@end
