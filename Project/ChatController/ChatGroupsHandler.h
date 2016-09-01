//
//  ChatGroupsHandler.h
//  Smart21
//
//  Created by Andrea Sponziello on 02/05/15.
//
//

#import <Foundation/Foundation.h>
#import "SHPFirebaseTokenDelegate.h"
#import <Firebase/Firebase.h>

@class FirebaseCustomAuthHelper;
@class Firebase;
@class SHPUser;
@interface ChatGroupsHandler : NSObject

@property (strong, nonatomic) SHPUser *loggeduser;
@property (strong, nonatomic) NSString *me;
@property (strong, nonatomic) FirebaseCustomAuthHelper *authHelper;

//@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSString *firebaseToken;
@property (strong, nonatomic) Firebase *groupsRef;
@property (assign, nonatomic) FirebaseHandle groups_ref_handle_added;
@property (assign, nonatomic) FirebaseHandle groups_ref_handle_changed;
@property (assign, nonatomic) FirebaseHandle groups_ref_handle_removed;
@property (strong, nonatomic) NSString *firebaseRef;
@property (strong, nonatomic) NSString *tenant;

-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user;
-(void)connect;
//-(NSMutableArray *)restoreGroupsFromDB;

@end
