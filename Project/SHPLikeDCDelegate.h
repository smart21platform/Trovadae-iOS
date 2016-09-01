//
//  SHPLikeDCDelegate.h
//  Shopper
//
//  Created by andrea sponziello on 25/08/12.
//
//

#import <Foundation/Foundation.h>

@class SHPProduct;

@protocol SHPLikeDCDelegate <NSObject>

@optional
-(void)likeDCLiked:(SHPProduct *)product;
-(void)likeDCUnliked:(SHPProduct *)product;

@required
-(void)likeDCErrorForProduct:(SHPProduct *)product withCode:(NSString *)code;

@end
