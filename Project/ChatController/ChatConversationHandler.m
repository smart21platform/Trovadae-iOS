//
//  ChatConversationHandler.m
//  Soleto
//
//  Created by Andrea Sponziello on 19/12/14.
//
//

#import "ChatConversationHandler.h"
#import <Firebase/Firebase.h>
#import "ChatMessage.h"
#import "FirebaseCustomAuthHelper.h"
#import "SHPUser.h"
#import "SHPFirebaseTokenDC.h"
#import "ChatUtil.h"
#import "ChatDB.h"
#import "ChatConversation.h"
#import "SHPChatDelegate.h"
#import "SHPPushNotificationService.h"
#import "SHPPushNotification.h"
#import "ChatManager.h"
#import "ChatGroup.h"
#import "ParseChatNotification.h"
#import "ChatParsePushService.h"

@implementation ChatConversationHandler

-(id)initWithRecipient:(NSString *)recipient conversationId:(NSString *)conversationId user:(SHPUser *)user {
    if (self = [super init]) {
        self.recipient = recipient;
        self.user = user;
        self.senderId = user.username;
        self.conversationId = conversationId;
        
        self.messages = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithGroupId:(NSString *)groupId conversationId:(NSString *)conversationId user:(SHPUser *)user {
    if (self = [super init]) {
        self.groupId = groupId;
        self.user = user;
        self.senderId = user.username;
        self.conversationId = conversationId;
        
        self.messages = [[NSMutableArray alloc] init];
    }
    return self;
}

//-(id)init {
//    if (self = [super init]) {
//        //
//    }
//    return self;
//}

- (void)connect {
    NSLog(@"Firebase login...");
//    [self firebaseLogin];
    [self setupConversation];
}

-(void)restoreMessagesFromDB {
    NSLog(@"RESTORING ALL MESSAGES FOR CONVERSATION %@", self.conversationId);
    NSArray *inverted_messages = [[[ChatDB getSharedInstance] getAllMessagesForConversation:self.conversationId start:0 count:40] mutableCopy];
    NSLog(@"DB MESSAGES NUMBER: %lu", (unsigned long) inverted_messages.count);
    NSLog(@"Last 40 messages restored...");
//    NSLog(@"Reversing array...");
    NSEnumerator *enumerator = [inverted_messages reverseObjectEnumerator];
    for (id element in enumerator) {
        [self.messages addObject:element];
    }
    
    // set as status:"failed" all the messages in status: "sending"
    for (ChatMessage *m in self.messages) {
        if (m.status == MSG_STATUS_SENDING) {
            m.status = MSG_STATUS_FAILED;
        }
    }
}

//-(void)updateMemoryFromDB {
//    NSLog(@"UPDATE DB > MEMORY ALL MESSAGES FOR CONVERSATION %@", self.conversationId);
//    int count = (int) self.messages.count + 1;
//    [self.messages removeAllObjects];
//    NSArray *inverted_messages = [[[ChatDB getSharedInstance] getAllMessagesForConversation:self.conversationId start:0 count:count] mutableCopy];
//    NSLog(@"DB MESSAGES NUMBER: %lu", (unsigned long) inverted_messages.count);
//    NSLog(@"Last %d messages restored...", count);
//    NSLog(@"Reversing array...");
//    NSEnumerator *enumerator = [inverted_messages reverseObjectEnumerator];
//    for (id element in enumerator) {
//        [self.messages addObject:element];
//    }
//}

-(void)firebaseLogin {
    SHPFirebaseTokenDC *dc = [[SHPFirebaseTokenDC alloc] init];
    dc.delegate = self;
    [dc getTokenWithParameters:nil withUser:self.user];
}

-(void)didFinishFirebaseAuthWithToken:(NSString *)token error:(NSError *)error {
    if (token) {
        NSLog(@"Auth Firebase ok. Token: %@", token);
        self.firebaseToken = token;
        [self setupConversation];
    } else {
        NSLog(@"Auth Firebase error: %@", error);
    }
    [self.delegateView didFinishInitConversationHandler:self error:error];
}

-(void)setupConversation {
    NSLog(@"Setting up references' connections with firebase using token: %@", self.firebaseToken);
    self.messagesRef = [ChatUtil conversationMessagesRef:self.conversationId];
    
    
    NSLog(@"Printing messagesRef handler...");
    NSLog(@"Messages Handler: %@", self.messagesRef);
    
    // AUTHENTICATION DISABLED FOR THE MOMENT!
//    [self initFirebaseWithRef:self.messagesRef token:self.firebaseToken];
    
    
    self.conversationOnSenderRef = [ChatUtil conversationRefForUser:self.senderId conversationId:self.conversationId];
    self.conversationOnReceiverRef = [ChatUtil conversationRefForUser:self.recipient conversationId:self.conversationId];
    
    NSInteger lasttime = 0;
    if (self.messages && self.messages.count > 0) {
        ChatMessage *message = [self.messages lastObject];
        NSLog(@"****** MOST RECENT MESSAGE TIME %@ %@", message, message.date);
        lasttime = message.date.timeIntervalSince1970;
    } else {
        lasttime = 0;
    }
    
    
//    // TEST HANDLER
//    [[self.messagesRef queryOrderedByChild:@"timestamp"] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"********** TEST new message snapshot %@\n*********", snapshot);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
//    
//    // TEST HANDLER
//    [[self.messagesRef queryOrderedByChild:@"timestamp"] observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"********** TEST new message snapshot %@\n*********", snapshot);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
//    
//    // TEST HANDLER
//    [[self.messagesRef queryOrderedByChild:@"timestamp"] observeEventType:FEventTypeChildMoved withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"********** TEST new message snapshot %@\n*********", snapshot);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
//    
//    // TEST HANDLER
//    [[self.messagesRef queryOrderedByChild:@"timestamp"] observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"********** TEST new message snapshot %@\n*********", snapshot);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
    
//    self.messages_ref_handle = [[self.messagesRef queryOrderedByChild:@"timestamp"] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
    self.messages_ref_handle = [[[self.messagesRef queryOrderedByChild:@"timestamp"] queryStartingAtValue:@(lasttime)] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // IMPORTANT: This callback is called also for newly locally created messages not still sent.
        NSLog(@">>>> new message snapshot %@", snapshot);
        ChatMessage *message = [ChatMessage messageFromSnapshotFactory:snapshot];
        
        // IMPORTANT (REPEATED)! This callback is called ALSO (and NOT ONLY) for newly locally created messages not still sent (called also with network off!).
        // Then, for every "new" message received (also locally generated) we update the conversation data & his status to "read" (is_new: NO).
//        if ([message.sender isEqualToString:self.senderId] && message.status == MSG_STATUS_SENT) {
//            NSLog(@">>>> UPDATING MY CONVERSATION STATUS...text: %@", message.text);
////            NSLog(@"MESSAGE.SENDER = ME. UPDATING SENDER-SIDE CONVERSATION.");
//            [ChatConversation updateConversation:self.conversationOnSenderRef message_text:message.text sender:message.sender recipient:self.recipient timestamp:[message.date timeIntervalSince1970] is_new:NO conversWith:self.recipient];
//        }
        
        // updates status only of messages not sent by me
        // HO RICEVUTO UN MESSAGGIO NUOVO
        NSLog(@"self.senderId: %@", self.senderId);
        if (message.status < MSG_STATUS_RECEIVED && ![message.sender isEqualToString:self.senderId]) {
            // NOT RECEIVED = NEW!
            NSLog(@"NEW MESSAGE RECEIVED!!!!! %@", message.text);
            [message updateStatusOnFirebase:MSG_STATUS_RECEIVED]; // firebase
        }
        // updates or insert new messages
        [self insertMessageInMemory:message]; // memory
        [self insertMessageOnDBIfNotExists:message];
        [self finishedReceivingMessage:message];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
//    self.updated_messages_ref_handle = [[self.messagesRef queryLimitedToLast:10] observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@">>>> new UPDATED message snapshot %@", snapshot);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
    
    self.updated_messages_ref_handle = [self.messagesRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@">>>> new UPDATED message snapshot %@", snapshot);
        ChatMessage *message = [ChatMessage messageFromSnapshotFactory:snapshot];
        if (message.status == MSG_STATUS_SENDING) {
            NSLog(@"Queed message updated. Data saved successfully. Updating status & reloading tableView.");
            int status = MSG_STATUS_SENT;
            [self updateMessageStatusInMemory:message.messageId withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
        } else if (message.status == MSG_STATUS_RECEIVED) {
            NSLog(@"Message received. Reloading tableView.");
            [self updateMessageStatusInMemory:message.messageId withStatus:message.status];
            [self updateMessageStatusOnDB:message.messageId withStatus:message.status];
            [self finishedReceivingMessage:message];
            [self sendReadNotificationForMessage:message];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void) initFirebaseWithRef:(Firebase *)ref token:(NSString *)token {
    self.authHelper = [[FirebaseCustomAuthHelper alloc] initWithFirebaseRef:ref token:token];
    NSLog(@"ok111");
    [self.authHelper authenticate:^(NSError *error, FAuthData *authData) {
        NSLog(@"authData: %@", authData);
        if (error != nil) {
            NSLog(@"There was an error authenticating.");
        } else {
            NSLog(@"authentication success %@", authData);
        }
    }];
}

-(void)sendReadNotificationForMessage:(ChatMessage *)message {
    double now = [[NSDate alloc] init].timeIntervalSince1970;
    if (now - self.lastSentReadNotificationTime < 10) {
        NSLog(@"TOO EARLY TO SEND A NOTIFICATION FOR THIS MESSAGE: %@", message.text);
        return;
    }
    NSLog(@"SENDING READ NOTIFICATION TO: %@ FOR MESSAGE: %@", message.sender, message.text);
    // PARSE NOTIFICATION
    ParseChatNotification *notification = [[ParseChatNotification alloc] init];
    notification.senderUser = self.user.username;
    notification.toUser = message.sender;
    notification.alert = [[NSString alloc] initWithFormat:@"%@ ha ricevuto il messaggio", message.recipient];
    notification.conversationId = message.conversationId;
    notification.badge = @"-1";
    ChatParsePushService *push_service = [[ChatParsePushService alloc] init];
    [push_service sendNotification:notification];
    // END PARSE NOTIFICATION
    self.lastSentReadNotificationTime = now;
}

-(void)sendMessage:(NSString *)text {
    if (self.groupId) {
        [self sendMessageToGroup:text];
        return;
    } else {
        [self sendMessageToRecipient:text];
    }
}

-(void)sendMessageToRecipient:(NSString *)text {
    NSLog(@"message to send: %@", text);
    ChatMessage *message = [[ChatMessage alloc] init];
    message.text = text;
    message.sender = self.senderId;
    message.recipient = self.recipient;
    message.recipientGroupId = self.groupId;
    NSDate *now = [[NSDate alloc] init];
    message.date = now;
    message.status = MSG_STATUS_SENDING;
    message.conversationId = self.conversationId;
    
    // create firebase reference
//    NSLog(@"self.messagesRef %@", self.messagesRef);
    Firebase *messageRef = [self.messagesRef childByAutoId]; // CHILD'S AUTOGEN UNIQUE ID
    message.messageId = messageRef.key;
//    NSLog(@"messageRef %@", messageRef);
    
    // save message locally
    [self insertMessageInMemory:message];
    [self insertMessageOnDBIfNotExists:message];
    [self finishedReceivingMessage:message]; // TODO messageArrived
    
    // save message to firebase
    NSMutableDictionary *message_dict = [self firebaseMessageFor:message];
    NSLog(@"Sending message to Firebase: %@ %@ %d", message.text, message.messageId, message.status);
    [messageRef setValue:message_dict withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"messageRef.setValue callback. %@", message_dict);
        if (error) {
            NSLog(@"Data could not be saved with error: %@", error);
            int status = MSG_STATUS_FAILED;
            [self updateMessageStatusInMemory:ref.key withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
        } else {
            NSLog(@"Data saved successfully. Updating status & reloading tableView.");
            int status = MSG_STATUS_SENT;
            NSAssert([ref.key isEqualToString:message.messageId], @"REF.KEY %@ different by MESSAGE.ID %@",ref.key, message.messageId);
            [self updateMessageStatusInMemory:message.messageId withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
            
            // send message to notification provider
            
            // SMART21 NOTIFICATION
//            SHPPushNotification *notification = [[SHPPushNotification alloc] init];
//            notification.notificationType = @"chat";
//            notification.toUser = message.recipient;
//            notification.message = [[NSString alloc] initWithFormat:@"%@: %@", message.sender, message.text];
//            notification.properties = @{ @"t": @"chat", @"recipient": message.sender};
//            SHPPushNotificationService *push_service = [[SHPPushNotificationService alloc] init];
//            [push_service sendNotification:notification completionHandler:^(SHPPushNotification *notification, NSError *error) {
//                if (!error) {
//                    NSLog(@"Notification sent for message %@", notification.message);
//                } else {
//                    NSLog(@"Error while sending notification %@. Error: %@", notification.message, error);
//                }
//            } withUser:self.user];
            // END SMART21 NOTIFICATION
            
            // PARSE NOTIFICATION
            ParseChatNotification *notification = [[ParseChatNotification alloc] init];
            notification.senderUser = message.sender;
            notification.toUser = message.recipient;
            notification.alert = [[NSString alloc] initWithFormat:@"%@: %@", message.sender, message.text];
            notification.conversationId = message.conversationId;
            notification.badge = @"1";
            ChatParsePushService *push_service = [[ChatParsePushService alloc] init];
            [push_service sendNotification:notification];
            // END PARSE NOTIFICATION
            
            
            NSLog(@"Updating conversations sender %@ recipient %@", self.senderId, self.recipient);
            
            // updates conversations
            
            // Sender-side conversation
//            NSLog(@"AGGIORNO LA CONVERSAZIONE DEL MITTENTE.");
            ChatManager *chat = [ChatManager getSharedInstance];
//            [chat createOrUpdateConversation:self.conversationOnSenderRef message_text:message.text sender:message.sender recipient:self.recipient timestamp:[message.date timeIntervalSince1970] is_new:NO conversWith:self.recipient];
            ChatConversation *senderConversation = [[ChatConversation alloc] init];
            senderConversation.ref = self.conversationOnSenderRef;
            senderConversation.last_message_text = message.text;
            senderConversation.is_new = NO;
            senderConversation.date = message.date;
            senderConversation.sender = message.sender;
            senderConversation.recipient = self.recipient;
            senderConversation.conversWith = self.recipient;
            senderConversation.groupName = self.groupName;
            senderConversation.groupId = self.groupId;
            senderConversation.status = CONV_STATUS_LAST_MESSAGE;
            // TODO conversation.conversWith_fullname = self.recipient_fullName;
            [chat createOrUpdateConversation:senderConversation];
            
            // Recipient-side: the conversation is new. It becomes !new immediately after the "tap" in recipent-side's converations-list.
//            NSLog(@"AGGIORNO LA CONVERSAZIONE DEL RICEVENTE (%@) CON IS_NEW = SI", self.recipient);
//            [chat createOrUpdateConversation:self.conversationOnReceiverRef message_text:message.text sender:self.senderId recipient:self.recipient timestamp:[msg_timestamp longValue] is_new:YES conversWith:self.senderId];

            ChatConversation *receiverConversation = [[ChatConversation alloc] init];
            receiverConversation.ref = self.conversationOnReceiverRef;
            receiverConversation.last_message_text = message.text;
            receiverConversation.is_new = YES;
            receiverConversation.date = message.date;
            receiverConversation.sender = message.sender;
            receiverConversation.recipient = self.recipient;
            receiverConversation.conversWith = self.senderId;
            senderConversation.groupName = self.groupName;
            receiverConversation.groupId = self.groupId;
            receiverConversation.status = CONV_STATUS_LAST_MESSAGE;
            // TODO conversation.conversWith_fullname = self.recipient_fullName;
            [chat createOrUpdateConversation:receiverConversation];
            
//            NSLog(@"Finished updating conversations...");
        }
    }];
}

-(void)sendMessageToGroup:(NSString *)text {
    ChatMessage *message = [[ChatMessage alloc] init];
    message.text = text;
    message.sender = self.senderId;
    message.recipientGroupId = self.groupId;
    NSDate *now = [[NSDate alloc] init];
    message.date = now;
    message.status = MSG_STATUS_SENDING;
    message.conversationId = self.conversationId;
    
    // create firebase reference
//    NSLog(@"self.messagesRef %@", self.messagesRef);
    Firebase *messageRef = [self.messagesRef childByAutoId]; // CHILD'S AUTOGEN UNIQUE ID
    message.messageId = messageRef.key;
//    NSLog(@"messageRef %@", messageRef);
    
    // save message locally
    [self insertMessageInMemory:message];
    [self insertMessageOnDBIfNotExists:message];
    [self finishedReceivingMessage:message]; // TODO messageArrived
    
    // save message to firebase
    NSMutableDictionary *message_dict = [self firebaseMessageFor:message];
    NSLog(@"(Group) Sending message to Firebase:(%@) %@ %@ %d dict: %@",messageRef, message.text, message.messageId, message.status, message_dict);
    [messageRef setValue:message_dict withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"messageRef.setValue callback. %@", message_dict);
        if (error) {
            NSLog(@"Data could not be saved with error: %@", error);
            int status = MSG_STATUS_FAILED;
            [self updateMessageStatusInMemory:ref.key withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
        } else {
            NSLog(@"Data saved successfully. Updating status & reloading tableView.");
            int status = MSG_STATUS_SENT;
            [self updateMessageStatusInMemory:ref.key withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
            
            // send message to notification provider
            ChatGroup *group = [[ChatDB getSharedInstance] getGroupById:self.groupId];
            for (NSString *memberId in group.members) {
                NSLog(@"*** GROUP NOTIFICATION:%@/%@. Message: %@, member: %@",group.name, group.groupId, text, memberId);
                SHPPushNotification *notification = [[SHPPushNotification alloc] init];
                notification.notificationType = @"chat";
                notification.toUser = message.recipient;
                notification.message = [[NSString alloc] initWithFormat:@"%@: %@", message.sender, message.text];
                notification.properties = @{ @"t": @"chat", @"recipient": memberId};
                SHPPushNotificationService *push_service = [[SHPPushNotificationService alloc] init];
                [push_service sendNotification:notification completionHandler:^(SHPPushNotification *notification, NSError *error) {
                    if (!error) {
                        NSLog(@"Notification sent for message %@", notification.message);
                    } else {
                        NSLog(@"Error while sending notification %@. Error: %@", notification.message, error);
                    }
                } withUser:self.user];
            }
            
            NSLog(@"Updating conversations sender %@ members %@", self.senderId, self.recipient);
            
            // updates conversations
            
            // Sender-side conversation
//            NSLog(@"AGGIORNO LA CONVERSAZIONE DEL MITTENTE.");
            ChatManager *chat = [ChatManager getSharedInstance];
            //            [chat createOrUpdateConversation:self.conversationOnSenderRef message_text:message.text sender:message.sender recipient:self.recipient timestamp:[message.date timeIntervalSince1970] is_new:NO conversWith:self.recipient];
            ChatConversation *senderConversation = [[ChatConversation alloc] init];
            senderConversation.ref = self.conversationOnSenderRef;
            senderConversation.last_message_text = message.text;
            senderConversation.is_new = NO;
            senderConversation.date = message.date;
            senderConversation.sender = message.sender;
//            senderConversation.recipient = self.recipient;
//            senderConversation.conversWith = self.recipient;
            senderConversation.groupName = self.groupName;
            senderConversation.groupId = self.groupId;
            senderConversation.status = CONV_STATUS_LAST_MESSAGE;
            // TODO conversation.conversWith_fullname = self.recipient_fullName;
            [chat createOrUpdateConversation:senderConversation];
            
            // Recipient-side: the conversation is new. It becomes !new immediately after the "tap" in recipent-side's converations-list.
            NSLog(@"AGGIORNO LA CONVERSAZIONE DEI MEMBRI RICEVENTI CON IS_NEW = SI");
            
            for (NSString *memberId in group.members) {
                NSLog(@"AGGIORNO CONVERSAZIONE DI %@", memberId);
                ChatConversation *memberConversation = [[ChatConversation alloc] init];
                Firebase *conversationOnMember = [ChatUtil conversationRefForUser:memberId conversationId:self.conversationId];
                memberConversation.ref = conversationOnMember;
                memberConversation.last_message_text = message.text;
                memberConversation.is_new = YES;
                memberConversation.date = message.date;
                memberConversation.sender = message.sender;
                memberConversation.groupName = self.groupName;
                memberConversation.groupId = self.groupId;
                memberConversation.status = CONV_STATUS_LAST_MESSAGE;
                // TODO conversation.conversWith_fullname = self.recipient_fullName;
                [chat createOrUpdateConversation:memberConversation];
            }
            NSLog(@"Finished updating group conversations...");
        }
    }];
}

-(NSMutableDictionary *)firebaseMessageFor:(ChatMessage *)message {
    // firebase message dictionary
    NSMutableDictionary *message_dict = [[NSMutableDictionary alloc] init];
    NSNumber *msg_timestamp = [NSNumber numberWithDouble:[message.date timeIntervalSince1970]];
    // always
    [message_dict setObject:message.conversationId forKey:MSG_FIELD_CONVERSATION_ID];
    [message_dict setObject:message.text forKey:MSG_FIELD_TEXT];
    [message_dict setObject:message.sender forKey:MSG_FIELD_SENDER];
    [message_dict setObject:msg_timestamp forKey:MSG_FIELD_TIMESTAMP];
    [message_dict setObject:[NSNumber numberWithInt:MSG_STATUS_SENT] forKey:MSG_FIELD_STATUS];
    // only if one-to-one
    if (message.recipient) {
        [message_dict setValue:message.recipient forKey:MSG_FIELD_RECIPIENT];
    }
    // only if group
    if (message.recipientGroupId) {
        [message_dict setValue:message.recipientGroupId forKey:MSG_FIELD_RECIPIENT_GROUP_ID];
    }
    return message_dict;
}

// Updates a just-sent memory-message with the new status: MSG_STATUS_FAILED or MSG_STATUS_SENT
-(void)updateMessageStatusInMemory:(NSString *)messageId withStatus:(int)status {
    for (ChatMessage* msg in self.messages) {
        if([msg.messageId isEqualToString: messageId]) {
            NSLog(@"message found, updating status %d", status);
            msg.status = status;
            break;
        }
    }
}

-(void)updateMessageStatusOnDB:(NSString *)messageId withStatus:(int)status {
    [[ChatDB getSharedInstance] updateMessage:messageId withStatus:status];
}

-(void)insertMessageOnDBIfNotExists:(ChatMessage *)message {
//    NSLog(@"******* saving on db %@", message);
    [[ChatDB getSharedInstance] insertMessageIfNotExists:message];
}

-(void)insertMessageInMemory:(ChatMessage *)message {
    // find message...
    BOOL found = NO;
    for (ChatMessage* msg in self.messages) {
        if([msg.messageId isEqualToString: message.messageId]) {
            NSLog(@"message found, skipping insert");
            found = YES;
            break;
        }
    }
    
    if (found) {
        return;
    }
    else {
        [self.messages addObject:message];
    }
//    [self.messages addObject:message];
    // REORDER MESSAGES?
    // http://stackoverflow.com/questions/805547/how-to-sort-an-nsmutablearray-with-custom-objects-in-it
    
//    // TODO: i messaggi offline del mittente, ricevuti dopo l'invio di messaggi da parte
//    // del mittente, non vengono inseriti. Procedere
////    NSLog(@"THIS MESSAGE -%@- DATE: %@ TIME: %f",message.text, message.date, message.date.timeIntervalSince1970);
//    NSInteger new_msg_time = message.date.timeIntervalSince1970;
//    ChatMessage *last_message = [self.messages lastObject];
//    NSInteger last_msg_time = last_message.date.timeIntervalSince1970;
////    NSLog(@"***** > Before adding, verifying last message -%@- date: %@, time: %ld",message.text, lastmessage.date, lasttime);
//    if (new_msg_time > last_msg_time) {
////        NSLog(@"OK. newtime > lasttime. ADDING THIS MESSAGE: %@", message.text);
//        [self.messages addObject:message];
//    }

}

-(void)finishedReceivingMessage:(ChatMessage *)message {
    NSLog(@"ConversationHandler: Finished receiving message %@ on delegate: %@",message.text, self.delegateView);
    if (self.delegateView) {
        [self.delegateView finishedReceivingMessage:message];
    }
}

@end
