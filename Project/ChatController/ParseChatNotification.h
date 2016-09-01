//
//  ParseChatNotification.h
//  Chat21
//
//  Created by Andrea Sponziello on 10/06/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseChatNotification : NSObject

@property(strong, nonatomic) NSString *alert;
@property(strong, nonatomic) NSString *toUser;
@property(strong, nonatomic) NSString *senderUser;
//@property(strong, nonatomic) NSDictionary *properties;
@property(strong, nonatomic) NSString *badge;
@property(nonatomic, strong) NSString *conversationId;

//-(NSString *)propertiesAsJSON;

@end
