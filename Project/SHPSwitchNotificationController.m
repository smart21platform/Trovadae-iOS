//
//  SHPSwitchNotificationController.m
//  AnimaeCuore
//
//  Created by Dario De pascalis on 19/06/14.
//
//

#import "SHPSwitchNotificationController.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPNoAuthenticatedViewController.h"
#import "SHPNotificationsViewController.h"

@interface SHPSwitchNotificationController ()

@end

@implementation SHPSwitchNotificationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    //[self switchNotificationView];
    // Do any additional setup after loading the view.
}

-(void)openViewForProductID:(NSString *)productID {
    NSLog(@"openViewForProductID");
    self.selectedProductID = productID;
    [self performSegueWithIdentifier:@"toLoggedIn" sender:self];
}

-(void)switchNotificationView{
    NSLog(@"************* to notification page *************** %@",self.applicationContext.loggedUser);
    if(self.applicationContext.loggedUser){
        [self performSegueWithIdentifier:@"toLoggedIn" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toLoggedOut" sender:self];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self switchNotificationView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toLoggedOut"]) {
        SHPNoAuthenticatedViewController *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toLoggedIn"]) {
        SHPNotificationsViewController *VC = [segue destinationViewController];
        if (self.selectedProductID) {
            VC.selectedProductID = self.selectedProductID;
        } else {
            VC.selectedProductID = nil;
        }
        VC.applicationContext = self.applicationContext;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)unwindToSwitchNotification:(UIStoryboardSegue*)sender
{
    NSLog(@"unwindToListJobAdsTVC:");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
