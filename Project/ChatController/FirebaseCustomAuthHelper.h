//
//  FirebaseCustomAuthHelper.h
//  Soleto
//
//  Created by Andrea Sponziello on 13/11/14.
//
//

#import <Foundation/Foundation.h>

@class Firebase;
@class FAuthData;

@interface FirebaseCustomAuthHelper : NSObject

@property (strong, nonatomic) Firebase *ref;
@property (strong, nonatomic) NSString *token;

- (id) initWithFirebaseRef:(Firebase *)ref token:(NSString *)token;

- (void) authenticate:(void (^)(NSError *, FAuthData *authData))callback;

@end
