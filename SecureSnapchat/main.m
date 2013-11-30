
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *conts = [NSHomeDirectory() stringByAppendingString:@"/.snap/contacts/"];
    if([fileManager createDirectoryAtPath:conts
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:nil]){
        printf("Created");
    }
    return NSApplicationMain(argc,  (const char **) argv);
}
