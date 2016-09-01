//
//  ChatConversationHandler.h
//  Soleto
//
//  Created by Andrea Sponziello on 19/12/14.
//
//

#import <Foundation/Foundation.h>
#import "SHPFirebaseTokenDelegate.h"
#import "SHPChatDelegate.h"
#import <Firebase/Firebase.h>

@class SHPApplicationContext;
@class FAuthData;
@class FirebaseCustomAuthHelper;
@class Firebase;
@class SHPUser;
@class ChatGroup;

@interface ChatConversationHandler : NSObject <SHPFirebaseTokenDelegate>

//@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPUser *user;
@property (strong, nonatomic) NSString *recipient;
@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSString *groupId;

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderDisplayName;

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *firebaseToken;
@property (strong, nonatomic) Firebase *messagesRef;
@property (strong, nonatomic) Firebase *conversationOnSenderRef;
@property (strong, nonatomic) Firebase *conversationOnReceiverRef;
@property (assign, nonatomic) FirebaseHandle messages_ref_handle;
@property (assign, nonatomic) FirebaseHandle updated_messages_ref_handle;
@property (strong, nonatomic) FirebaseCustomAuthHelper *authHelper;
@property (assign, nonatomic) id <SHPChatDelegate> delegateView;

@property (assign, nonatomic) double lastSentReadNotificationTime;

-(id)initWithRecipient:(NSString *)recipient conversationId:(NSString *)conversationId user:(SHPUser *)user;
-(id)initWithGroupId:(NSString *)groupId conversationId:(NSString *)conversationId user:(SHPUser *)user;
-(void)connect;
- (void)sendMessage:(NSString *)text;
-(void)restoreMessagesFromDB;

@end
