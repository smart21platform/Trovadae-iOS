//
//  SHPSwitchNotificationController.h
//  AnimaeCuore
//
//  Created by Dario De pascalis on 19/06/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;

@interface SHPSwitchNotificationController : UIViewController
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *selectedProductID;
-(void)openViewForProductID:(NSString *)productID;

@end
