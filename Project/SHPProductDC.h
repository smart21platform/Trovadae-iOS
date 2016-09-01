//  BirdWatching
//
//  Created by andrea sponziello on 26/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPProductDCDelegate.h"
#import <CoreLocation/CoreLocation.h>

@class SHPUser;

@interface SHPProductDC : NSObject

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) id <SHPProductDCDelegate> delegate;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, assign) NSInteger statusCode;


// deprecated
//- (void)searchByLocation:(double)lat lon:(double)lon;

-(void)searchById:(NSString *)oid location:(CLLocation *)location withUser:(SHPUser *)__user;
-(void)search:(CLLocation *)location categoryId:(NSString *)categoryId page:(NSInteger) page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;
-(void)searchByShop:(NSString *)shopId page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;
-(void)productsLikedTo:(SHPUser *)user page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;
-(void)productsCreatedBy:(SHPUser *)user page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;
-(void)searchByText:(NSString *)text location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;
-(void)productDelete:(NSString *)oid withUser:(SHPUser *)user;
-(void)timelineForUser:(SHPUser *)user location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize;

+(NSArray *)jsonToProducts:(NSData *)jsonData;
- (void)cancelDownload;


+(NSString *)getCategoryType:(NSString *)category arrayCategories:(NSArray *)arrayCategories;

@end

