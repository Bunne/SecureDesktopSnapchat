#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>

@class ImageViewerController;

@interface MyController: NSWindowController
{
    @private
	IBOutlet NSImageView *	imageView;
    IBOutlet ImageViewerController *imageViewer;
}


@end