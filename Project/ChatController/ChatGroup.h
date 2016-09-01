//
//  ChatGroup.h
//  Smart21
//
//  Created by Andrea Sponziello on 27/03/15.
//
//

#import <Foundation/Foundation.h>

@class Firebase;
@class FDataSnapshot;
@class SHPApplicationContext;

@interface ChatGroup : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *user; // used to query groups on local DB
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *iconURL;
@property (nonatomic, strong) NSDate *createdOn;
@property (nonatomic, strong) NSMutableArray *members;

+(NSMutableArray *)membersString2Array:(NSString *)membersString;
+(NSString *)membersArray2String:(NSArray *)membersArray;

// dc
//+(void)createGroup:(ChatGroup*)group reference:(Firebase *)groupsBaseRef withContext:(SHPApplicationContext *)context;
//+(void)addMember:(NSString *)groupId member:(NSString *)user_id; // TODO
//+(void)removeMember:(NSString *)groupId member:(NSString *)user_id; // TODO
//+(void)removeGroup:(NSString *)groupId; // TODO


@end
