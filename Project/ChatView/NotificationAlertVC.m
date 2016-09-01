//
//  NotificationAlertVC.m
//  Chat21
//
//  Created by Andrea Sponziello on 22/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "NotificationAlertVC.h"
#import "ChatRootNC.h"
#import "SHPConversationsVC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"

@interface NotificationAlertVC () {
    SystemSoundID soundID;
}
@end

@implementation NotificationAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"NotificationAlertVC loaded.");
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
//    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"View tapped!! Moving to conversation tab.");
    [self animateClose];
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
    // move to the converstations tab
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
        SHPConversationsVC *vc = nc.viewControllers[0];
        if (vc.presentedViewController) {
            NSLog(@"THERE IS A MODAL PRESENTED! NOT SWITCHING TO ANY CONVERSATION VIEW.");
        } else {
            NSLog(@"SWITCHING TO CONVERSATION VIEW. DISABLED.");
            // IF YOU ENABLE THIS IS MANDATORY TO FIND A WAY TO DISMISS OR HANDLE THE CURRENT MODAL VIEW
//            [nc popToRootViewControllerAnimated:NO];
//            [vc openConversationWithRecipient:self.sender];
//            tabController.selectedIndex = chat_tab_index;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
static float animationDurationShow = 0.5;
static float animationDurationClose = 0.3;
static float showTime = 4.0;

-(void)animateShow {
    [self playSound];
    self.animating = YES;
    [UIView animateWithDuration:animationDurationShow
              delay:0
            options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
         animations:^{
             self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
         }
         completion:^(BOOL finished) {
             self.animating = NO;
             self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:showTime target:self selector:@selector(animateClose) userInfo:nil repeats:NO];
         }
     ];
}

-(void)animateClose {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    self.animating = YES;
    [UIView animateWithDuration:animationDurationClose
        delay:0
        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
        animations:^{
            self.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            self.animating = NO;
        }
    ];
}

- (IBAction)closeAction:(id)sender {
    NSLog(@"Closing alert");
    [self animateClose];
}

-(void)playSound {
    // on completion play a sound
    // help: https://github.com/TUNER88/iOSSystemSoundsLibrary
    // help: http://developer.boxcar.io/blog/2014-10-08-notification_sounds/
//    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_bamboo.caf"];
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/newnotif.caf", [[NSBundle mainBundle] resourcePath]];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
//    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource: ofType:];
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
