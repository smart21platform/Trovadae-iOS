//
//  ShoppShopDCDelegate.h
//  BirdWatching
//
//  Created by andrea sponziello on 08/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHPShop;
@class SHPShopDC;

@protocol SHPShopsLoadedDCDelegate <NSObject>

@optional
- (void) shopsLoaded: (NSArray *)shops;
- (void) shopCreated:(SHPShop *)shop;
- (void) shopUpdated:(SHPShop *)shop;
- (void) shopDCNetworkError:(SHPShopDC *)dc;
- (void) networkError;

@end
