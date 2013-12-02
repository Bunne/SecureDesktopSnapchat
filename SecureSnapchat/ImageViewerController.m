//
//  ImageViewerController.m
//  SecureSnapchat
//
//  Created by John Reynolds on 12/2/13.
//
//

#import "ImageViewerController.h"
#import "ImageViewer.h"

@interface ImageViewerController ()

@end

@implementation ImageViewerController

@synthesize viewer;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) setContent:(NSImage *)content {
    [viewer updateViewWithImage:content];
}
@end
