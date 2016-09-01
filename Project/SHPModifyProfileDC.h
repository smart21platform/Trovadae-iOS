//
//  SHPModifyProfileDC.h
//  TrovaDAE
//
//  Created by Dario De Pascalis on 01/07/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SHPUser;
@class SHPModifyProfileDC;

@protocol SHPModifyProfileDCDelegate <NSObject>
@optional
-(void)userUpdated:(SHPModifyProfileDC *)dc error:(NSError *)error;
@end

@interface SHPModifyProfileDC : NSObject <NSURLConnectionDelegate>

@property (nonatomic, assign) id <SHPModifyProfileDCDelegate> delegate;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSString *oldPassword;
@property (nonatomic, strong) NSString *nwPassword;
@property (nonatomic, strong) NSString *serviceUrl;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLConnection *currentConnection;

- (void)updateUserPassword:(SHPUser *)user;
- (void)updateUserName:(SHPUser *)user;
- (void)cancelConnection;

@end

