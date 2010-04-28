//
//  LogoutController.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 27/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LogoutController.h"
#import "Xbox Live Friends.h"
#import "LoginController.h"

#define SIGN_OUT_URL @"http://login.live.com/logout.srf?ct=1271868636&rver=5.5.4177.0&lc=1033&id=66262&ru=about:blank&lru=about%3ablank"

@implementation LogoutController

- (id)init {
	
	if (![super init]) {
		return nil;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutOfPassport) name:@"LogOutOfLive" object:nil];
	
	return self;
}

- (void)awakeFromNib
{
	[signOutWebView setFrameLoadDelegate:self];
}

- (IBAction)logoutButtonClicked:(id)sender
{
	NSLog(@"Loggin out of live");
	[[signOutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SIGN_OUT_URL]]];
}

- (void)logoutOfPassport
{
	NSLog(@"Loggin out of live");
	[[signOutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SIGN_OUT_URL]]];
}

- (void)loadBlankPage
{
	NSLog(@"Setting logout webview blank");
	[[signOutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

#pragma mark -
#pragma mark WebView Methods

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
	
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	NSString *currentPage = [signOutWebView mainFrameURL];
	NSLog(@"%@", currentPage);
	
	if ([currentPage rangeOfString:@"www.xbox.com"].location != NSNotFound) {
		[[signOutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DoSignIn" object:nil];
	}
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	
}

- (void)webViewLoadingChange:(NSNotification *)aNotification {
	
}


- (void)webViewWithRequest:(NSURLRequest *)request
{
	[[signOutWebView mainFrame] loadRequest:request];
}

@end
