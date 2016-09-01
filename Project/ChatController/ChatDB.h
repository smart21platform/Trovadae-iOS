//
//  ChatDB.h
//  Soleto
//
//  Created by Andrea Sponziello on 05/12/14.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ChatMessage;
@class ChatConversation;
@class ChatGroup;

@interface ChatDB : NSObject
{
    NSString *databasePath;
}

@property (assign, nonatomic) BOOL logQuery;

+(ChatDB*)getSharedInstance;
//-(BOOL)createDB;
-(BOOL)createDBWithName:(NSString *)name;

// messages
-(BOOL)insertMessageIfNotExists:(ChatMessage *)message;
-(BOOL)insertMessage:(ChatMessage *)message;
-(BOOL)updateMessage:(NSString *)messageId withStatus:(int)status;
-(NSArray*)getAllMessages;
-(NSArray*)getAllMessagesForConversation:(NSString *)conversationId start:(int)start count:(int)count;
-(NSArray*)getAllMessagesForConversation:(NSString *)conversationId;
-(ChatMessage *)getMessageById:(NSString *)messageId;
-(BOOL)removeAllMessagesForConversation:(NSString *)conversationId;

// conversations
-(BOOL)insertOrUpdateConversation:(ChatConversation *)conversation;
-(BOOL)insertConversation:(ChatConversation *)conversation;
-(BOOL)updateConversation:(ChatConversation *)conversation;
-(NSArray*)getAllConversations;
-(NSArray*)getAllConversationsForUser:(NSString *)user;
-(ChatConversation *)getConversationById:(NSString *)conversationId;
-(BOOL)removeConversation:(NSString *)conversationId;

// groups
-(BOOL)insertOrUpdateGroup:(ChatGroup *)group;
-(BOOL)insertGroup:(ChatGroup *)group;
-(BOOL)updateGroup:(ChatGroup *)group;
-(NSArray*)getAllGroups;
-(NSArray*)getAllGroupsForUser:(NSString *)user;
-(ChatGroup *)getGroupById:(NSString *)groupId;
-(BOOL)removeGroup:(NSString *)groupId;


@end