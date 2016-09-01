//
//  SHPCart.h
//  Eurofood
//
//  Created by Dario De Pascalis on 03/09/14.
//
//

#import <Foundation/Foundation.h>
@class SHPObjectCart;
@class SHPUser;

@protocol SHPCartDelegate
- (void)responseAddProductToCart:(NSString *)message;
- (void)alertError:(NSString *)error;
@end

@interface SHPCart : NSObject

@property (nonatomic, assign) id <SHPCartDelegate> delegate;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, strong) NSMutableData *receivedData;


- (void)addProductToCart:(NSString *)idProduct quantityProduct:(int)quantityProduct price:(float)priceProduct withUser:(SHPUser *)__user;

@end
