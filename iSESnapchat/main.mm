//
//  main.m
//  iSESnapchat
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>
#import "opencv/cv.h"
#import "opencv/highgui.h"
int main(int argc, const char * argv[])
{
  @autoreleasepool {
  
  IplImage* img = cvCreateImage( cvSize( 640, 480 ), IPL_DEPTH_8U, 3 );
  
  cvCircle( img, cvPoint( 320, 240 ), 100, cvScalar( 255, 0, 0 , 255 ), 5, 8, 0 );
  
  cvNamedWindow( "OpenCV Window", CV_WINDOW_NORMAL );
  cvShowImage( "OpenCV Window", img );
  
  cvWaitKey(0);
  
  cvDestroyWindow( "OpenCV Window" );
  cvReleaseImage( &img );
  
  }
  return 0;
}
