//
//  NSImage+saveAsJpegWithName.m
//  SecureSnapchat
//
//  Created by John Reynolds on 12/1/13.
//
//

#import "NSImage+saveAsJpegWithName.h"

@implementation NSImage (saveAsJpegWithName)

- (void) saveAsJpegWithName:(NSString*) fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:YES];
}

@end
