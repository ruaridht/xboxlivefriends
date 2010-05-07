//
//  AIAccountDetailsController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AITabController.h"
#import "XBReputationView.h"

@interface AIAccountDetailsController : AITabController {
	IBOutlet NSTextField *name;
	IBOutlet NSTextField *location;
	IBOutlet NSTextField *bio;
	IBOutlet NSTextField *zone;
	IBOutlet NSImageView *avatar;
	IBOutlet NSImageView *repStars;
	
	IBOutlet XBReputationView *reputation;
}

- (IBAction)reloadAccountDetails:(id)sender;

@end
