//
//  NSTextFieldFormatter.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 28/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Xbox Live Friends.h"

@interface NSTextFieldFormatter : NSFormatter {
	int maxLength;
}
- (void)setMaximumLength:(int)len;
- (int)maximumLength;

@end
