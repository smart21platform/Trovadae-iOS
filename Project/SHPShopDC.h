//
//  SHPShopDC.h
//  BirdWatching
//
//  Created by andrea sponziello on 07/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPShopsLoadedDCDelegate.h"
#import <CoreLocation/CoreLocation.h>

@class SHPShop;
@class SHPUser;

@interface SHPShopDC : NSObject

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) id <SHPShopsLoadedDCDelegate> shopsLoadedDelegate;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSString *serviceUrl;
@property (nonatomic, strong) NSString *serviceName;

- (void)searchByShopId:(NSString *)shopId;
- (void)searchByName:(NSString *)name;
- (void)searchByLocation:(double)lat lon:(double)lon;
- (void)searchByName:(NSString *)name lat:(double)lat lon:(double)lon;
- (void)searchByText:(NSString *)text location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;
- (void)create:(SHPShop *)shop withUser:(SHPUser *)__user;
- (void)update:(SHPShop *)shop withUser:(SHPUser *)__user;

- (void)cancelDownload;

@end
