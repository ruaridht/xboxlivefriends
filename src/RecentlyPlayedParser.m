//
//  RecentlyPlayedParser.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 23/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RecentlyPlayedParser.h"
#import "Xbox Live Friends.h"

#define RECENTLY_PLAYED_PAGE @"http://live.xbox.com/en-US/profile/RecentPlayers/RecentPlayers.aspx"
#define STATUS_NEW_LINE_REPLACEMENT @" - "

@implementation RecentlyPlayedParser

+ (NSArray *)parseRecent
{	
	NSArray *gamerArray;
	
	NSString *theSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:RECENTLY_PLAYED_PAGE] encoding:NSUTF8StringEncoding error:nil];
	
	if (!theSource) {
		NSLog(@"Recently played page not reached.");
		return nil;
	}
	
	gamerArray = [self parseRecentWithSource:theSource];
	
	if ([gamerArray count] == 0) {
		NSLog(@"No players in recently played.");
		return nil;
	}
	
	return gamerArray;
}

+ (NSArray *)parseRecentWithSource:(NSString *)theSource
{
	NSMutableArray *gamers = [[NSMutableArray alloc] init];
	
	
	NSArray *rows = [theSource cropRowsMatching:@"<tr id=\"" rowEnd:@"</tr>"];
	
	for (NSString *row in rows) {
		
		if (![row contains:@"GamerTag="]) {
			continue;
		}
		
		NSString *gamertag = [row cropFrom:@"GamerTag=" to:@"\""];
		gamertag = [gamertag replace:@"+" with:@" "];
		
		NSString *gamertileURL = [row cropFrom:@"GamerTileImage\" src=\"" to:@"\""];
		if ([gamertileURL contains:@"QuestionMark32x32.jpg"]) {
			gamertileURL = @"http://live.xbox.com/xweb/lib/images/QuestionMark32x32.jpg";
		}
		
		/*
		NSString *status = [row cropFrom:@"headers=\"Status\">" to:@"</td>"];
		status = [status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		 */
		NSString *status = @"Online";
		
		NSString *richPresence = [row cropFrom:@"class=\"XbcGameTitle\" headers=\"GameTile\">" to:@"</td>"];
		richPresence = [richPresence replace:@"&nbsp;" with:@" "];
		richPresence = [richPresence replace:@"<br />" with:@"\n"];
		richPresence = [richPresence replace:@"<br>" with:@"\n"];
		richPresence = [richPresence replace:@"\r\n" with:@"\n"];
		richPresence = [richPresence replace:@"\r" with:@"\n"];
		richPresence = [richPresence replace:@"Playing " with:@""];
		if ([richPresence contains:@"Last seen "]) {
			richPresence = [richPresence replace:@"Last seen " with:@""];
			richPresence = [richPresence replace:@" playing " with:@"\n"];
		}
		richPresence = [richPresence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		richPresence = [richPresence replace:@"\n" with:STATUS_NEW_LINE_REPLACEMENT];
		richPresence = [richPresence replace:@"   " with:@" "];
		
		NSString *theZone = [row cropFrom:@"headers=\"GamerZone\">" to:@"</td>"];
		theZone = [MQFunctions flattenHTML:theZone];
		
		XBFriend *theGamer = [XBFriend friendWithTag:gamertag tileURLString:gamertileURL statusString:status infoString:richPresence];
		
		[theGamer setZone:theZone];
		
		[gamers addObject:theGamer];
	}
	
	return [gamers copy];
}

@end
