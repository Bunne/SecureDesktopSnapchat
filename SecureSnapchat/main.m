
#import <Cocoa/Cocoa.h>


int main(int argc, char *argv[])
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *conts = [NSHomeDirectory() stringByAppendingString:@"/.snap/contacts/"];
    NSString *enclave = [NSHomeDirectory() stringByAppendingString:@"/.snap/enclave/"];
    NSString *file_pem = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pem"];
    NSString *file_pem_pub = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pub"];
    if([fileManager createDirectoryAtPath:conts
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:nil]){
//        printf("Created");
    }
    if([fileManager createDirectoryAtPath:enclave
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:nil]){
        //        printf("Created");
    }
    // Now that it is created we want to know if a private key exists
    // Create public/private key pair here if does not exist
    if ([fileManager fileExistsAtPath:file_pem ] == NO || [fileManager fileExistsAtPath:file_pem_pub ] == NO){
        
        char data[20];
        for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
        
        
        NSString *pass;// = [[NSString alloc] initWithBytes:data length:20 encoding:NSUTF8StringEncoding];
        
        
        //get password
        NSString *prompt = @"Please choose your password...";
        NSString *defaultValue = @"";

        NSAlert *alert = [NSAlert alertWithMessageText:prompt
                                         defaultButton:@"Enter"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@"Please enter your password..."];

        NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
        [input setStringValue:defaultValue];
        [alert setAccessoryView:input];
    
        
        BOOL done = NO;
        
        while (!done) {
            NSInteger button = [alert runModal];
            
            // affirmative closing ("ok")
            if (button == NSAlertDefaultReturn) {
                [input validateEditing];
                
                pass = [input stringValue];
                
            } else if (button == NSAlertAlternateReturn) {
                //        NSLog(@"User cancelled");
                exit(1);
            } else {
                //        NSLog(@"HUH?");
            }
            if (![pass isEqualToString:@""]) {
                done = YES;
            }
            else NSLog(@"null password. do it again");
        }
        
        //ReEnter Password
        alert = [NSAlert alertWithMessageText:prompt
                                 defaultButton:@"ReEnter"
                               alternateButton:@"Cancel"
                                   otherButton:nil
                     informativeTextWithFormat:@"Please ReEnter your password..."];
        
        input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
        [input setStringValue:defaultValue];
        [alert setAccessoryView:input];
        NSInteger button = [alert runModal];
        
        // affirmative closing ("ok")
        if (button == NSAlertDefaultReturn) {
            [input validateEditing];
            
            if (![[input stringValue] isEqualToString:pass]) {
                exit(2);
            }
            
            pass = [input stringValue];
            
        } else if (button == NSAlertAlternateReturn) {
            //        NSLog(@"User cancelled");
            exit(1);
        } else {
            //        NSLog(@"HUH?");
        }
        if (![pass isEqualToString:@""]) {
            done = YES;
        }
        
        //set keys into place
        pid_t pid = fork();
        int status;
        if (pid == 0) {
            execlp("openssl",
                   "openssl",
                   "genrsa",
                   "-aes128",
                   "-passout", [[@"pass:" stringByAppendingString:pass] UTF8String],
                   "-out", "me.pem",
                   "1024", NULL);
            exit(0);
        }
        waitpid(pid, &status, 0);
        
        pid = fork();
        if (pid == 0) {
            execlp("openssl",
                   "openssl",
                   "rsa",
                   "-in", "me.pem",
                   "-passin", [[@"pass:" stringByAppendingString:pass] UTF8String],
                   "-pubout",
                   "-out", "me.pub",
                   NULL);
            exit(0);
        }
        waitpid(pid, &status, 0);
        
        if ([fileManager moveItemAtPath:@"me.pem"
                                 toPath:file_pem  error:NULL]) {
            //printf("Copied successfully\n");
        }
        if ([fileManager moveItemAtPath:@"me.pub"
                                 toPath:file_pem_pub  error:NULL]) {
            //printf("Copied successfully\n");
        }

    }
    
    return NSApplicationMain(argc,  (const char **) argv);
}
