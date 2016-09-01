//
//  SHPActivity.h
//  Coricciati MG
//
//  Created by Dario De Pascalis on 05/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SHPCustomActionShared
- (void)deleteProduct;
//- (void)alertError:(NSString *)error;
@end

@interface SHPActivity : UIActivity

@property (nonatomic, assign) id <SHPCustomActionShared> parent;

@end
