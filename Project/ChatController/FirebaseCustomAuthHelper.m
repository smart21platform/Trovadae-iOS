//
//  FirebaseCustomAuthHelper.m
//  Soleto
//
//  Created by Andrea Sponziello on 13/11/14.
//

#import "FirebaseCustomAuthHelper.h"
#import <Firebase/Firebase.h>

@implementation FirebaseCustomAuthHelper

- (id) initWithFirebaseRef:(Firebase *)ref token:(NSString *)token {
    self = [super init];
    if (self) {
        NSLog(@" ref: %@ token: %@", ref, token);
        self.ref = ref;
        self.token = token;
    }
    return self;
}

- (void) authenticate:(void (^)(NSError *, FAuthData *authData))callback {
    NSLog(@"authenticate:...");
    [self.ref authWithCustomToken:self.token withCompletionBlock:^(NSError *error, FAuthData *authData) {
        NSLog(@"End Login:\nError:%@\nauth:%@\nuid:%@\nprovider:%@\ntoken:%@\nproviderData:%@", error, authData.auth, authData.uid, authData.provider, authData.token, authData.providerData);
        NSLog(@"email: %@", [authData.auth objectForKey:@"email"]);
        NSLog(@"uid: %@", [authData.auth objectForKey:@"uid"]);
        NSLog(@"username: %@", [authData.auth objectForKey:@"username"]);
        if (error) {
            NSLog(@"Login Failed! %@", error);
        } else {
            NSLog(@"Login succeeded! %@", authData);
            callback(error, authData);
        }
    }];
    
    //    [self.ref authUser:@"andrea.sponziello@gmail.com" password:@"Firebase73" withCompletionBlock:^(NSError *error, FAuthData *authData) {
    //        if (error) {
    //            NSLog(@"Error signing in. %@", error);
    //        } else {
    //            // user is logged in, check authData for data
    //            callback(error, authData);
    //            NSLog(@"signed in.");
    //        }
    //    }];
}

@end
