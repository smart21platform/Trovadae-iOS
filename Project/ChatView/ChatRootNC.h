//
//  ChatRootNC.h
//  Chat21
//
//  Created by Andrea Sponziello on 28/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

@interface ChatRootNC : UINavigationController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (assign, nonatomic) int loggedInConfiguration; // -1 = unset, 1 = chat, 2 = not logged
@property (strong, nonatomic) NSDictionary *chatConfig;
@property (assign, nonatomic) BOOL startupLogin;

-(void)openConversationWithRecipient:(NSString *)username;
-(void)openConversationWithRecipient:(NSString *)username sendText:(NSString *)text;

@end
