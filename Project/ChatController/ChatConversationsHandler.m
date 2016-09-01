//
//  ChatConversationsHandler.m
//  Soleto
//
//  Created by Andrea Sponziello on 29/12/14.
//
//

#import "ChatConversationsHandler.h"
#import "SHPFirebaseTokenDC.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "ChatUtil.h"
#import <Firebase/Firebase.h>
#import "ChatConversation.h"
#import "SHPConversationsViewDelegate.h"
#import "ChatDB.h"
#import "ChatManager.h"

//#import "FirebaseCustomAuthHelper.h"

@implementation ChatConversationsHandler

//-(id)initWith:(SHPApplicationContext *)applicationContext delegateView:(id<SHPConversationsViewDelegate>)delegateView {
//    if (self = [super init]) {
//        self.applicationContext = applicationContext;
//        self.me = self.applicationContext.loggedUser.username;
//        self.delegateView = delegateView;
//        
//        self.conversations = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user {
    if (self = [super init]) {
        self.firebaseRef = firebaseRef;
        self.tenant = tenant;
        self.loggeduser = user;
        self.me = user.username;
        self.conversations = [[NSMutableArray alloc] init];
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
    [self setupConversations];
}

-(void)printAllConversations {
    NSLog(@"***** CONVERSATIONS DUMP **************************");
    self.conversations = [[[ChatDB getSharedInstance] getAllConversations] mutableCopy];
    for (ChatConversation *c in self.conversations) {
        NSLog(@"user: %@ id:%@ converswith:%@ sender:%@ recipient:%@",c.user, c.conversationId, c.conversWith, c.sender, c.recipient);
    }
    NSLog(@"******************************* END.");
}

-(NSMutableArray *)restoreConversationsFromDB {
    self.conversations = [[[ChatDB getSharedInstance] getAllConversationsForUser:self.me] mutableCopy];
    for (ChatConversation *c in self.conversations) {
        Firebase *conversation_ref = [self.conversationsRef childByAppendingPath:c.conversationId];
        c.ref = conversation_ref;
    }
//    NSLog(@"DB CONVERSATIONS COUNT: %lu", (unsigned long) self.conversations.count);
    return self.conversations;
//    [self finishedReceivingConversations];
}

// ATTENZIONE: UTILIZZATO?????
-(void)firebaseLogin {
    SHPFirebaseTokenDC *dc = [[SHPFirebaseTokenDC alloc] init];
    dc.delegate = self;
    [dc getTokenWithParameters:nil withUser:self.loggeduser];
}

// ATTENZIONE: UTILIZZATO?????
-(void)didFinishFirebaseAuthWithToken:(NSString *)token error:(NSError *)error {
    if (token) {
        NSLog(@"Chat Conversations Firebase Auth ok. Token: %@", token);
        self.firebaseToken = token;
        [self setupConversations];
    } else {
        NSLog(@"Auth Firebase error: %@", error);
    }
    [self.delegateView didFinishConnect:self error:error];
}

-(void)setupConversations {
    NSLog(@"Setting up conversations for handler %@ on delegate %@", self, self.delegateView);
    ChatManager *chat = [ChatManager getSharedInstance];
    NSString *firebase_conversations_ref = [ChatUtil buildConversationsReferenceWithTenant:self.tenant username:self.me baseFirebaseRef:self.firebaseRef];
    
    self.conversationsRef = [[Firebase alloc] initWithUrl: firebase_conversations_ref];
    
    NSInteger lasttime = 0;
    ChatConversation *first_conversation;
    if (self.conversations && self.conversations.count > 0) {
        first_conversation = [self.conversations firstObject];
        
        NSLog(@"****** MOST RECENT CONVERSATION TEXT %@ TIME %@ %@",first_conversation.last_message_text, first_conversation, first_conversation.date);
        lasttime = first_conversation.date.timeIntervalSince1970;
    } else {
        lasttime = 0;
    }
    
    NSLog(@"LAST TIME: %ld, %@", lasttime, [NSDate dateWithTimeIntervalSince1970:lasttime]);
    
//    self.conversations_ref_handle_added = [self.conversationsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
    self.conversations_ref_handle_added = [[[self.conversationsRef queryOrderedByChild:@"timestamp"] queryStartingAtValue:@(lasttime)] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"NEW CONVERSATION snapshot............... %@", snapshot);
        ChatConversation *conversation = [ChatManager conversationFromSnapshotFactory:snapshot];
        if ([self.currentOpenConversationId isEqualToString:conversation.conversationId] && conversation.is_new == YES) {
            // changes (forces) the "is_new" flag to FALSE;
            conversation.is_new = NO;
            Firebase *conversation_ref = [self.conversationsRef childByAppendingPath:conversation.conversationId];
            NSLog(@"UPDATING IS_NEW=NO FOR CONVERSATION %@", conversation_ref);
            [chat updateConversationIsNew:conversation_ref is_new:conversation.is_new];
        }
        [self insertOrUpdateConversationOnDB:conversation];
        [self restoreConversationsFromDB];
        // queryStartingAtValue is inclusive so we must check that this conversation is not already synchronized
        if (first_conversation && [first_conversation.conversationId isEqualToString:conversation.conversationId]) {
            if (conversation.date.timeIntervalSince1970 > first_conversation.date.timeIntervalSince1970) {
                [self finishedReceivingConversation:conversation];
            }
        } else {
            [self finishedReceivingConversation:conversation];
        }
//        NSLog(@"CONV DATE: %@ FOR %@", conversation.date, conversation.last_message_text);
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    self.conversations_ref_handle_changed =
    [self.conversationsRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"************************* CONVERSATION UPDATED ****************************");
//        NSLog(@"CHANGED CONVERSATION snapshot............... %@", snapshot);
        ChatConversation *conversation = [ChatManager conversationFromSnapshotFactory:snapshot];
        if ([self.currentOpenConversationId isEqualToString:conversation.conversationId] && conversation.is_new == YES) {
            // changes (forces) the "is_new" flag to FALSE;
            conversation.is_new = NO;
            Firebase *conversation_ref = [self.conversationsRef childByAppendingPath:conversation.conversationId];
            NSLog(@"UPDATING IS_NEW=NO FOR CONVERSATION %@", conversation_ref);
            [chat updateConversationIsNew:conversation_ref is_new:conversation.is_new];
        }
        [self insertOrUpdateConversationOnDB:conversation];
        [self restoreConversationsFromDB];
        [self finishedReceivingConversation:conversation];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}


-(void)insertOrUpdateConversationOnDB:(ChatConversation *)conversation {
    conversation.user = self.me;
    //NSLog(@"INSERTING.........: id:%@ converswith:%@ sender:%@ recipient:%@", conversation.conversationId, conversation.conversWith, conversation.sender, conversation.recipient);
    [[ChatDB getSharedInstance] insertOrUpdateConversation:conversation];
//    [self printAllConversations];
}

-(void)finishedReceivingConversation:(ChatConversation *)conversation {
    NSLog(@"Finished receiving conversation %@ on delegate: %@",conversation.last_message_text, self.delegateView);
    if (self.delegateView) {
        [self.delegateView finishedReceivingConversation:conversation];
    }
}

@end
