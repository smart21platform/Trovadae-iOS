//
//  ChatParsePushService.m
//  Chat21
//
//  Created by Andrea Sponziello on 12/06/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import "ChatParsePushService.h"
#import "ParseChatNotification.h"
#import <Parse/Parse.h>

@implementation ChatParsePushService

-(void)sendNotification:(ParseChatNotification *)notification {
//    NSLog(@"Sending notification %@", notification);
//    NSLog(@"Sending notification sender %@", notification.senderUser);
//    NSLog(@"Sending notification user %@", notification.toUser);
//    NSLog(@"Sending notification alert %@", notification.alert);
//    NSLog(@"Sending notification badge %ld", notification.badge);
//    NSLog(@"Sending notification convId %@", notification.conversationId);
    NSString *_badge = notification.badge; // [NSString stringWithFormat: @"%ld", (long)notification.badge];
    [PFCloud callFunctionInBackground:@"messagesent"
                       withParameters:@{@"sender":notification.senderUser, @"to": notification.toUser, @"alert": notification.alert, @"badge": _badge, @"conversationId": notification.conversationId, @"type": @"chat"}
                                block:^(NSArray *results, NSError *error) {
                                    if (!error) {
                                        // update ui with "notification sent" (as FB Messanger)
                                        //NSLog(@"results: %@", results);
                                    } else {
                                        NSLog(@"error %@", error);
                                    }
                                }
     ];
}

@end
