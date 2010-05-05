//
//  Controller.h
//  Xbox Live Friends
//
//  i trip blind kids, what's your anti-drug?
// 
//  © 2006 mindquirk
//  

#import <Cocoa/Cocoa.h>
#import "StayAround.h"
#import "MAAttachedWindow.h"

@interface Controller : NSObject {

	//misc
	IBOutlet NSTextView *sourceLogger;
	NSTimer *refreshTimer;
	IBOutlet NSButton *autoRefresh;
	IBOutlet NSTextField *refreshTime;

	BOOL isRegistered;
	NSOperationQueue *queue;
	
	IBOutlet NSMenuItem *debugMenu;
	
	// Status menu stuff
	NSStatusItem *statusItem;
    MAAttachedWindow *statusAttWindow;
    
    IBOutlet NSView *statusView;
    IBOutlet NSTableView *statusFriendsOnline;
	NSMutableArray *tableViewItems;
	NSArray *onlineFriends;
	
	IBOutlet NSTextField *myTag;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *statusMenuFriends;
	IBOutlet NSMenuItem *statusMenuMessages;
	IBOutlet NSMenuItem *statusMenuStatus;
}

+ (StayAround *)stayArounds;

- (NSOperationQueue *)operationQueue;
- (void)timedRefresh;
- (void)startRefreshTimer;
- (IBAction)toggleRefreshTimer:(id)sender;
- (IBAction)changeRefreshTime:(id)sender;

- (void)toggleAttachedWindowAtPoint:(NSPoint)pt;
- (void)toggleStatusMenu;

@end
