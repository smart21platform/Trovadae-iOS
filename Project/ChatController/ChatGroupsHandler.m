//
//  ChatGroupsHandler.m
//  Smart21
//
//  Created by Andrea Sponziello on 02/05/15.
//
//

#import "ChatGroupsHandler.h"
#import "SHPFirebaseTokenDC.h"
#import "SHPUser.h"
#import "ChatUtil.h"
#import <Firebase/Firebase.h>
#import "ChatGroup.h"
#import "ChatDB.h"
#import "ChatManager.h"

@implementation ChatGroupsHandler

-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user {
    if (self = [super init]) {
        NSLog(@"OOO");
        self.firebaseRef = firebaseRef;
        self.tenant = tenant;
        self.loggeduser = user;
        self.me = user.username;
//        self.groups = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)connect {
    //    NSLog(@"Firebase login with username %@...", self.me);
    //    if (!self.me) {
    //        NSLog(@"ERROR: First set .me property with a valid username.");
    //    }
    //    [self firebaseLogin];
    [self setupGroups];
}

//-(NSMutableArray *)restoreGroupsFromDB {
//    self.groups = [[[ChatDB getSharedInstance] getAllGroupsForUser:self.me] mutableCopy];
//    for (ChatGroup *g in self.groups) {
//        Firebase *group_ref = [self.groupsRef childByAppendingPath:g.groupId];
//        g.ref = group_ref;
//    }
//    NSLog(@"DB GROUPS COUNT: %lu", (unsigned long) self.groups.count);
//    return self.groups;
//}

// ATTENZIONE: UTILIZZATO?????
-(void)firebaseLogin {
    SHPFirebaseTokenDC *dc = [[SHPFirebaseTokenDC alloc] init];
    [dc getTokenWithParameters:nil withUser:self.loggeduser];
}

// ATTENZIONE: UTILIZZATO?????
-(void)didFinishFirebaseAuthWithToken:(NSString *)token error:(NSError *)error {
    if (token) {
        NSLog(@"Chat Groups Firebase Auth ok. Token: %@", token);
        self.firebaseToken = token;
        [self setupGroups];
    } else {
        NSLog(@"Auth Firebase error: %@", error);
    }
}

-(void)setupGroups {
    self.groupsRef = [ChatUtil groupsRefWithBase:self.firebaseRef];
    
    self.groups_ref_handle_added = [self.groupsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"NEW GROUP SNAPSHOT: %@", snapshot);
        ChatGroup *group = [ChatManager groupFromSnapshotFactory:snapshot];
//        NSLog(@"..GROUP NAME: %@", group.name);
        [self insertOrUpdateGroupOnDB:group];
//        [self restoreGroupsFromDB];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    self.groups_ref_handle_changed =
    [self.groupsRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"************************* GROUP UPDATED ****************************");
        NSLog(@"CHANGED GROUP SNAPSHOT: %@", snapshot);
        ChatGroup *group = [ChatManager groupFromSnapshotFactory:snapshot];
        [self insertOrUpdateGroupOnDB:group];
//        [self restoreGroupsFromDB];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}


-(void)insertOrUpdateGroupOnDB:(ChatGroup *)group {
//    NSLog(@"...GROUP NAME: %@", group.name);
    group.user = self.me;
    [[ChatDB getSharedInstance] insertOrUpdateGroup:group];
}

@end
