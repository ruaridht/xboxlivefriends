//
//  NSTextFieldFormatter.m
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 28/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSTextFieldFormatter.h"
#import "Xbox Live Friends.h"

@implementation NSTextFieldFormatter

- init {
	[super init];
	maxLength = INT_MAX;
	return self;
}

- (void)setMaximumLength:(int)len {
	maxLength = len;
}

- (int)maximumLength {
	return maxLength;
}

- (NSString *)stringForObjectValue:(id)object {
	return (NSString *)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error {
	*object = string;
	return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error {
	if ([partialString length] > maxLength) {
		*newString = nil;
		return NO;
	}
	
	*newString = partialString;
	return [*newString isEqual:partialString];
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
	return nil;
}

@end
