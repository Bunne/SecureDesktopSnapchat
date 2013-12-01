//
//  NotificationDelegate.m
//  SecureSnapchat
//
//  Created by Rabbit on 11/30/13.
//
//

#import "NotificationDelegate.h"

@implementation NotificationDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
