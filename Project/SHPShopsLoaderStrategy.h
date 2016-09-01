//
//  SHPShopsLoaderStrategy.h
//  Dressique
//
//  Created by andrea sponziello on 14/01/13.
//
//

#import <Foundation/Foundation.h>

@class SHPShopDC;

@interface SHPShopsLoaderStrategy : NSObject

@property (strong, nonatomic) SHPShopDC *shopDC;
@property (nonatomic, assign) NSInteger searchStartPage;
@property (nonatomic, assign) NSInteger searchPageSize;

-(void)loadShops;
-(void)cancelOperation;

@end
