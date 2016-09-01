//
//  SHPSearchShopsLoader.h
//  Dressique
//
//  Created by andrea sponziello on 14/01/13.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "SHPShopsLoaderStrategy.h"

@class CLLocation;

@interface SHPSearchShopsLoader : SHPShopsLoaderStrategy

@property (assign, nonatomic) BOOL allowSearchAll;
@property (strong, nonatomic) CLLocation *searchLocation;
@property (strong, nonatomic) NSString *textToSearch;

@end
