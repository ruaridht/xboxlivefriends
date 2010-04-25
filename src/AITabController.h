//
//  AITabController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AITabController : NSObject {
	id lastFetch;
	NSString *lastFetchTag;
	NSString *errorForTab;
	
	NSArray *gamelistArray;
}

@property(copy) NSString *lastFetchTag;
@property(copy) NSString *errorForTab;
@property(copy) id lastFetch;

- (void)clearErrorForTab;

- (NSString *)notificationName;
- (BOOL)postsDoneNotificationAutomatically;
- (BOOL)threadedLoad;
- (void)loadingComplete;
- (void)displayAccountInfo:(NSString *)gamertag;
- (void)clearTab;
- (void)tabBecameVisible;

@end
