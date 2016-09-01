//
//  SHPSearchProductsLoader.h
//  Dressique
//
//  Created by andrea sponziello on 04/01/13.
//
//

#import "SHPProductsLoaderStrategy.h"
#import <Foundation/Foundation.h>

@class SHPUser;

@interface SHPSearchProductsLoader : SHPProductsLoaderStrategy

@property (strong, nonatomic) NSString *textToSearch;
//@property (strong, nonatomic) SHPUser *authUser;

@end
