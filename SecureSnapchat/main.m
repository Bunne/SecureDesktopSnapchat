
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *conts = [NSHomeDirectory() stringByAppendingString:@"/.snap/contacts/"];
    if([fileManager createDirectoryAtPath:conts
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:nil]){
//        printf("Created");
    }
    // Now that it is created we want to know if a private key exists
    // Create public/private key pair here if does not exist
    
    
    return NSApplicationMain(argc,  (const char **) argv);
}
