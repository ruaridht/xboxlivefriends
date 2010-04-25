//
//  Profile Editor.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 24/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProfileEditor : NSObject {
	
	IBOutlet NSPanel *editPanel;
	
	IBOutlet NSTextField *editName;
	IBOutlet NSTextField *editMotto;
	IBOutlet NSTextField *editBio;
	IBOutlet NSTextField *editLocation;
	
	IBOutlet NSButton *saveButton;
	IBOutlet NSButton *cancelButton;
	
	NSString *prevName;
	NSString *prevMotto;
	NSString *prevBio;
	NSString *prevLocation;
}

- (void)fetchCurrentProfileInfo;

- (IBAction)openEditProfile:(id)sender;
- (IBAction)saveEditedProfile:(id)sender;
- (IBAction)cancelEditProfile:(id)sender;

@end
