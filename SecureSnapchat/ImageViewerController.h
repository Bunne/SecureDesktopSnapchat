//
//  ImageViewerController.h
//  SecureSnapchat
//
//  Created by John Reynolds on 12/2/13.
//
//

#import <Cocoa/Cocoa.h>

@class ImageViewer;

@interface ImageViewerController : NSWindowController {
    IBOutlet ImageViewer *viewer;
}

@property (nonatomic, assign) IBOutlet ImageViewer *viewer;

- (void) setContent:(NSImage *)content;
@end
