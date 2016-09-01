//
//  Message.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/20/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "ChatMessage.h"
#import <Firebase/Firebase.h>

@implementation ChatMessage

-(id)init {
    self = [super init];
    if (self) {
        // initialization
    }
    return self;
}

-(NSString *)dateFormattedForListView {
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    NSString *date = [timeFormat stringFromDate:self.date];
    return date;
}

-(void)updateStatusOnFirebase:(int)status {
    NSDictionary *message_dict = @{
        @"status": [NSNumber numberWithInt:status]
    };
    [self.ref updateChildValues:message_dict];
}

+(ChatMessage *)messageFromSnapshotFactory:(FDataSnapshot *)snapshot {
    NSString *conversationId = snapshot.value[MSG_FIELD_CONVERSATION_ID];
    NSString *text = snapshot.value[MSG_FIELD_TEXT]; //snapshot.value[@"text"];
    NSString *sender = snapshot.value[MSG_FIELD_SENDER];
    NSString *recipient = snapshot.value[MSG_FIELD_RECIPIENT];
    NSNumber *timestamp = snapshot.value[MSG_FIELD_TIMESTAMP];
    ChatMessage *message = [[ChatMessage alloc] init];
    message.key = snapshot.key;
    message.ref = snapshot.ref;
    message.messageId = snapshot.key;
    message.conversationId = conversationId;
    message.text = text;
    message.sender = sender;
    message.date = [NSDate dateWithTimeIntervalSince1970:timestamp.longValue];
    message.status = [(NSNumber *)snapshot.value[MSG_FIELD_STATUS] intValue];
    message.recipient = recipient;
    return message;
}

@end