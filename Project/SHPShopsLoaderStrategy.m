//
//  SHPShopsLoaderStrategy.m
//  Dressique
//
//  Created by andrea sponziello on 14/01/13.
//
//

#import "SHPShopsLoaderStrategy.h"
#import "SHPShopDC.h"

@implementation SHPShopsLoaderStrategy

@synthesize shopDC;
@synthesize searchPageSize;
@synthesize searchStartPage;

// abstract
-(void)loadShops {}

-(void)cancelOperation {
    [self.shopDC cancelDownload];
}

@end
