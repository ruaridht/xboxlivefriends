//
//  GamerFriendsParser.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 20/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GamerFriendsParser : NSObject {

}

+ (NSArray *)parseFriendsForTag:(NSString *)gamertag;
+ (NSArray *)friendsWithSource:(NSString *)theSource;

@end
