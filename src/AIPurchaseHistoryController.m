//
//  AIPurchaseHistoryController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AIPurchaseHistoryController.h"
#import "Xbox Live Friends.h"
#import "AITabController.h"

#define PURCHASED_GAMES_URL @"http://marketplace.xbox.com/en-US/myAccount/PurchaseHistory.aspx?phf=0&mt=0&d=0"
#define PURCHASED_DEMOS_URL @"http://marketplace.xbox.com/en-US/myAccount/PurchaseHistory.aspx?phf=1&mt=0&d=0"
#define PURCHASED_VIDEOS_URL @"http://marketplace.xbox.com/en-US/myAccount/PurchaseHistory.aspx?phf=2&mt=0&d=0"
#define PURCHASED_AVATAR_URL @"http://marketplace.xbox.com/en-US/myAccount/PurchaseHistory.aspx?phf=3&mt=0&d=0"

@implementation AIPurchaseHistoryController

- (NSString *)notificationName
{
	return @"AIPurchaseHistoryLoadNotification";
}

- (void)awakeFromNib
{
	[purchaseHistoryView setFrameLoadDelegate:self];
	[purchaseHistoryView setUIDelegate:self];
	[purchaseHistoryView setShouldCloseWithWindow:NO];
}

- (void)displayAccountInfo:(NSString *)gamertag
{
	NSLog(@"Displaying Account's Recent Purchases Info");
	
	purchasedGames = [self parsePurchaseHistoryWithURLString:PURCHASED_GAMES_URL];
	purchasedDemos = [self parsePurchaseHistoryWithURLString:PURCHASED_DEMOS_URL];
	purchasedVideos = [self parsePurchaseHistoryWithURLString:PURCHASED_VIDEOS_URL];
	purchasedAvatar = [self parsePurchaseHistoryWithURLString:PURCHASED_AVATAR_URL];

	purchasedItems = [self consolidateAllPurchases];
	
	[self displayPurchasedList:purchasedItems];
	
}

- (void)clearTab {
	[[purchaseHistoryView mainFrame] loadHTMLString:@"" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}

- (IBAction)refilter:(id)sender
{
	[self displayPurchasedList:purchasedItems];
}

- (IBAction)searchGames:(id)sender{
	[self displayPurchasedList:purchasedItems];
}

- (NSArray *)consolidateAllPurchases
{
	NSMutableArray *tempItems = [NSMutableArray array];
	
	for (NSDictionary *item in purchasedGames) {
		//NSLog(@"NAME: %@", [item objectForKey:@"name"]);
		[tempItems addObject:item];
	}
	for (NSDictionary *item in purchasedDemos) {
		//NSLog(@"NAME: %@", [item objectForKey:@"name"]);
		[tempItems addObject:item];
	}
	for (NSDictionary *item in purchasedVideos) {
		//NSLog(@"NAME: %@", [item objectForKey:@"name"]);
		[tempItems addObject:item];
	}
	for (NSDictionary *item in purchasedAvatar) {
		//NSLog(@"NAME: %@", [item objectForKey:@"name"]);
		[tempItems addObject:item];
	}
	
	return [[tempItems copy] autorelease];
}

#pragma mark -
#pragma mark WebView Methods

- (void)displayPurchasedList:(NSArray *)purchased
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *theRow = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/purchased_list_row.html"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/purchased_list_body.html"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *allRows = @"<!-- something something -->";
	
	
	NSMutableString *currentEditRow;
	
	BOOL showsError = NO;
	//int usableGames = 0;
	
	int popupTag = [[filterPopup selectedItem] tag];
	
	if([purchased count] != 0){
		int i = 0;
		for (NSDictionary *item in purchased){
			BOOL shouldDisplayThisGame = YES;
			@try{
				currentEditRow = [theRow mutableCopy];
				
				/*
				 if (thisGame.isJustMe) {
				 //[self setErrorForTab:@"Cannot View Your Own Achievements"];
				 [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AIShowErrorTab" object:@"Cannot View Your Own Achievements"]];
				 return;
				 }
				 */
				/*
				 NSString *rowEvenness;
				 if (usableGames % 2 == 1) {
				 rowEvenness = @"odd";
				 }
				 else {
				 rowEvenness = @"even";
				 }
				 [currentEditRow replaceOccurrencesOfString:@"$even_or_odd" withString:rowEvenness options:0 range:NSMakeRange(0, [currentEditRow length])];
				 */
				
				[currentEditRow replaceOccurrencesOfString:@"%name%" withString:[item objectForKey:@"name"] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				[currentEditRow replaceOccurrencesOfString:@"%date%" withString:[item objectForKey:@"date"] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				[currentEditRow replaceOccurrencesOfString:@"%type%" withString:[item objectForKey:@"type"] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				shouldDisplayThisGame = YES;
				
				NSString *purchasedType = [item objectForKey:@"type"];
				
				if (popupTag == 1) {
					if (![purchasedType isEqualToString:@"Demo"] & ![purchasedType isEqualToString:@"Avatar Items"])
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				} else if (popupTag == 2) {
					if ([purchasedType isEqualToString:@"Demo"])
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				} else if (popupTag == 3) {
					if ([purchasedType isEqualToString:@"Video"])
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				} else if (popupTag == 4) {
					if ([purchasedType isEqualToString:@"Avatar Items"])
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				
				//filter games list in accordance with search string
				if ([[searchField stringValue] length] > 0 && [[item objectForKey:@"name"] rangeOfString:[searchField stringValue] options:NSCaseInsensitiveSearch].location == NSNotFound) {
					shouldDisplayThisGame = NO;
				}
				
				if(shouldDisplayThisGame){
					allRows = [NSString stringWithFormat:@"%@%@", allRows, currentEditRow];
					//usableGames = usableGames + 1;
				}
				
				[currentEditRow release];
			}
			@catch (NSException *exception){
				//				NSLog([exception name]);
				//				NSLog([exception reason]);
				
			}
			i++;
		}
	}
	else
		showsError = YES;
	/*
	 if (usableGames == 0)
	 showsError = YES;
	 */
	/*
	 if (showsError){
	 NSMutableString *errorMut = [[[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/simple_error_message.htm"] encoding:NSMacOSRomanStringEncoding error:NULL] mutableCopy] autorelease];
	 
	 if (popupTag == 0 && [[searchField stringValue] length] == 0) {
	 [errorMut replaceOccurrencesOfString:@"$title" withString:@"Gamertag Not Found" options:0 range:NSMakeRange(0, [errorMut length])];
	 }
	 else {
	 [errorMut replaceOccurrencesOfString:@"$title" withString:@"No Matches" options:0 range:NSMakeRange(0, [errorMut length])];
	 }
	 [errorMut replaceOccurrencesOfString:@"$subtitle" withString:@"" options:0 range:NSMakeRange(0, [errorMut length])];
	 theBody = [[errorMut copy] autorelease];
	 }
	 */
	
	NSMutableString *theBodyMut = [[theBody mutableCopy] autorelease];
	
	//[theBodyMut replaceOccurrencesOfString:@"$their_tag" withString:gamertag options:0 range:NSMakeRange(0, [theBodyMut length])];
	[theBodyMut replaceOccurrencesOfString:@"%items%" withString:allRows options:0 range:NSMakeRange(0, [theBodyMut length])];
	
	[[purchaseHistoryView mainFrame] loadHTMLString:theBodyMut baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];

	[pool drain];
}

#pragma mark -
#pragma mark Parsing Methods

- (NSArray *)parsePurchaseHistoryWithURLString:(NSString *)urlString
{
	NSString *theSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
	NSString *historySource = [theSource cropFrom:@"<div class=\"XbcMktPurchaseHistoryThinNavBar\">" to:@"</table><div class=\"XbcMktPurchaseHistoryThinNavBar\">"];
	
	NSString *numOfItems = [historySource cropFrom:@" of " to:@" items"];
	//NSLog(@"Number Of Purchases: %@", numOfItems);
	
	int numOfItemsInt = [numOfItems intValue];
	numOfItemsInt -= 20;
	
	
	int pageIndex = 1;
	NSString *thisSource;
	while (numOfItemsInt > 0) {
		pageIndex++;
		numOfItemsInt -= 20;
		thisSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&p=%i", urlString, pageIndex]] encoding:NSUTF8StringEncoding error:nil];
		thisSource = [thisSource cropFrom:@"<div class=\"XbcMktPurchaseHistoryThinNavBar\">" to:@"</table><div class=\"XbcMktPurchaseHistoryThinNavBar\">"];
		historySource = [historySource stringByAppendingString:thisSource];
	}
	
	NSArray *rows = [historySource cropRowsMatching:@"<td class=\"Name\">" rowEnd:@"><div class=\"XbcMktSilverButtonRight\""];
	
	NSMutableArray *purchasesArray = [NSMutableArray array];
	
	for (NSString *row in rows) {
		
		//NSLog(@"Row ---------------------");
		NSMutableDictionary *record = [NSMutableDictionary dictionary];
		
		NSString *tempName = [row cropFrom:@"<a href=" to:@"/a>"];
		tempName = [tempName cropFrom:@">" to:@"<"];
		//NSLog(@"BOUGHT: %@", tempName);
		
		NSString *tempURL = [row cropFrom:@"<a href=\"" to:@"\""];
		NSString *tempDate = [row cropFrom:@"\"PurchaseDate\">" to:@"</td>"];
		
		NSString *tempType = [row cropFrom:@"\"ContentType\">" to:@"</td>"];
		
		[record setObject:tempName forKey:@"name"];
		[record setObject:tempURL forKey:@"url"];
		[record setObject:tempDate forKey:@"date"];
		[record setObject:tempType forKey:@"type"];
		
		[purchasesArray addObject:record];
	}
	
	return [[purchasesArray	copy] autorelease];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)setCurrentTab:(id)sender
{
	if ([sender tag] == 1) {
		[gamesButton setState:NSOnState];
		[gameDemoButton setState:NSOffState];
		[videosButton setState:NSOffState];
		[avatarButton setState:NSOffState];
	}
	if ([sender tag] == 2) {
		[gamesButton setState:NSOffState];
		[gameDemoButton setState:NSOnState];
		[videosButton setState:NSOffState];
		[avatarButton setState:NSOffState];
	}
	if ([sender tag] == 3) {
		[gamesButton setState:NSOffState];
		[gameDemoButton setState:NSOffState];
		[videosButton setState:NSOnState];
		[avatarButton setState:NSOffState];
	}
	if ([sender tag] == 4) {
		[gamesButton setState:NSOffState];
		[gameDemoButton setState:NSOffState];
		[videosButton setState:NSOffState];
		[avatarButton setState:NSOnState];
	}
}

@end
