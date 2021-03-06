//
//  AIHaloScreenshotsController.h
//  Xbox Live Friends
//
//  Created by Ruaridh Thomson on 21/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuickLook/QuickLook.h>
#import "AITabController.h"
#import "MAAttachedWindow.h"
#import "GIHaloScreenshotsController.h"

/*
@interface MyImageObject : NSObject{
    NSString * mPath;
}

- (void) setPath:(NSString *) path;

@end
*/

@interface AIHaloScreenshotsController : AITabController {
	
    // my images to display and browse (ie my data source) 
    NSMutableArray*	_myImages;
    NSMutableArray*	myImageSSIDs;
    NSMutableArray*	myImageTitles;
    NSMutableArray*	myImageDescriptions;
	
    // my browser (connected in the nib file)
    IBOutlet id mImageBrowser;
    NSMutableArray * mImages;
	NSMutableArray * mImportedImages;
	
	
	MAAttachedWindow *infoPop;
	IBOutlet NSView *infoWindowView;
	IBOutlet NSTextField *infoPopTitle;
	IBOutlet NSTextField *infoPopDescription;
	
    IBOutlet NSTextField *counter;
	
	id* previewPanel;
	
	BOOL quickLookAvailable;
	
}

- (IBAction) quickLookButton:(id) sender;
- (void)quickLookSelectedItems;

-(void)thumbDownload:(NSDictionary *)info;
- (void) updateDatasource;
- (void)doInfoPop;
- (void)closeInfoPop;

- (IBAction) zoomed:(id) sender;
- (void) addAnImageWithPath:(NSString *) path;
- (IBAction) addImageButtonClicked:(id) sender;

@end
