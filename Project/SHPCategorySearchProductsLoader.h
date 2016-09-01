//
//  SHPCategorySearchProductsLoader.h
//  Dressique
//
//  Created by andrea sponziello on 15/05/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPProductsLoaderStrategy.h"

@class SHPCategory;
@class SHPUser;
@class CLLocation;

@interface SHPCategorySearchProductsLoader : SHPProductsLoaderStrategy

@property (strong, nonatomic) CLLocation *searchLocation;
@property (strong, nonatomic) NSString *categoryId;
//@property (strong, nonatomic) SHPUser *authUser;

@end
