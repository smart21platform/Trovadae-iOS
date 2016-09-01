//
//  SHPTimelineProductsLoader.h
//  Dressique
//
//  Created by andrea sponziello on 15/05/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPProductsLoaderStrategy.h"

@class CLLocation;
@class SHPUser;

@interface SHPTimelineProductsLoader : SHPProductsLoaderStrategy

@property (strong, nonatomic) CLLocation *searchLocation;
//@property (strong, nonatomic) SHPUser *authUser;

@end
