//
//  SHPNoAuthenticatedViewController.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 27/01/14.
//
//

#import "SHPNoAuthenticatedViewController.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
@interface SHPNoAuthenticatedViewController ()

@end

@implementation SHPNoAuthenticatedViewController

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
    // title image
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.titleView = titleLogo;
    _msgNoAuthenticated.text=NSLocalizedString(@"noAutenticatedNotification", nil);
    //self.navigationController.navigationBar.topItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES];
	// Do any additional setup after loading the view.
    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"************* to notification page LOGOUT *************** %@",self.applicationContext);
    if(self.applicationContext.loggedUser){
        [self performSegueWithIdentifier:@"toSwitchNotification" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toNoAutenticatedView:(UIStoryboardSegue *)segue {
    NSLog(@"toNoAutenticatedView");
    NSLog(@"from segue id: %@", segue.identifier);
}


@end
