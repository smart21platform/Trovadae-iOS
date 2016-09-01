//
//  SHPNetworkErrorViewController.h
//  Shopper
//
//  Created by andrea sponziello on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHPNetworkErrorViewController : UIViewController {
    UILabel *messageLabel;
    UIButton *retryButton;
    UIView *container;
    NSInteger containerWidth;
    CGRect frame;
}

@property (nonatomic, strong) NSString *message;

-(void)setTargetAndSelector:(id)buttonTarget buttonSelector:(SEL) buttonSelector;
-(id)initWithFrame:(CGRect) theFrame;

@end
