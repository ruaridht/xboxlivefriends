//
//  StatusItemView.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 29/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StatusItemView.h"
#import "Controller.h"

@implementation StatusItemView 

- (id)initWithFrame:(NSRect)frame controller:(Controller *)ctrlr
{
    if (self = [super initWithFrame:frame]) {
        controller = ctrlr; // deliberately weak reference.
    }
    
    return self;
} 

- (void)dealloc
{
    controller = nil;
    [super dealloc];
}

- (void)drawRect:(NSRect)rect 
{	
	NSImage *image;
	
	if (clicked) {
		[[NSColor selectedMenuItemColor] set];
		NSRectFill(rect);
		image = [NSImage imageNamed:@"status_white"];
    } else {
		image = [NSImage imageNamed:@"status_black"];
	}
	
	NSSize imgSize = [image size];
	NSRect imgRect = NSMakeRect(0, 0, imgSize.width, imgSize.height);
	imgRect.origin.x = ([self frame].size.width - imgSize.width) / 2.0;
	imgRect.origin.y = ([self frame].size.height - imgSize.height) / 2.0;
	
	[image drawInRect:imgRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)mouseDown:(NSEvent *)event
{
    NSRect frame = [[self window] frame];
    NSPoint pt = NSMakePoint(NSMidX(frame), NSMinY(frame));
    [controller toggleAttachedWindowAtPoint:pt];
    clicked = !clicked;
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[controller toggleStatusMenu];
}

@end