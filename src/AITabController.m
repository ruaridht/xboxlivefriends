//
//  AITabController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Since all views are subclassed from here, this would be a fitting place to store parsed information.

#import "AITabController.h"
#import "Controller.h"

@implementation AITabController

@synthesize lastFetch, lastFetchTag;
@dynamic errorForTab;

- (id)init {
	if (![super init])
		return nil;
	
	[[Controller stayArounds] addObject:self];
	
	gamelistArray = nil;
	
	[self setErrorForTab:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedToLoad:) name:[self notificationName] object:nil];
	
	return self;
}

- (NSString *)notificationName {
	// Override this in your controller
	return @"AddNotificationNameHere";
}

- (BOOL)postsDoneNotificationAutomatically {
	// you may override this in your controller
	return true;
}

- (BOOL)threadedLoad {
	// you may override this in your controller
	return true;
}


- (void)notifiedToLoad:(NSNotification *)notification {
	[self tabBecameVisible];
	NSString *gamertag = [[[notification object] copy] autorelease];
	@try{
		if (![gamertag isEqual:lastFetchTag] && gamertag != nil) {
			[self setLastFetchTag:gamertag];
			[self clearErrorForTab];
			[self clearTab];
			if ([self threadedLoad]) {
				NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(tabLoadThread:) object:gamertag];
				[[[NSApp delegate] operationQueue] addOperation:theOp];	
				//[NSThread detachNewThreadSelector:@selector(tabLoadThread:) toTarget:self withObject:gamertag];
			}
			else {
				[self displayAccountInfo:gamertag];
				if ([self postsDoneNotificationAutomatically])
					[self loadingComplete];
			}
		}
		else {
			if ([self errorForTab]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRequestFailed" object:[self errorForTab]];
				return;
			}
			
			[self loadingComplete];
		}
	}
	@catch(NSException *exception) {
		NSLog(@"AITabController caught exception");
		NSLog(@"%@", [exception reason]);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRequestFailed" object:nil];
	}	
}

- (void)loadingComplete {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AIPaneDoneLoading" object:nil];
}

- (void)tabLoadThread:(NSString *)gamertag  {
	[self displayAccountInfo:gamertag];
	
	if ([self postsDoneNotificationAutomatically])
		[self loadingComplete];
}

- (NSString *)errorForTab {
    return errorForTab;
}

- (void)setErrorForTab:(NSString *)newValue {
    if (newValue != errorForTab) {
        errorForTab = [newValue copy];
		if ([self errorForTab])
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AIRequestFailed" object:[self errorForTab]];
    }
}

- (void)clearErrorForTab {
	errorForTab = nil;
}


- (void)displayAccountInfo:(NSString *)gamertag {
	
}

- (void)clearTab {
	
}

- (void)tabBecameVisible {
	
}

@end
