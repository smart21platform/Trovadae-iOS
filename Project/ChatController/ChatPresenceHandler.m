//
//  ChatPresenceHandler.m
//  Chat21
//
//  Created by Andrea Sponziello on 02/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "ChatPresenceHandler.h"
#import "SHPFirebaseTokenDC.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "ChatUtil.h"
#import <Firebase/Firebase.h>

@implementation ChatPresenceHandler

-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user {
    if (self = [super init]) {
        self.firebaseRef = firebaseRef;
        self.tenant = tenant;
        self.loggeduser = user;
        self.me = user.username;
    }
    return self;
}

- (void)connect {
    //    NSLog(@"Firebase login with username %@...", self.me);
    //    if (!self.me) {
    //        NSLog(@"ERROR: First set .me property with a valid username.");
    //    }
    //    [self firebaseLogin];
    NSLog(@"connecting handler %@ to firebase: %@", self, self.firebaseRef);
    [self setupMyConnections];
}

-(void)setupMyConnections {
    
    
    // since I can connect from multiple devices, we store each connection instance separately
    // any time that connectionsRef's value is null (i.e. has no children) I am offline
    NSString *myConnectionsRefURL = [ChatUtil buildPresenceReferenceWithTenant:self.tenant username:self.me baseFirebaseRef:self.firebaseRef];
    NSLog(@"Firebase Presence Reference URL: %@", myConnectionsRefURL);
//    Firebase *presenceRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/users/joe/connections"];
    Firebase *myConnectionsRef = [[Firebase alloc] initWithUrl:myConnectionsRefURL];
    
    // stores the timestamp of my last disconnect (the last time I was seen online)
    Firebase *lastOnlineRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/users/joe/lastOnline"];
    
    Firebase *connectedRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/.info/connected"];
    [connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if([snapshot.value boolValue]) {
            // connection established (or I've reconnected after a loss of connection)
            
            // add this device to my connections list
            // this value could contain info about the device or a timestamp instead of just true
            Firebase *con = [myConnectionsRef childByAutoId];
            [con setValue:@YES];
            
            // when this device disconnects, remove it
            [con onDisconnectRemoveValue];
            
            // when I disconnect, update the last time I was seen online
            [lastOnlineRef onDisconnectSetValue:kFirebaseServerValueTimestamp];
        }
    }];
    
    
    
    
    
//    NSLog(@"Setting up conversations for handler %@ on delegate %@", self, self.delegateView);
//    ChatManager *chat = [ChatManager getSharedInstance];
//    NSString *firebase_conversations_ref = [ChatUtil buildConversationsReferenceWithTenant:self.tenant username:self.me baseFirebaseRef:self.firebaseRef];
//    
//    self.conversationsRef = [[Firebase alloc] initWithUrl: firebase_conversations_ref];
//    
//    NSInteger lasttime = 0;
//    ChatConversation *first_conversation;
//    if (self.conversations && self.conversations.count > 0) {
//        first_conversation = [self.conversations firstObject];
//        
//        NSLog(@"****** MOST RECENT CONVERSATION TEXT %@ TIME %@ %@",first_conversation.last_message_text, first_conversation, first_conversation.date);
//        lasttime = first_conversation.date.timeIntervalSince1970;
//    } else {
//        lasttime = 0;
//    }
//    
//    NSLog(@"LAST TIME: %ld, %@", lasttime, [NSDate dateWithTimeIntervalSince1970:lasttime]);
//    
//    //    self.conversations_ref_handle_added = [self.conversationsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//    self.conversations_ref_handle_added = [[[self.conversationsRef queryOrderedByChild:@"timestamp"] queryStartingAtValue:@(lasttime)] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"NEW CONVERSATION snapshot............... %@", snapshot);
//        ChatConversation *conversation = [ChatManager conversationFromSnapshotFactory:snapshot];
//        if ([self.currentOpenConversationId isEqualToString:conversation.conversationId] && conversation.is_new == YES) {
//            // changes (forces) the "is_new" flag to FALSE;
//            conversation.is_new = NO;
//            Firebase *conversation_ref = [self.conversationsRef childByAppendingPath:conversation.conversationId];
//            NSLog(@"UPDATING IS_NEW=NO FOR CONVERSATION %@", conversation_ref);
//            [chat updateConversationIsNew:conversation_ref is_new:conversation.is_new];
//        }
//        [self insertOrUpdateConversationOnDB:conversation];
//        [self restoreConversationsFromDB];
//        // queryStartingAtValue is inclusive so wE must check that this conversation is not already synchronized
//        if (first_conversation && [first_conversation.conversationId isEqualToString:conversation.conversationId]) {
//            if (conversation.date.timeIntervalSince1970 > first_conversation.date.timeIntervalSince1970) {
//                [self finishedReceivingConversation:conversation];
//            }
//        } else {
//            [self finishedReceivingConversation:conversation];
//        }
//        NSLog(@"CONV DATE: %@ FOR %@", conversation.date, conversation.last_message_text);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
//    
//    self.conversations_ref_handle_changed =
//    [self.conversationsRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        //        NSLog(@"************************* CONVERSATION UPDATED ****************************");
//        NSLog(@"CHANGED CONVERSATION snapshot............... %@", snapshot);
//        ChatConversation *conversation = [ChatManager conversationFromSnapshotFactory:snapshot];
//        if ([self.currentOpenConversationId isEqualToString:conversation.conversationId] && conversation.is_new == YES) {
//            // changes (forces) the "is_new" flag to FALSE;
//            conversation.is_new = NO;
//            Firebase *conversation_ref = [self.conversationsRef childByAppendingPath:conversation.conversationId];
//            NSLog(@"UPDATING IS_NEW=NO FOR CONVERSATION %@", conversation_ref);
//            [chat updateConversationIsNew:conversation_ref is_new:conversation.is_new];
//        }
//        [self insertOrUpdateConversationOnDB:conversation];
//        [self restoreConversationsFromDB];
//        [self finishedReceivingConversation:conversation];
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
}

@end
