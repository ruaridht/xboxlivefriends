//
//  AIAchievementsController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "AITabController.h" 

@interface AIAchievementsController : AITabController {
	IBOutlet WebView *comparisonWebView;
	IBOutlet NSPopUpButton *filterPopup;
	IBOutlet NSTextField *searchField;
	
	NSArray *gamesPlayed;
}

- (IBAction)refilter:(id)sender;
- (IBAction)searchGames:(id)sender;

- (void)displayGamesPlayed:(NSArray *)gamesList forGamertag:(NSString *)gamertag;

- (float)percentCompletedFromString:(NSString *)blankOfBlank;
- (NSString *)completedPointsFromString:(NSString *)blankOfBlank;
- (NSString *)totalPointsFromString:(NSString *)blankOfBlank;
- (NSString *)checkmark:(BOOL)x;

@end
