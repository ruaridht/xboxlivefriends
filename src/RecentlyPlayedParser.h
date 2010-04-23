//
//  RecentlyPlayedParser.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 23/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RecentlyPlayedParser : NSObject {

}

+ (NSArray *)parseRecent;
+ (NSArray *)parseRecentWithSource:(NSString *)theSource;

@end
