//
//  SHPLikedProductsLoader.h
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import "SHPProductsLoaderStrategy.h"
#import "SHPUser.h"

@interface SHPLikedProductsLoader : SHPProductsLoaderStrategy

@property (strong, nonatomic) SHPUser *likedToUser;
//@property (strong, nonatomic) SHPUser *authUser;

@end
