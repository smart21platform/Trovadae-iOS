//
//  SHPUpdateUserCustomPropertiesDC.h
//  TrovaDAE
//
//  Created by Dario De Pascalis on 16/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SHPUser;
@class SHPUpdateUserCustomPropertiesDC;

@protocol SHPUpdateUserCustomPropertiesDCDelegate <NSObject>
@optional
-(void)propertiesUpdated:(SHPUpdateUserCustomPropertiesDC *)dc error:(NSError *)error;
@end

@interface SHPUpdateUserCustomPropertiesDC : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) id <SHPUpdateUserCustomPropertiesDCDelegate> delegate;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSString *serviceUrl;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLConnection *currentConnection;

//- (void)sendCommand:(NSString *)command toProduct:(SHPProduct *)p withUser:(SHPUser *)user;
- (void)updateCommand:(SHPUser *)user;
- (void)cancelConnection;

@end



