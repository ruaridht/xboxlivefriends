//
//  AIPurchaseHistoryController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "AITabController.h"

@interface AIPurchaseHistoryController : AITabController {
	IBOutlet NSButton *gamesButton;
	IBOutlet NSButton *gameDemoButton;
	IBOutlet NSButton *videosButton;
	IBOutlet NSButton *avatarButton;
	
	IBOutlet NSPopUpButton *filterPopup;
	IBOutlet NSTextField *searchField;
	
	IBOutlet WebView *purchaseHistoryView;
	
	NSArray *purchasedItems;
	NSArray *purchasedGames;
	NSArray *purchasedDemos;
	NSArray *purchasedVideos;
	NSArray *purchasedAvatar;
	
}

- (NSArray *)consolidateAllPurchases;
- (void)displayPurchasedList;
- (void)displayPurchasedList:(NSArray *)purchased;
- (NSArray *)parsePurchaseHistoryWithURLString:(NSString *)urlString;

- (IBAction)setCurrentTab:(id)sender;
- (IBAction)refilter:(id)sender;
- (IBAction)searchGames:(id)sender;

@end
