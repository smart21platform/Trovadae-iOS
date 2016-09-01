//
//  SHPVerifyUploadPermissionsDC.h
//  AnimaeCuore
//
//  Created by Dario De Pascalis on 12/06/14.
//
//

#import <Foundation/Foundation.h>

@protocol SHPVerifyUploadPermissionsDCDelegate
- (void)permissionCheck:(BOOL)permission;
@end

@class SHPApplicationContext;

@interface SHPVerifyUploadPermissionsDC : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, strong) id <SHPVerifyUploadPermissionsDCDelegate> delegate;

-(void)verifyUploadPermission;
@end
