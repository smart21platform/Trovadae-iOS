//
//  SHPCategoryDCDelegate.h
//  Shopper
//
//  Created by andrea sponziello on 09/08/12.
//
//

#import <Foundation/Foundation.h>

@protocol SHPCategoryDCDelegate <NSObject>

@required
- (void) categoriesLoaded: (NSArray *)categories error:(NSError *)error;
//- (void) networkError;

@end
