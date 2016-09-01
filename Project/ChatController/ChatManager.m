//
//  ChatManager.m
//  Soleto
//
//  Created by Andrea Sponziello on 20/12/14.
//
//

#import "ChatManager.h"
#import "ChatConversationHandler.h"
#import "ChatConversationsHandler.h"
#import "ChatPresenceHandler.h"
#import "ChatGroupsHandler.h"
#import "SHPUser.h"
#import "ChatGroup.h"
#import "SHPPushNotificationService.h"
#import "SHPPushNotification.h"
#import "SHPApplicationContext.h"
#import "ChatConversation.h"
#import "ChatDB.h"

static ChatManager *sharedInstance = nil;

@implementation ChatManager

-(id)init {
    NSLog(@"Initializing ChatManager...");
    if (self = [super init]) {
        self.handlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(void)initializeWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant context:(SHPApplicationContext *)applicationContext {
    ChatManager *chat =[ChatManager getSharedInstance];
    [Firebase defaultConfig].persistenceEnabled = YES;
    chat.firebaseRef = firebaseRef;
    chat.tenant = tenant;
    chat.context = applicationContext;
}

+(ChatManager *)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

//-(void)addConversationHandler:(NSString *)id handler:(ChatConversationHandler *)handler {
-(void)addConversationHandler:(ChatConversationHandler *)handler {
    NSLog(@"Adding handler with key: %@", handler.conversationId);
    [self.handlers setObject:handler forKey:handler.conversationId];
}

-(void)removeConversationHandler:(NSString *)conversationId {
    NSLog(@"Removing conversation handler with key: %@", conversationId);
    [self.handlers removeObjectForKey:conversationId];
}

-(ChatConversationHandler *)getConversationHandlerByConversationId:(NSString *)conversationId {
    NSLog(@"Returning firebase ref with key: %@", conversationId);
    return (ChatConversationHandler *)[self.handlers objectForKey:conversationId];
}

-(ChatConversationsHandler *)createConversationsHandlerForUser:(SHPUser *)user {
//    NSString *className = NSStringFromClass([user class]);
//    NSLog(@"user class %@",className);
    ChatConversationsHandler *handler = [[ChatConversationsHandler alloc] initWithFirebaseRef:self.firebaseRef tenant:self.tenant user:user];
    NSLog(@"Setting new handler %@ to Conversations Manager.", handler);
    self.conversationsHandler = handler;
    return handler;
}

-(ChatPresenceHandler *)createPresenceHandlerForUser:(SHPUser *)user {
//    NSString *className = NSStringFromClass([user class]);
    //    NSLog(@"user class %@",className);
    ChatPresenceHandler *handler = [[ChatPresenceHandler alloc] initWithFirebaseRef:self.firebaseRef tenant:self.tenant user:user];
    NSLog(@"Setting new handler %@ to Conversations Manager.", handler);
    self.presenceHandler = handler;
    return handler;
}

-(void)login:(NSString *)user {
    ChatDB *chatDB =[ChatDB getSharedInstance];
    [chatDB createDBWithName:user];
}

-(void)logout {
    NSLog(@"disposing conversationsHandler.conversations_ref_handle_added...");
    [self.conversationsHandler.conversationsRef removeObserverWithHandle:self.conversationsHandler.conversations_ref_handle_added];
    NSLog(@"disposing conversationsHandler.conversations_ref_handle_changed...");
    [self.conversationsHandler.conversationsRef removeObserverWithHandle:self.conversationsHandler.conversations_ref_handle_changed];
    [self.conversationsHandler.conversationsRef unauth];
//    self.conversationsHandler.conversations = nil;
    self.conversationsHandler = nil;
    
    NSLog(@"disposing messages handlers %@...", self.handlers);
    for (id key in self.handlers) {
        ChatConversationHandler *h = (ChatConversationHandler *)[self.handlers objectForKey:key];
        NSLog(@"disposing message ref: %@, handler: %lu", h.messagesRef, h.messages_ref_handle);
        [h.messagesRef removeObserverWithHandle:h.messages_ref_handle];
        [h.messagesRef removeObserverWithHandle:h.updated_messages_ref_handle];
        [h.messagesRef unauth];
        h.messages = nil;
//        [self removeConversationHandler:h.conversationId]; // Exception "was mutated while being enumerated".
//        NSLog(@"veryfing unauthorized...");
//        [[h.messagesRef queryOrderedByChild:@"timestamp"] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//            NSLog(@"New snapshot %@", snapshot);
//        } withCancelBlock:^(NSError *error) {
//            NSLog(@"%@", error.description);
//        }];
    }
    [self.handlers removeAllObjects];
}

// === GROUPS ===


//-(NSString *)createFirebaseGroup:(ChatGroup*)group {
-(void)createFirebaseGroup:(ChatGroup*)group withCompletionBlock:(void (^)(NSString *groupId, NSError *))completionBlock {
    // create firebase reference
    NSString *groupsBaseRefURL = [self.firebaseRef stringByAppendingFormat:@"/groups"];
    
    NSLog(@"groupsBaseRef %@", groupsBaseRefURL);
    Firebase *groupsRef = [[Firebase alloc] initWithUrl:groupsBaseRefURL];
    Firebase *groupRef = [groupsRef childByAutoId]; // CHILD'S AUTOGEN UNIQUE ID
    group.groupId = groupRef.key;
    NSLog(@"groupRef %@", groupRef);
    
    NSLog(@"group.owner %@", group.owner);
    NSLog(@"group.date %@", group.createdOn);
    NSLog(@"group.iconURL %@", group.iconURL);
    NSLog(@"members >");
    for (NSString *user in group.members) {
        NSLog(@"member: %@", user);
    }
    NSNumber *createdOn_timestamp = [NSNumber numberWithDouble:[group.createdOn timeIntervalSince1970]];
    
    NSString *groupIconURL = group.iconURL;
    if (!group.iconURL) {
        groupIconURL = @"NOICON";
    }
    
    NSDictionary *group_dict = @{
                                 GROUP_OWNER: group.owner,
                                 GROUP_NAME: group.name,
                                 GROUP_MEMBERS : group.members,
                                 GROUP_CREATEDON: createdOn_timestamp,
                                 GROUP_ICON_URL: groupIconURL,
                                 };
    // save group to firebase
    NSLog(@"Saving group to Firebase...");
    [groupRef setValue:group_dict withCompletionBlock:^(NSError *error, Firebase *ref) {
        NSLog(@"setValue callback. %@", group_dict);
        if (error) {
            NSLog(@"Command: \"Create Group %@ on Firebase\" failed with error: %@", group.name, error);
            completionBlock(nil, error);
        } else {
            NSLog(@"Command: \"Create Group %@ on Firebase\" was successfull.", group.name);
            completionBlock(group.groupId, nil);
//            NSLog(@"Sending 'invited' notification to every member.");
//            NSLog(@"members: %d", (int)group.members.count);
//            for (NSString *member_id in group.members) {
//                NSLog(@"member: %@", member_id);
//            }
//            // Send notification to every member
//            for (NSString *member_id in group.members) {
//                NSLog(@"Sending notification to user: %@", member_id);
//                SHPPushNotification *notification = [[SHPPushNotification alloc] init];
//                notification.notificationType = NOTIFICATION_TYPE_MEMBER_ADDED_TO_GROUP;
//                notification.toUser = member_id;
//                notification.message = [[NSString alloc] initWithFormat:@"You have been added to group %@", [group.name capitalizedString]];
//                notification.properties = @{ @"t": NOTIFICATION_TYPE_MEMBER_ADDED_TO_GROUP, @"group_id": group.groupId};
//                SHPPushNotificationService *push_service = [[SHPPushNotificationService alloc] init];
//                [push_service sendNotification:notification completionHandler:^(SHPPushNotification *notification, NSError *error) {
//                    if (!error) {
//                        NSLog(@"Notification sent with message: \"%@\"", notification.message);
//                    } else {
//                        NSLog(@"Error while sending notification %@. Error: %@", notification.message, error);
//                    }
//                } withUser:self.context.loggedUser];
//                NSLog(@"Notification sent to user %@", member_id);
//            }
//            NSLog(@"All notifications sent for group %@.", group.name);
        }
    }];
}

-(ChatGroupsHandler *)createGroupsHandlerForUser:(SHPUser *)user {
    ChatGroupsHandler *handler = [[ChatGroupsHandler alloc] initWithFirebaseRef:self.firebaseRef tenant:self.tenant user:user];
    NSLog(@"Setting new handler %@ to Groups Manager.", handler);
    self.groupsHandler = handler;
    return handler;
}

-(void)addMember:(NSString *)groupId member:(NSString *)user_id {
    // TODO
}

-(void)removeMember:(NSString *)groupId member:(NSString *)user_id {
    // TODO
}

-(void)removeGroup:(NSString *)groupId {
    
}

+(ChatGroup *)groupFromSnapshotFactory:(FDataSnapshot *)snapshot {
    NSString *owner = snapshot.value[GROUP_OWNER];
    NSMutableArray *members = snapshot.value[GROUP_MEMBERS];
    NSString *name = snapshot.value[GROUP_NAME];
    NSNumber *createdOn_timestamp = snapshot.value[GROUP_CREATEDON];
    
    ChatGroup *group = [[ChatGroup alloc] init];
    group.key = snapshot.key;
    group.ref = snapshot.ref;
    group.owner = owner;
    group.name = name;
    group.members = members;
    group.groupId = snapshot.key;
    group.createdOn = [NSDate dateWithTimeIntervalSince1970:createdOn_timestamp.longValue];
    
    return group;
}

// === TEST ===


-(void)firebaseScout {
    NSString *firebase_conversations_ref = [self.firebaseRef stringByAppendingFormat:@"/testchild/person"];
    
    Firebase *testRef = [[Firebase alloc] initWithUrl: firebase_conversations_ref];
    
    NSLog(@"Creating or Updating person...");
    NSDictionary *dict = @{
                                        @"firstname" : @"Andreas",
                                        @"lastname": @"Sponziello"
                                        };
    [testRef updateChildValues:dict withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error) {
            NSLog(@"Error updating or creating %@ generated an error: %@", ref, error);
        } else {
            NSLog(@"Updating or Creating operation on %@ was successful.", ref);
        }
    }];
}

// === CONVERSATIONS ===

-(void)createOrUpdateConversation:(ChatConversation *)conversation {
    NSNumber *msg_timestamp = [NSNumber numberWithDouble:[conversation.date timeIntervalSince1970]];
//    NSLog(@"Creating or updating conversation ref %@ text %@ sender %@ recipient %@ timestamp %@ is_new? %d", conversation.ref, conversation.last_message_text, conversation.sender, conversation.recipient, msg_timestamp, conversation.is_new);
    NSMutableDictionary *conversation_dict = [[NSMutableDictionary alloc] init];
    // always
    [conversation_dict setObject:conversation.last_message_text forKey:CONV_LAST_MESSAGE_TEXT_KEY];
    [conversation_dict setObject:conversation.sender forKey:CONV_SENDER_KEY];
    [conversation_dict setObject:msg_timestamp forKey:CONV_TIMESTAMP_KEY];
    [conversation_dict setObject:[NSNumber numberWithBool:conversation.is_new] forKey:CONV_IS_NEW_KEY];
    [conversation_dict setObject:[NSNumber numberWithInteger:conversation.status] forKey:CONV_STATUS_KEY];
//    if (conversation.conversWith_fullname) {
//        [conversation_dict setObject:conversation.conversWith_fullname forKey:CONV_CONVERS_WITH_FULLNAME];
//    }
    // only if one-to-one
    if (conversation.recipient) {
        [conversation_dict setValue:conversation.recipient forKey:CONV_RECIPIENT_KEY];
        [conversation_dict setValue:conversation.conversWith forKey:CONV_CONVERS_WITH_KEY];
    }
    // only if group
    if (conversation.groupId) {
        [conversation_dict setValue:conversation.groupId forKey:CONV_GROUP_ID_KEY];
    }
    if (conversation.groupName) {
        [conversation_dict setValue:conversation.groupName forKey:CONV_GROUP_NAME_KEY];
    }
//    NSLog(@"CONVERSATION DICTIONARY: %@", conversation_dict);
    [conversation.ref updateChildValues:conversation_dict];
}

// DEPRECATED?????
//-(void)createOrUpdateConversation:(Firebase *)conversationRef message_text:(NSString *)message_text sender:(NSString *)sender recipient:(NSString *)recipient timestamp:(long)timestamp is_new:(int)is_new conversWith:(NSString *)conversWith groupId:(NSString *)groupId groupName:(NSString *)groupName {
//    NSLog(@"Updating conversation ref %@ text %@ sender %@ recipient %@ timestamp %ld is_new? %d", conversationRef, message_text, sender, recipient, timestamp, is_new);
//    NSDictionary *conversation_dict = @{
//                                        CONV_LAST_MESSAGE_TEXT : message_text,
//                                        CONV_SENDER: sender,
//                                        CONV_RECIPIENT: recipient,
//                                        CONV_TIMESTAMP: [NSNumber numberWithLong:timestamp],
//                                        CONV_IS_NEW: [NSNumber numberWithBool:is_new],
////                                        CONV_CONVERS_WITH_FULLNAME: conversWith_fullname,
//                                        CONV_GROUP_ID: groupId,
//                                        CONV_GROUP_NAME: groupName,
//                                        };
//    [conversationRef updateChildValues:conversation_dict];
//}

-(void)removeConversation:(ChatConversation *)conversation {
    
    NSString *conversationId = conversation.conversationId;
    NSLog(@"Removing conversation from local DB...");
    [self removeConversationFromDB:conversationId];
    
    Firebase *conversationRef = conversation.ref;
    [conversationRef removeValueWithCompletionBlock:^(NSError *error, Firebase *firebaseRef) {
        //NSLog(@"Conversation %@ removed from firebase.", firebaseRef);
    }];
}

-(void)removeConversationFromDB:(NSString *)conversationId {
    ChatDB *db = [ChatDB getSharedInstance];
    [db removeConversation:conversationId];
    [db removeAllMessagesForConversation:conversationId];
}

-(void)updateConversationIsNew:(Firebase *)conversationRef is_new:(int)is_new {
    NSLog(@"Updating conversation ref %@ is_new? %d", conversationRef, is_new);
    NSDictionary *conversation_dict = @{
                                        CONV_IS_NEW_KEY: [NSNumber numberWithBool:is_new]
                                        };
    [conversationRef updateChildValues:conversation_dict];
}

+(ChatConversation *)conversationFromSnapshotFactory:(FDataSnapshot *)snapshot {
    NSString *text = snapshot.value[CONV_LAST_MESSAGE_TEXT_KEY];
    NSString *recipient = snapshot.value[CONV_RECIPIENT_KEY];
    NSString *sender = snapshot.value[CONV_SENDER_KEY];
    NSString *conversWith = snapshot.value[CONV_CONVERS_WITH_KEY];
    NSString *groupId = snapshot.value[CONV_GROUP_ID_KEY];
    NSString *groupName = snapshot.value[CONV_GROUP_NAME_KEY];
    NSNumber *timestamp = snapshot.value[CONV_TIMESTAMP_KEY];
    NSNumber *is_new = snapshot.value[CONV_IS_NEW_KEY];
    NSNumber *status = snapshot.value[CONV_STATUS_KEY];
    
    ChatConversation *conversation = [[ChatConversation alloc] init];
    conversation.key = snapshot.key;
    conversation.ref = snapshot.ref;
    conversation.conversationId = snapshot.key;
    conversation.last_message_text = text;
    conversation.recipient = recipient;
    conversation.sender = sender;
    conversation.date = [NSDate dateWithTimeIntervalSince1970:timestamp.longValue];
    conversation.is_new = [is_new boolValue];
    conversation.conversWith = conversWith;
    conversation.groupId = groupId;
    conversation.groupName = groupName;
    conversation.status = (int)[status integerValue];
    return conversation;
}

@end
