//
//  NotificationAlertVC.h
//  Chat21
//
//  Created by Andrea Sponziello on 22/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class SHPApplicationContext;

@interface NotificationAlertVC : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
- (IBAction)closeAction:(id)sender;

@property (strong, nonatomic) NSTimer *animationTimer;
@property (assign, nonatomic) BOOL animating;

@property (assign, nonatomic) SystemSoundID sound;

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *sender;

-(void)animateShow;
-(void)animateClose;

@end
