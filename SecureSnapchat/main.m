
#import <Cocoa/Cocoa.h>


int main(int argc, char *argv[])
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *conts = [NSHomeDirectory() stringByAppendingString:@"/.snap/contacts/"];
    NSString *file_pem = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pem"];
    NSString *file_pem_pub = [NSHomeDirectory() stringByAppendingString:@"/.snap/me.pub"];
    if([fileManager createDirectoryAtPath:conts
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:nil]){
//        printf("Created");
    }
    // Now that it is created we want to know if a private key exists
    // Create public/private key pair here if does not exist
    if ([fileManager fileExistsAtPath:file_pem ] == NO || [fileManager fileExistsAtPath:file_pem_pub ] == NO){
        /*
        FILE * fp;
        int bits = 1024;
        unsigned long exp = RSA_F4;
        RSA * rsa = RSA_generate_key(bits,exp,NULL,NULL);
        fp = fopen([file_pem UTF8String],"w");
        
        // Generate random pass
        char data[20];
        for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
        NSString *pass = [[NSString alloc] initWithBytes:data length:20 encoding:NSUTF8StringEncoding];
        
        // Write keys
        PEM_write_RSAPrivateKey(fp,rsa,EVP_des_ede3_cbc(),[pass UTF8String],20,NULL,NULL);
        close(fp);
        fp = fopen([file_pem_pub UTF8String],"w");
        PEM_write_RSAPublicKey(fp,rsa);
        close(fp);
        RSA_free(rsa);*/
        char data[20];
        for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
        NSString *pass = [[NSString alloc] initWithBytes:data length:20 encoding:NSUTF8StringEncoding];
        NSString *passOutCommand = [@"-passout pass:" stringByAppendingString:pass];
        NSString *passInCommand = [@"-passin pass:" stringByAppendingString:pass];
        NSString *path = @"/usr/bin/openssl";
        
        
        pid_t pid = fork();
        int status;
        if (pid == 0) {
            execlp("openssl",
                   "openssl",
                   "genrsa",
                   "-aes128",
                   //"-passout", "pass:aoeu",
                   "-passout", [[@"pass:" stringByAppendingString:pass] UTF8String],
                   //[passOutCommand UTF8String],
                   "-out", "me.pem",
                   "1024", NULL);
            exit(0);
        }
        waitpid(pid, &status, 0);
        
        
        
//        NSArray *privateKeyArgs = [NSArray arrayWithObjects:@"genrsa", @"-aes128", @"-out", path, @"1024", nil];
//        
//        NSTask *genPrivateKeyTask = [[[NSTask alloc] init] autorelease];
//        
//        //[NSTask launchedTaskWithLaunchPath:[NSHomeDirectory() stringByAppendingString:@"/.snap/"] arguments:privateKeyArgs];
//        [genPrivateKeyTask setArguments:privateKeyArgs];
//        //[genPrivateKeyTask setLaunchPath:@"/usr/bin/openssl"];
//        [genPrivateKeyTask setLaunchPath:[NSHomeDirectory() stringByAppendingString:@"/.snap/"]];
//        [genPrivateKeyTask launch];
//        
//        do {
//            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
//        } while([genPrivateKeyTask isRunning]);
        
        
        
        
        
        
//        NSArray *args = [NSArray arrayWithObjects:
//                                        @"genrsa",
//                                        @"-aes128",
//                                        passOutCommand,
//                                        @"-out me.pem",
//                                        @"2048", nil];
//        [[NSTask launchedTaskWithLaunchPath:path arguments:args] waitUntilExit];
        NSArray *args2 = [NSArray arrayWithObjects:
                         @"rsa",
                          @"-in me.pem",
                          passInCommand,
                          @"-pubout",
                          @"-out me.pub",
                         nil];
        //[[NSTask launchedTaskWithLaunchPath:path arguments:args2] waitUntilExit];
        
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
                            printf("Copied successfully\n");
        }
        if ([fileManager moveItemAtPath:@"me.pub"
                                 toPath:file_pem_pub  error:NULL]) {
            printf("Copied successfully\n");
        }

    }
    
    return NSApplicationMain(argc,  (const char **) argv);
}
