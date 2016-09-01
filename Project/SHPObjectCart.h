//
//  SHPObjectCart.h
//  Eurofood
//
//  Created by Dario De Pascalis on 03/09/14.
//
//

#import <Foundation/Foundation.h>

@interface SHPObjectCart : NSObject
@property (nonatomic, strong) NSString *oid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, assign) int quantity;
@end
