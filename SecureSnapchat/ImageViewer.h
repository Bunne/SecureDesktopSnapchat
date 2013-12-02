//
//  ImageViewer.h
//  SecureSnapchat
//
//  Created by John Reynolds on 12/2/13.
//
//

#import <Cocoa/Cocoa.h>

@interface ImageViewer : NSView {
    NSImageView *imageView;
}

- (void) updateViewWithImage:(NSImage *)image;

@property (nonatomic,assign) NSImageView *imageView;
@end
