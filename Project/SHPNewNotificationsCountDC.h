//
//  SHPNewNotificationsCountDC.h
//  Ciaotrip
//
//  Created by andrea sponziello on 24/01/14.
//
//

#import <Foundation/Foundation.h>

typedef void (^SHPNewNotificationsCountDCCompletionHandler)(NSInteger count, NSError *error);

@class SHPApplicationContext;
@class SHPUser;

@interface SHPNewNotificationsCountDC : NSObject

@property(strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, copy) SHPNewNotificationsCountDCCompletionHandler completionHandler;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, strong) NSMutableData *receivedData;

-(void)getCountForUser:(SHPUser *)user completionHandler:(SHPNewNotificationsCountDCCompletionHandler)handler;

@end
