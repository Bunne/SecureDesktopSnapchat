
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *conts = [NSHomeDirectory() stringByAppendingString:@"/.contacts/"];
    if([fileManager createDirectoryAtPath:conts
                    withIntermediateDirectories:NO
                    attributes:nil
                    error:nil]){
        printf("yes");
    }
    return NSApplicationMain(argc,  (const char **) argv);
}
