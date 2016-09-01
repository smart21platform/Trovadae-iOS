//
//  ChatUtil.h
//  Soleto
//
//  Created by Andrea Sponziello on 02/12/14.
//
//

#import <Foundation/Foundation.h>

@class Firebase;
@class ChatNotificationView;

@interface ChatUtil : NSObject

+(NSString *)conversationIdWithSender:(NSString *)sender receiver:(NSString *)receiver tenant:(NSString *)tenant;
+(NSString *)conversationIdForGroup:(NSString *)groupId;
+(NSString *)usernameOnTenant:(NSString *)tenant username:(NSString *)username;
+(Firebase *)conversationRefForUser:(NSString *)username conversationId:(NSString *)conversationId;
+(Firebase *)conversationMessagesRef:(NSString *)conversationId;
+(NSString*)buildConversationsReferenceWithTenant:(NSString *)tenant username:(NSString *)user_id baseFirebaseRef:(NSString *)baseFirebaseRef;
+(NSString *)buildPresenceReferenceWithTenant:(NSString *)tenant username:(NSString *)user_id baseFirebaseRef:(NSString *)baseFirebaseRef;
+(Firebase *)groupsRefWithBase:(NSString *)baseRefURL;
+(void)showNotificationWithMessage:(NSString *)message image:(UIImage *)image sender:(NSString *)sender;

@end
