//
//  SHPLikedToLoader.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 14/02/14.
//
//

#import <Foundation/Foundation.h>
#import "SHPUsersLoaderStrategy.h"

@class SHPUserDC;
@class SHPProduct;

@interface SHPLikedToLoader : SHPUsersLoaderStrategy

@property(strong, nonatomic) SHPProduct *product;
@property(strong, nonatomic) SHPUserDC *userDC;

@end
