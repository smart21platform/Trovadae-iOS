//
//  SHPLikeDC.h
//  Shopper
//
//  Created by andrea sponziello on 25/08/12.
//
//

#import <Foundation/Foundation.h>
#import "SHPLikeDCDelegate.h"

@class SHPProduct;
@class SHPUser;

@interface SHPLikeDC : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) id <SHPLikeDCDelegate> likeDelegate;
@property (nonatomic, strong) NSString *serviceUrl;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) SHPProduct *product;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLConnection *currentConnection;

- (void)sendCommand:(NSString *)command toProduct:(SHPProduct *)p withUser:(SHPUser *)u;
- (void)like:(SHPProduct *)product withUser:(SHPUser *)user;
- (void)unlike:(SHPProduct *)product withUser:(SHPUser *)user;
- (void)cancelConnection;

@end
