#import "MyController.h"
#import "SelectFiles.h"
#import "AddPeople.h"
#import "NotificationDelegate.h"
#include <CoreServices/CoreServices.h>
#import "NSImage+saveAsJpegWithName.h"
#import "ImageViewerController.h"

@implementation MyController


/* FORGOT PASSWORD
    Clear keys, generate new ones.
 */
- (IBAction)forgotPassword:(id)sender
{
    
    NSString *prompt = @"Reset Password?";
    NSAlert *alert = [NSAlert alertWithMessageText:prompt
                            defaultButton:@"Yes"
                          alternateButton:@"Cancel"
                              otherButton:nil
                informativeTextWithFormat:@"Doing so will delete your current contact information and restart Secure Snapchat. You will not be able to open received .snap files created using this contact information.\nUpon restart, you will be prompted for a new password. To continue using Secure Snapchat, send your new .pub file to your contacts."];
    
    NSInteger button = [alert runModal];
    
    // affirmative closing ("ok")
    if (button == NSAlertDefaultReturn) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *file_pem = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pem"];
        NSString *file_pem_pub = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pub"];
        if([fileManager removeItemAtPath:file_pem error:nil] and
           [fileManager removeItemAtPath:file_pem_pub error:nil]){
            printf("Deleted %s \n", [file_pem UTF8String]);
            printf("Deleted %s \n", [file_pem_pub UTF8String]);
        }
        NSAlert *reset_alert = [[NSAlert alloc] init];
        [reset_alert addButtonWithTitle:@"OK"];
        [reset_alert setMessageText:@"Exiting Program"];
        [reset_alert setAlertStyle:NSWarningAlertStyle];
        if ([reset_alert runModal] == NSAlertFirstButtonReturn) {
            // OK clicked, delete the record
            exit(1);
        }
    } else if (button == NSAlertAlternateReturn) {
        //        NSLog(@"User cancelled");
    } else {
        //        NSLog(@"HUH?");
    }


}

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
                NSString *finalfileName = [fileNameBase stringByAppendingString:@".snap"];
                NSString *toHome = [NSHomeDirectory() stringByAppendingString:@"/Desktop/"];
                toHome = [toHome stringByAppendingString:[[[NSString alloc] initWithBytes:data
                                                                                   length:20
                                                                                 encoding:NSUTF8StringEncoding] stringByAppendingString:@".snap"]];

                //make a "secure" key, write it to a file ----^
                char data2[20];
                for (int x=0;x<20;data2[x++] = (char)('A' + (arc4random_uniform(26))));
                [[[NSString alloc] initWithBytes:data2
                                          length:20
                                        encoding:NSUTF8StringEncoding] writeToFile:keyfileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                //save the image to disk as a jpeg
                [outputImage saveAsJpegWithName:jpegfileName];
                
                //encrypt the picture with the key file
                NSString *sslPath = @"/usr/bin/openssl";
                
                //$openssl enc -aes-256-cbc -in plain.txt -out encrypted.bin
                NSArray *encryptJpegWithSymetricKeyArgs = [NSArray arrayWithObjects:@"enc",
                                                           @"-aes-256-cbc",
                                                           @"-in", jpegfileName,
                                                           @"-out", jpegfileName_enc,
                                                           @"-pass", [@"file:" stringByAppendingString:keyfileName],nil];
                
                [[NSTask launchedTaskWithLaunchPath:sslPath arguments:encryptJpegWithSymetricKeyArgs] waitUntilExit];
                
                //encrypt the symmetric key with the public key of the recipient
                //$openssl rsautl -encrypt -in <input_file> -inkey <llave> -out <output_file>
                NSArray *encryptSymetricKeyArgs = [NSArray arrayWithObjects:@"rsautl",
                                                   @"-encrypt",
                                                   @"-in", keyfileName,
                                                   @"-pubin",
                                                   @"-inkey", fileName,
                                                   @"-out", keyfileName_enc, nil];
                
                [[NSTask launchedTaskWithLaunchPath:sslPath arguments:encryptSymetricKeyArgs] waitUntilExit];
                
                
                //change working directory
                NSFileManager *filemgr;
                NSString *currentpath;
                filemgr = [NSFileManager defaultManager];
                currentpath = [filemgr currentDirectoryPath];
                if ([filemgr changeCurrentDirectoryPath: [NSHomeDirectory() stringByAppendingString:@"/.snap/enclave/"]] == NO)
                    NSLog (@"Cannot change directory.");
                
                
                //zip the encrypted symmetric key and the encrypted image into a .snap file
                NSString *zipPath = @"/usr/bin/zip";
                NSString *specialjpeg = [[[NSString alloc] initWithBytes:data
                                                                 length:20
                                                               encoding:NSUTF8StringEncoding] stringByAppendingString:@".snaptmpenc"];
                NSString *specialkey = [[[NSString alloc] initWithBytes:data
                                                                  length:20
                                                                encoding:NSUTF8StringEncoding] stringByAppendingString:@".snapkeyenc"];
                NSArray *zipArgs = [NSArray arrayWithObjects:finalfileName,
                                    specialjpeg,
                                    specialkey, nil];
                [[NSTask launchedTaskWithLaunchPath:zipPath arguments:zipArgs] waitUntilExit];
                [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"icon.png"] forFile:finalfileName options:0];
                
                //change back
                if ([filemgr changeCurrentDirectoryPath: currentpath] == NO)
                    NSLog (@"Cannot change directory.");
                     
                //delete the originals
                NSString *rmPath = @"/bin/rm";
                NSArray *rmArgs = [NSArray arrayWithObjects:jpegfileName, jpegfileName_enc, keyfileName, keyfileName_enc, nil];
                [[NSTask launchedTaskWithLaunchPath:rmPath arguments:rmArgs] waitUntilExit];
                [filemgr moveItemAtPath:finalfileName toPath:toHome error:nil];
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
    CFAbsoluteTime latency = 1.0; /* Latency in seconds */
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
    
    NSString *ourPriv = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pem"];
    NSString *ourPub = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pub"];
    NSString *enclave = [NSHomeDirectory() stringByAppendingString:@"/.snap/enclave/"];
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
            NSString* theSnapFileName = [[fileName lastPathComponent] stringByDeletingPathExtension];
            NSString* SnapFileKey = [enclave stringByAppendingString:[theSnapFileName stringByAppendingString:@".snapkeyenc"]];
            NSString* SnapFileTmp = [enclave stringByAppendingString:[theSnapFileName stringByAppendingString:@".snaptmpenc"]];
            
            [fileManager moveItemAtPath:fileName toPath:[enclave stringByAppendingString:[theSnapFileName stringByAppendingString:@".snap"]] error:nil];
            fileName = [enclave stringByAppendingString:[theSnapFileName stringByAppendingString:@".snap"]];
            // DECRYPT AND SHOW
            NSString *unzipPath = @"/usr/bin/unzip";
            
            //change working directory
            NSFileManager *filemgr;
            NSString *currentpath;
            filemgr = [NSFileManager defaultManager];
            currentpath = [filemgr currentDirectoryPath];
            if ([filemgr changeCurrentDirectoryPath: [NSHomeDirectory() stringByAppendingString:@"/.snap/enclave/"]] == NO)
                NSLog (@"Cannot change directory.");
            
            NSArray *zipargs = [NSArray arrayWithObjects: fileName,
                                //@"*.snap*",
                                //@"-d", enclave,
                                nil];
            [[NSTask launchedTaskWithLaunchPath:unzipPath arguments:zipargs] waitUntilExit];
            [fileManager removeItemAtPath:fileName error:nil];
            
            //change back
            if ([filemgr changeCurrentDirectoryPath: currentpath] == NO)
                NSLog (@"Cannot change directory.");
            
            //Make a random Canary file
            char data[20];
            for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
            NSString *fileNameBase = [[NSHomeDirectory() stringByAppendingString:@"/.snap/enclave/"]
                                      stringByAppendingString:[[NSString alloc] initWithBytes:data
                                                                                       length:20
                                                                                     encoding:NSUTF8StringEncoding]];
            NSString *canary = [fileNameBase stringByAppendingString:@".canary"];
            NSString *canarya = [fileNameBase stringByAppendingString:@".canarya"];
            NSString *coalmine = [fileNameBase stringByAppendingString:@".coalmine"];
            
            //write to canary
            for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
            NSString *correctPassKey = [[NSString alloc] initWithBytes:data
                                                                length:20
                                                              encoding:NSUTF8StringEncoding];
            [correctPassKey writeToFile:canary atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            //encrypt the canary
            NSString *sslPath = @"/usr/bin/openssl";
            //$openssl rsautl -encrypt -in <input_file> -inkey <llave> -out <output_file>
            NSArray *encryptCanary = [NSArray arrayWithObjects:@"rsautl",
                                      @"-encrypt",
                                      @"-in", canary,
                                      @"-pubin",
                                      @"-inkey", ourPub,
                                      @"-out", canarya, nil];
            
            [[NSTask launchedTaskWithLaunchPath:sslPath arguments:encryptCanary] waitUntilExit];
            [fileManager removeItemAtPath:canary error:nil];
            
            // ASK FOR PASSWORD
            NSString *pass;
            
            //get password
            NSString *prompt = @"Please enter your password...";
            NSString *defaultValue = @"";
            
            NSAlert *alert = [NSAlert alertWithMessageText:prompt
                                             defaultButton:@"Enter"
                                           alternateButton:@"Cancel"
                                               otherButton:nil
                                 informativeTextWithFormat:@"Please enter your password..."];
            
            NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
            [input setStringValue:defaultValue];
            [alert setAccessoryView:input];
            
            NSInteger button = [alert runModal];
            
            // affirmative closing ("ok")
            if (button == NSAlertDefaultReturn) {
                [input validateEditing];
                pass = [input stringValue];
                // Attempt to decrypt with the pass
                NSArray *decryptCanary = [NSArray arrayWithObjects:@"rsautl",
                                          @"-decrypt",
                                          @"-in", canarya,
                                          @"-inkey", ourPriv,
                                          @"-passin", [@"pass:" stringByAppendingString:pass],
                                          @"-out", coalmine, nil];
                [[NSTask launchedTaskWithLaunchPath:sslPath arguments:decryptCanary] waitUntilExit];
                [fileManager removeItemAtPath:canarya error:nil];
                
                // Read in decrypted
                NSString *readCanary = [[NSString alloc]
                                        initWithContentsOfFile:coalmine
                                        encoding:NSUTF8StringEncoding
                                        error:nil];
                // Continue if correct
                if ((readCanary != nil) and ([readCanary isEqualToString:correctPassKey])){
                    [fileManager removeItemAtPath:coalmine error:nil];
                    printf("\nPASSCORRECT\n");
                    NSArray *decryptSnapKey = [NSArray arrayWithObjects:@"rsautl",
                                               @"-decrypt",
                                               @"-in", SnapFileKey,
                                               @"-inkey", ourPriv,
                                               @"-passin", [@"pass:" stringByAppendingString:pass],
                                               @"-out", coalmine, nil];
                    [[NSTask launchedTaskWithLaunchPath:sslPath arguments:decryptSnapKey] waitUntilExit];
                    printf("\nDECRYPTED TO COAL MINE\n");
                    NSArray *decryptImage = [NSArray arrayWithObjects:@"enc",
                                             @"-d",
                                             @"-aes-256-cbc",
                                             @"-in", SnapFileTmp,
                                             @"-pass", [@"file:" stringByAppendingString:coalmine],
                                             @"-out", canary, nil];
                    [[NSTask launchedTaskWithLaunchPath:sslPath arguments:decryptImage] waitUntilExit];
                    NSImage* decryptedImage = [[NSImage alloc] initWithContentsOfFile:canary];
                    NSArray *toEmpty = [fileManager contentsOfDirectoryAtPath:enclave error:nil];
                    for (NSString *x in toEmpty){
                        if([fileManager removeItemAtPath:[enclave stringByAppendingString:x] error:nil]){
                            printf("Deleted %s \n", [x UTF8String]);
                        }
                    }
                    NSWindow *splashWindow = [[NSWindow alloc] initWithContentRect: NSMakeRect (0, 0, 256, 256)
                                                               styleMask: NSBorderlessWindowMask
                                                                 backing:NSBackingStoreBuffered
                                                                   defer:NO];
                    
                    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect (0, 0, 256, 256)];
                    [imageView setImage: decryptedImage];
                    [[splashWindow contentView] addSubview: imageView];
                    [imageView setBounds: NSMakeRect (0, 0, 256, 256)];
                    
                    [splashWindow setHasShadow: YES];
                    [splashWindow center];
                    [splashWindow makeKeyAndOrderFront: self];
                    [imageView display];
                    
//                    [NSThread sleepForTimeInterval:5.0f];
                    double delayInSeconds = 5.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        //code to be executed on the main queue after delay
                        [imageView release];
                        [splashWindow release];
                    });

                }
                else{
                    NSAlert *reset_alert = [[NSAlert alloc] init];
                    [reset_alert addButtonWithTitle:@"OK"];
                    [reset_alert setMessageText:@"Incorrect Password!!"];
                    [reset_alert setAlertStyle:NSWarningAlertStyle];
                    if ([reset_alert runModal] == NSAlertFirstButtonReturn) {
                    }
                }
            } else if (button == NSAlertAlternateReturn) {
            } else {
                //        NSLog(@"HUH?");
            }
        }
        NSArray *toEmpty = [fileManager contentsOfDirectoryAtPath:enclave error:nil];
        for (NSString *x in toEmpty){
            if([fileManager removeItemAtPath:[enclave stringByAppendingString:x] error:nil]){
                printf("Deleted %s \n", [x UTF8String]);
            }
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
//    FSEventStreamStop(stream);
//    FSEventStreamInvalidate(stream);
//    FSEventStreamRelease(stream);

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
            printf("Path changed: %s\n", ppPaths[i]);
            [fileManager removeItemAtPath:this_path error:nil];
        }
    }
}

@end
