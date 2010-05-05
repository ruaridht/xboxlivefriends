//
//  StatusItemView.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 29/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Controller;

@interface StatusItemView : NSView {
    __weak Controller *controller;
    BOOL clicked;
}

- (id)initWithFrame:(NSRect)frame controller:(Controller *)ctrlr;

@end
