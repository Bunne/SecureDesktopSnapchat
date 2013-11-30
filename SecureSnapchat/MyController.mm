#import "MyController.h"
#import "SelectFiles.h"
#import "AddPeople.h"

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
}

@end
