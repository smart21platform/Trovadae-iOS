//
//  SHPProductUpdateDC.h
//  San Vito dei Normanni
//
//  Created by Andrea Sponziello on 24/07/14.
//
//

#import <Foundation/Foundation.h>
@protocol SHPProductUpdateDelegate
- (void)itemUpdatedWithError:(NSString *)error;
@end

@class SHPApplicationContext;

@interface SHPProductUpdateDC : NSObject

@property(strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, strong) NSMutableData *receivedData;
@property(strong, nonatomic) UIViewController *delegateViewController;

-(void)update:
        (NSString *)productId
        title:(NSString *)title
        description:(NSString *)productDescription
        price:(NSString *)productPrice
        startprice:(NSString *)productStartPrice
        telephone:(NSString *)telephone
        startDate:(NSString *)startDate
        endDate:(NSString *)endDate;

@end
