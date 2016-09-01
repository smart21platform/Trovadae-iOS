//
//  SHPActivityViewController.h
//  Shopper
//
// http://www.markbetz.net/2010/09/30/ios-diary-showing-an-activity-spinner-over-a-uitableview/
//
//  Created by andrea sponziello on 10/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHPActivityViewController : UIViewController {
    UILabel *activityLabel;
    UIActivityIndicatorView *activityIndicator;
//    UIView *container;
    CGRect frame;
}

-(id)initWithFrame:(CGRect) theFrame;
-(void)startAnimating;
-(void)stopAnimating;
-(void)hideAll;
-(void)showAll;

@end