//
//  XBAccountInfoController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	OpenProgressBarPanelReturnCode = 11701,
	CloseWindowPanelReturnCode = 11702,
	ErrorPanelReturnCode = 11703,
} PanelReturnCode;

@interface XBAccountInfoController : NSObject {
	
	IBOutlet NSTextField *currentProgress;
	IBOutlet NSPanel *progressPanel;
	IBOutlet NSPanel *errorPanel;
	IBOutlet NSWindow *accountInfoWindow;
	
	IBOutlet NSProgressIndicator *spinner;
	IBOutlet NSProgressIndicator *progressPanelIndicator;
	IBOutlet NSTextField *progressPanelText;
	
	IBOutlet NSTextField *gamerscore;
	IBOutlet NSTextField *gamertag;
	IBOutlet NSTextField *motto;
	IBOutlet NSImageView *tile;
	IBOutlet NSTextField *mspoints;
	
	NSString *currentTabName;
	NSString *currentGamertag;
}

@property(copy) NSString *currentGamertag;
@property(copy) NSString *currentTabName;

- (void)changeLoadStatus:(NSNotification *)notification;
- (void)lookupAccountInfo;
- (void)openAccountInfoWindow;
- (void)lookupAccountInfoThreaded;
- (void)fetchAccountSettingsInfoThreaded;
- (void)fetchAccountSettingsInfo;

- (void)startSpinner:(NSNotification *)notification;
- (void)stopSpinner:(NSNotification *)notification;
- (void)paneDoneLoading:(NSNotification *)notification;

- (void)fullLookup;
- (void)lookupGamerInfo:(NSString *)gamertagString;

- (void)loadCurrentTab;
- (void)closeProgressPanel;
- (void)openProgressPanel;

- (void)openErrorPanel;
- (IBAction)closeErrorPanel:(id)sender;

@end
