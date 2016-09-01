//
//  ChatManager.h
//  Soleto
//
//  Created by Andrea Sponziello on 20/12/14.
//
//

#import <Foundation/Foundation.h>

static NSString* const NOTIFICATION_TYPE_MEMBER_ADDED_TO_GROUP = @"group_member_added";
static NSString* const GROUP_OWNER = @"owner";
static NSString* const GROUP_CREATEDON = @"createdOn";
static NSString* const GROUP_NAME = @"name";
static NSString* const GROUP_MEMBERS = @"members";
static NSString* const GROUP_ICON_URL = @"iconURL";

@class ChatConversationHandler;
@class ChatConversationsHandler;
@class ChatGroupsHandler;
@class SHPUser;
@class ChatGroup;
@class SHPApplicationContext;
@class FDataSnapshot;
@class ChatConversation;
@class Firebase;
@class ChatPresenceHandler;

@interface ChatManager : NSObject

@property (nonatomic, strong) NSString *firebaseRef;
@property (nonatomic, strong) NSString *tenant;
@property (nonatomic, strong) SHPApplicationContext *context;
@property (nonatomic, strong) NSMutableDictionary *handlers;
@property (nonatomic, strong) ChatConversationsHandler *conversationsHandler;
@property (nonatomic, strong) ChatPresenceHandler *presenceHandler;
@property (nonatomic, strong) ChatGroupsHandler *groupsHandler;

+(void)initializeWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant context:(SHPApplicationContext *)applicationContext;
+(ChatManager *)getSharedInstance;

-(void)addConversationHandler:(ChatConversationHandler *)handler;
-(ChatConversationHandler *)getConversationHandlerByConversationId:(NSString *)conversationId;

-(ChatConversationsHandler *)createConversationsHandlerForUser:(SHPUser *)user;
-(ChatPresenceHandler *)createPresenceHandlerForUser:(SHPUser *)user;
-(ChatGroupsHandler *)createGroupsHandlerForUser:(SHPUser *)user;

//-(void)setConversationsHandler:(ChatConversationsHandler *)handler;
//-(void)removeConversationsHandler:(NSString *)id;
//-(ChatConversationsHandler *)getConversationsHandler;

-(void)logout;
-(void)login:(NSString *)user;

-(void)firebaseScout;

// === GROUPS ===

// se errore aggiorna conversazione-gruppo locale (DB, creata dopo) con messaggio errore, stato "riprova" e menù "riprova" (vedi creazione gruppo whatsapp in modalità "aereo").

//- (void) authenticate:(void (^)(NSError *, FAuthData *authData))callback

-(void)createFirebaseGroup:(ChatGroup*)group withCompletionBlock:(void (^)(NSString *groupId, NSError *))completionBlock;
-(void)addMember:(NSString *)groupId member:(NSString *)user_id;
-(void)removeMember:(NSString *)groupId member:(NSString *)user_id;
-(void)removeGroup:(NSString *)groupId;
+(ChatGroup *)groupFromSnapshotFactory:(FDataSnapshot *)snapshot;

// === CONVERSATIONS ===

//-(void)createOrUpdateConversation:(Firebase *)conversationRef message_text:(NSString *)message_text sender:(NSString *)sender recipient:(NSString *)recipient timestamp:(long)timestamp is_new:(int)is_new conversWith:(NSString *)conversWith groupId:(NSString *)groupId groupName:(NSString *)groupName;
-(void)createOrUpdateConversation:(ChatConversation *)conversation;
-(void)removeConversation:(ChatConversation *)conversation;
-(void)removeConversationFromDB:(NSString *)conversationId;
-(void)updateConversationIsNew:(Firebase *)conversationRef is_new:(int)is_new;
+(ChatConversation *)conversationFromSnapshotFactory:(FDataSnapshot *)snapshot;

@end
