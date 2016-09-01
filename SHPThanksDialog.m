//
//  SHPThanksDialog.m
//  Secondamano
//
//  Created by Andrea Sponziello on 26/02/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "SHPThanksDialog.h"
#import <pop/POP.h>

@implementation SHPThanksDialog


-(void)viewDidAppear:(BOOL)animated {
    POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.2)];
    sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    sprintAnimation.springBounciness = 20.f;
    [self.checkImage pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
}

- (IBAction)closeAction:(id)sender {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
