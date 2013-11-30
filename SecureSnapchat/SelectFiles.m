//
//  SelectFiles.m
//  SecureSnapchat
//
//  Created by Rabbit on 11/30/13.
//
//

#import "SelectFiles.h"

@implementation SelectFiles


- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    NSString *path = [url path];
    NSString *homeDir = [NSString stringWithFormat:@"/Users/Klick/Desktop/SecureSnapchat/.contacts"];
    
    return [path hasPrefix:homeDir] && ! [path isEqualToString:homeDir];
}

- (void)panel:(id)sender didChangeToDirectoryURL:(NSURL *)url {
    NSString *path = [url path];
    NSString *homeDir = [NSString stringWithFormat:@"/Users/Klick/Desktop/SecureSnapchat/.contacts"];
    
    // If the user has changed to a non home directory, send him back home!
    if (! [path hasPrefix:homeDir]) [sender setDirectory:homeDir];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
    NSString *path = [url path];
    NSString *homeDir = [NSString stringWithFormat:@"/Users/Klick/Desktop/SecureSnapchat/.contacts"];
    
    if (![path hasPrefix:homeDir]) {
        if (outError)
            
            return NO;
    }
    return YES;
}


@end
