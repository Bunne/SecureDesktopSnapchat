
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
    if ([fileManager fileExistsAtPath:file_pem ] == NO){
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
        NSArray *args = [NSArray arrayWithObjects:
                                        @"genrsa",
                                        @"-aes128",
                                        passOutCommand,
                                        @"-out me.pem",
                                        @"2048", nil];
        [[NSTask launchedTaskWithLaunchPath:path arguments:args] waitUntilExit];
        NSArray *args2 = [NSArray arrayWithObjects:
                         @"rsa",
                          @"-in me.pem",
                          passInCommand,
                          @"-pubout",
                          @"-out me.pub",
                         nil];
        [[NSTask launchedTaskWithLaunchPath:path arguments:args2] waitUntilExit];
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
