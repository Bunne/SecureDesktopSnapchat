#import "MyController.h"
#import "SelectFiles.h"
#import "AddPeople.h"
#import "NotificationDelegate.h"
#include <CoreServices/CoreServices.h>
#import "NSImage+saveAsJpegWithName.h"


@implementation MyController

/* ADDING CONTACT
    Allows the user to select a .public key to add to their contacts list
*/
- (IBAction) addContact:(id)sender
{
    AddPeople *delegateSelf = [[AddPeople alloc]init];
    
    NSString *conts = [NSHomeDirectory() stringByAppendingString:@"/.snap/contacts/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setDirectory:NSHomeDirectory()];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setDelegate:delegateSelf];
    [openPanel allowsMultipleSelection];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"pub", nil]];
    
    if ( [openPanel runModal] == NSOKButton )
    {
        NSArray* files = [openPanel filenames];
        for( int i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];
            NSString* fn = [conts stringByAppendingString:[fileName lastPathComponent]];
            //            printf("%s\n", [fileName UTF8String]);
            //            printf("%s\n", [fn UTF8String]);
            if ([fileManager moveItemAtPath:fileName
                                     toPath:fn  error:NULL]) {
                //                printf("Copied successfully\n");
            }
        }
    }
}


/* SHARING CONTACT
 Copies the user's public key to the desktop.
 */
- (IBAction) shareContact:(id)sender{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NotificationDelegate *delegateSelf = [[NotificationDelegate alloc]init];
    NSString *ourKey = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pub"];
    NSString *toHome = [NSHomeDirectory() stringByAppendingString:@"/Desktop/"];
    NSString *prompt = @"Please enter your contact name:";
    NSString *defaultValue = @"";
    
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"Save"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"Enter the name you wish your contact to recognize you by."];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];

        NSString *contactName = [[input stringValue] stringByAppendingString:@".pub"];
        NSString *copyTo = [toHome stringByAppendingString:contactName];

        if ([fileManager copyItemAtPath:ourKey toPath:copyTo error:nil]){
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:delegateSelf];
            notification.title = @"Contact Copied!";
            notification.informativeText = [NSString stringWithFormat:@"%@ copied to Desktop.", contactName];
            notification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }


    } else if (button == NSAlertAlternateReturn) {
//        NSLog(@"User cancelled");
    } else {
//        NSLog(@"bla");
    }
    
    
    
}

/* Launch Picture Taker
    Sets up and initializes the picture taker
*/
- (IBAction) launchPictureTaker:(id)sender
{
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    
	[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerShowEffectsKey];
    
	[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerAllowsFileChoosingKey];
	[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerShowRecentPictureKey];
	[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerUpdateRecentPictureKey];
	[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerAllowsEditingKey];
	[pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(1000,1000)] forKey:IKPictureTakerOutputImageMaxSizeKey];
    
    [pictureTaker beginPictureTakerSheetForWindow:[imageView window] withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
}

#pragma mark -
#pragma mark delegate

/* PROCESSING TAKEN IMAGE
    Allow the user to select a public key from their contacts list to send the taken image to.
    The image is then encrypted and sent.
*/
- (void) pictureTakerValidated:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf
{
    if(returnCode == NSOKButton){
		/* retrieve the output image */
        NSImage *outputImage = [pictureTaker outputImage];
        
        // Handle contact selection
        SelectFiles *delegateSelf = [[SelectFiles alloc]init];
        NSString *urlstring = [NSString stringWithFormat:@"."];
        NSURL *url = [NSURL URLWithString:urlstring];
        
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setDirectoryURL:url];
        [openPanel setCanChooseDirectories:NO];
        [openPanel setDelegate:delegateSelf];
        [openPanel allowsMultipleSelection];
        [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"pub", nil]];
        if ( [openPanel runModal] == NSOKButton )
        {
            NSArray* files = [openPanel filenames];
            for( int i = 0; i < [files count]; i++ )
            {
                NSString* fileName = [files objectAtIndex:i];
                // ENCRYPT AND SEND
                
                //Make a random temp file name
                char data[20];
                for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
                
                NSString *fileNameBase = [[NSHomeDirectory() stringByAppendingString:@"/.snap/enclave/"]
                                          stringByAppendingString:[[NSString alloc] initWithBytes:data
                                                                                           length:20
                                                                                         encoding:NSUTF8StringEncoding]];
                //file names for clear and encrypted files
                NSString *jpegfileName = [fileNameBase stringByAppendingString:@".snaptmp"];
                NSString *jpegfileName_enc = [fileNameBase stringByAppendingString:@".snaptmpenc"];
                NSString *keyfileName = [fileNameBase stringByAppendingString:@".snapkey"];
                NSString *keyfileName_enc = [fileNameBase stringByAppendingString:@".snapkeyenc"];
                
                //make a "secure" key, write it to a file ----^
                for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
                [[[NSString alloc] initWithBytes:data
                                          length:20
                                        encoding:NSUTF8StringEncoding] writeToFile:keyfileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                //save the image to disk as a jpeg
                [outputImage saveAsJpegWithName:jpegfileName];
                
                //encrypt the picture with the key file
                NSString *sslPath = @"/usr/bin/openssl";
                
                //openssl enc -aes-256-cbc -in plain.txt -out encrypted.bin
                NSArray *encryptJpegWithSymetricKeyArgs = [NSArray arrayWithObjects:@"enc",
                                                           @"-aes-256-cbc",
                                                           @"-in", jpegfileName,
                                                           @"-out", jpegfileName_enc,
                                                           @"-pass", [@"file:" stringByAppendingString:keyfileName],nil];
                
                //encrypt the
                
                
                //example...
//                NSString *passInCommand = [@"-passin pass:" stringByAppendingString:pass];
//                NSString *path = @"/usr/bin/openssl";
//                NSArray *args = [NSArray arrayWithObjects:
//                                 @"genrsa",
//                                 @"-aes128",
//                                 passOutCommand,
//                                 @"-out me.pem",
//                                 @"2048", nil];
//                [[NSTask launchedTaskWithLaunchPath:path arguments:args] waitUntilExit];
                
                
                
                //We don't care about signing...
//                NSString *prompt = @"Please enter your password...";
//                NSString *defaultValue = @"";
//                
//                NSAlert *alert = [NSAlert alertWithMessageText: prompt
//                                                 defaultButton:@"Send"
//                                               alternateButton:@"Cancel"
//                                                   otherButton:nil
//                                     informativeTextWithFormat:@"Please enter your password..."];
//                
//                NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
//                [input setStringValue:defaultValue];
//                [alert setAccessoryView:input];
//                NSInteger button = [alert runModal];
//                
//                // affirmative closing ("ok")
//                if (button == NSAlertDefaultReturn) {
//                    [input validateEditing];
//                    
//                    
//                    
////                    NSString *contactName = [[input stringValue] stringByAppendingString:@".pub"];
////                    NSString *copyTo = [toHome stringByAppendingString:contactName];
////                    
////                    if ([fileManager copyItemAtPath:ourKey toPath:copyTo error:nil]){
////                        NSUserNotification *notification = [[NSUserNotification alloc] init];
////                        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:delegateSelf];
////                        notification.title = @"Contact Copied!";
////                        notification.informativeText = [NSString stringWithFormat:@"%@ copied to Desktop.", contactName];
////                        notification.soundName = NSUserNotificationDefaultSoundName;
////                        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
////                    }
//                    
//                    
//                } else if (button == NSAlertAlternateReturn) {
//                    //        NSLog(@"User cancelled");
//                } else {
//                    //        NSLog(@"HUH?");
//                }
                
            }
        }
    }
	else{
		/* Process Canceled */
	}
    
    
}

/* OPEN .SNAP FILE
    Allows us to open a valid .snap file addressed to us.
*/
- (IBAction) openSnap:(id)sender
{
////////////////////////////////////////////////////////////////////////////////
   
    /* Define variables and create a CFArray object containing
     CFString objects containing paths to watch.
     */
    CFStringRef mypath = (__bridge CFStringRef)NSHomeDirectory();
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    FSEventStreamContext cntxt = {0};
    cntxt.info = self;
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 3.0; /* Latency in seconds */
    /* Create the stream, passing in a callback */
    stream = FSEventStreamCreate(NULL,
                                 &feCallback,
                                 &cntxt,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow,
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    
////////////////////////////////////////////////////////////////////////////////
    
    NSString *ourKey = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pem"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setDirectory:NSHomeDirectory()];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"snap", nil]];
    
    if ( [openPanel runModal] == NSOKButton )
    {
        NSArray* files = [openPanel filenames];
        for( int i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];
            // DECRYPT AND SHOW
            
            
        }
    }

////////////////////////////////////////////////////////////////////////////////
    FSEventStreamStop(stream);
    FSEventStreamInvalidate(stream);
    FSEventStreamRelease(stream);
}

static void feCallback(ConstFSEventStreamRef streamRef, void* pClientCallBackInfo,
                       size_t numEvents, void* pEventPaths, const    FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])

{
    char** ppPaths = (char**)pEventPaths; int i;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *file_ext = [NSArray arrayWithObjects:@"jpeg", @"jpg", @"fleck",@"png", @"tiff", @"gif",@"psd", nil];
    for (i = 0; i < numEvents; i++)
    {
        NSString * this_path = [NSString stringWithFormat:@"%s",ppPaths[i]];
        if([file_ext containsObject:[[this_path lastPathComponent] pathExtension]]){
            //printf("Path changed: %s\n", ppPaths[i]);
            [fileManager removeItemAtPath:this_path error:nil];
        }
    }
}
@end
