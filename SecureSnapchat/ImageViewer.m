//
//  ImageViewer.m
//  SecureSnapchat
//
//  Created by John Reynolds on 12/2/13.
//
//

#import "ImageViewer.h"

@implementation ImageViewer

@synthesize imageView;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSRect rect = NSMakeRect(0, 0, 480, 480);
        imageView = [[NSImageView alloc] initWithFrame:rect];
        [imageView setImageScaling:NSScaleToFit];
        //[imageView setImage:[NSImage imageNamed:@"icon.png"]];
        [self addSubview:imageView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void) updateViewWithImage:(NSImage *)image {
    
    [imageView setImage:nil];
    [imageView setImage:image];
}

@end
