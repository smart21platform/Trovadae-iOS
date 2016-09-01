//
//  SHPProductUploaderDC.h
//  Dressique
//
//  Created by andrea sponziello on 01/02/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPDataController.h"

@class SHPApplicationContext;
@class SHPShop;
@class SHPCategory;
@class SHPUser;
@class SHPProduct;

@protocol SHPProductUploaderDelegate
- (void)productUploaded:(NSString *)error;
@end

@interface SHPProductUploaderDC : SHPDataController

@property(strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, strong) NSMutableData *receivedData;
@property(strong, nonatomic) UIViewController *callerViewController;
@property(strong, nonatomic) UIProgressView *progressView;
@property (nonatomic, assign) id <SHPProductUploaderDelegate> delegate;
// product-form data
@property(strong, nonatomic) NSString *productTitle;
@property(strong, nonatomic) NSString *productDescription;
@property(strong, nonatomic) NSString *productCategoryOid;
@property(strong, nonatomic) NSString *productShopOid;
@property(strong, nonatomic) NSString *productShopGooglePlacesReference;
@property(strong, nonatomic) NSString *productShopSource;
@property(strong, nonatomic) NSString *productLat;
@property(strong, nonatomic) NSString *productLon;
@property(strong, nonatomic) UIImage *productImage;
@property(strong, nonatomic) NSString *productPrice;
@property(strong, nonatomic) NSString *productStartPrice;
@property(strong, nonatomic) NSString *productTelephone;
@property(strong, nonatomic) NSString *productBrand;
@property(strong, nonatomic) NSString *productStartDate;
@property(strong, nonatomic) NSString *productEndDate;
@property(strong, nonatomic) NSString *uploadId;
@property(assign, nonatomic) BOOL onFinishPublishToFacebook;
@property(strong, nonatomic) NSString *productProperties;

-(void)setMetadata:(UIImage *)__productImage
            brand:(NSString *)__productBrand
            categoryOid:(NSString *)__productCategoryOid
            shopOid:(NSString *)__productShopOid
            shopSource:(NSString *)__productShopSource
            lat:(NSString *)__lat
            lon:(NSString *)__lon
            shopGooglePlacesReference:(NSString *)__productShopGooglePlacesReference
            title:(NSString *)__productTitle
            description:(NSString *)__productDescription
            price:(NSString *)__productPrice
            startprice:(NSString *)__productStartPrice
            telephone:(NSString *)__telephone
            startDate:(NSString *)__productStartDate
            endDate:(NSString *)__productEndDate
            properties:(NSString *)__productProperties;

-(void)send;
-(void)sendReport;
-(void)sendUpdate:(NSString *)idProduct;

+(NSMutableArray *)uploadIdsOnDisk;
+(SHPProductUploaderDC *)getPersistentUploaderById:(NSString *)id;
+(void)deleteMeFromPersistentConnections:(NSString *)id;
+(void)removeUploadFromPersistentConnections:(NSString *)id;

@end
