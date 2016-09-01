//
//  SHPActivityViewController.m
//  Shopper
//
//  Created by andrea sponziello on 10/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPActivityViewController.h"

@interface SHPActivityViewController ()

@end

@implementation SHPActivityViewController

-(id)initWithFrame:(CGRect)theFrame {
    if (self = [super init]) {
        frame = theFrame;
        self.view.frame = theFrame;
    }
    return self;
}

-(void)startAnimating {
    [activityIndicator startAnimating];
}

-(void)stopAnimating {
    [activityIndicator stopAnimating];
}

-(void)hideAll {
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
    activityLabel.hidden = YES;
}

-(void)showAll {
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    activityLabel.hidden = NO;
}

-(void)createTheView {
//    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
//    activityLabel = [[UILabel alloc] init];
//    activityLabel.text = NSLocalizedString(@"LoadingLKey", nil);
//    activityLabel.textColor = [UIColor darkGrayColor];
//    activityLabel.font = [UIFont systemFontOfSize:16];
//    [container addSubview:activityLabel];
//    activityLabel.frame = CGRectMake(31, 3, 80, 30); //CGRectMake(0, 3, 70, 25);
//    activityLabel.backgroundColor = [UIColor darkGrayColor];
    
    activityIndicator = [[UIActivityIndicatorView alloc] 
                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray
                         ];
//    [container addSubview:activityIndicator];
    float centerx = (frame.size.width - 30) / 2;
    activityIndicator.frame = CGRectMake(centerx, 154, 30, 30);
    
//    [self.view addSubview:container];
//    container.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    [self.view addSubview:activityIndicator];
    self.view.backgroundColor = [UIColor whiteColor];
}

//-(void)loadView {
//    [super loadView];
//    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
//    activityLabel = [[UILabel alloc] init];
//    activityLabel.text = NSLocalizedString(@"Loading", @"string1");
//    activityLabel.textColor = [UIColor lightGrayColor];
//    activityLabel.font = [UIFont systemFontOfSize:17];
//    [container addSubview:activityLabel];
//    activityLabel.frame = CGRectMake(0, 3, 70, 25);
//    
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [container addSubview:activityIndicator];
//    activityIndicator.frame = CGRectMake(80, 0, 30, 30);
//    
//    [self.view addSubview:container];
//    container.center = CGPointMake(frame.size.width/2, frame.size.height/2);
//    self.view.backgroundColor = [UIColor whiteColor];
//}

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
    // Do any additional setup after loading the view.
    [self createTheView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
//    container = nil;
    activityLabel = nil;
    activityIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//-(void)viewWillAppear:(BOOL) animated {
//    NSLog(@".....Appearing...");
//    [super viewWillAppear:animated];
//    [activityIndicator startAnimating];
//}
//
//-(void)viewWillDisappear:(BOOL) animated {
//    [super viewWillDisappear:animated];
//    [activityIndicator stopAnimating];
//}

//-(void)dealloc {
//    container = nil;
//    activityLabel = nil;
//    activityIndicator = nil;
//}

@end
