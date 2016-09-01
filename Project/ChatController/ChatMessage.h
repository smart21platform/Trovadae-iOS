//
//  ChatMessage.h
//  Soleto
//
//  Created by Andrea Sponziello on 17/11/14.
//
//

#import <Foundation/Foundation.h>

static int const MSG_STATUS_FAILED = -1;
static int const MSG_STATUS_SENDING = 0;
static int const MSG_STATUS_SENT = 1;
static int const MSG_STATUS_RECEIVED = 2;
static int const MSG_STATUS_SEEN = 3;

// firebase fields
static NSString* const MSG_FIELD_CONVERSATION_ID = @"conversationId";
static NSString* const MSG_FIELD_TEXT = @"text";
static NSString* const MSG_FIELD_SENDER = @"sender";
static NSString* const MSG_FIELD_RECIPIENT = @"recipient";
static NSString* const MSG_FIELD_RECIPIENT_GROUP_ID = @"recipientGroupId";
static NSString* const MSG_FIELD_TIMESTAMP = @"timestamp";
static NSString* const MSG_FIELD_STATUS = @"status";

@class Firebase;
@class FDataSnapshot;

@interface ChatMessage : NSObject// <JSQMessageData>

@property (nonatomic, strong) NSString *key; // firebase-key
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) NSString *messageId; // firebase-key
@property (nonatomic, strong) NSString *text; // firebase
@property (nonatomic, strong) NSString *sender; // firebase
@property (nonatomic, strong) NSString *recipient; // firebase
@property (nonatomic, strong) NSString *recipientGroupId; // firebase
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSDate *date; // firebase (converted to timestamp)
@property (nonatomic, assign) int status; // firebase


-(NSString *)dateFormattedForListView;
-(void)updateStatusOnFirebase:(int)status;
+(ChatMessage *)messageFromSnapshotFactory:(FDataSnapshot *)snapshot;

@end