//
//  SHPProductsDelegate.h
//  BirdWatching
//
//  Created by andrea sponziello on 26/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class SHPProductDC;
//@class SHPProduct;

@protocol SHPProductDCDelegate <NSObject>

// deprecated
@required
- (void)loaded: (NSArray *)products;
- (void)networkError;

//@optional
//-(void)productDeleted:(SHPProduct *)product DC:(SHPProductDC *)dc;
//-(void)productsDidLoad:(SHPProductDC *)dc products:(NSArray *)products;

@end
