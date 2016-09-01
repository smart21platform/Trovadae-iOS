//
//  ChatPresenceHandler.h
//  Chat21
//
//  Created by Andrea Sponziello on 02/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatPresenceViewDelegate.h"

@class SHPApplicationContext;
@class FirebaseCustomAuthHelper;
@class Firebase;
@class SHPUser;

@interface ChatPresenceHandler : NSObject

@property (strong, nonatomic) SHPUser *loggeduser;
@property (strong, nonatomic) NSString *me;
@property (strong, nonatomic) FirebaseCustomAuthHelper *authHelper;

@property (strong, nonatomic) NSString *firebaseToken;
@property (assign, nonatomic) id <ChatPresenceViewDelegate> delegate;
@property (strong, nonatomic) NSString *firebaseRef;
@property (strong, nonatomic) NSString *tenant;

-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user;
-(void)connect;

@end
