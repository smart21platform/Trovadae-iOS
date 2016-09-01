//
//  SHPAuth.m
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import "SHPAuth.h"
#import "SHPUser.h"
#import "SHPCaching.h"
#import "SHPApplicationContext.h"

@implementation SHPAuth

static NSString *USER_LOGGED_KEY = @"loggedUser";
static NSString *USER_LOGGED_FILE = @"shopperUserFile";

+(SHPUser *)restoreSavedUser {
    NSMutableDictionary *userDict = [SHPCaching restoreDictionaryFromFile:USER_LOGGED_FILE];
    if (userDict) {
        SHPUser *user = [userDict objectForKey:USER_LOGGED_KEY];
        return user;
    }
    return nil;
}

+(void)saveLoggedUser:(SHPUser *)user {
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
    [userDict setObject:user forKey:USER_LOGGED_KEY];
    [SHPCaching saveDictionary:userDict inFile:USER_LOGGED_FILE];
}

+(void)deleteLoggedUser {
    [SHPCaching deleteFile:USER_LOGGED_FILE];
}

//+(void)signout:(SHPApplicationContext *)applicationContext {
//    applicationContext.loggedUser = nil;
//    [SHPCaching deleteFile:USER_LOGGED_FILE];
//    
//}

@end
