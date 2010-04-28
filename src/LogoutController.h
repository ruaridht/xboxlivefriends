//
//  LogoutController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 27/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface LogoutController : NSObject {
	IBOutlet NSWindow *signOutnWindow;
	IBOutlet WebView *signOutWebView;
}

- (IBAction)logoutButtonClicked:(id)sender;
- (void)logoutOfPassport;
- (void)loadBlankPage;

@end
