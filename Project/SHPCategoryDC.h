//
//  SHPCategoryDC.h
//  Shopper
//
//  Created by andrea sponziello on 09/08/12.
//
//

#import <Foundation/Foundation.h>
#import "SHPCategoryDCDelegate.h"


@interface SHPCategoryDC : NSObject

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) id <SHPCategoryDCDelegate> delegate;
@property (nonatomic, strong) NSURLConnection *theConnection;

- (void)getAll;
+ (NSArray *)jsonToCategories:(NSData *)jsonData;

@end
