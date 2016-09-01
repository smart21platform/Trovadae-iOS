//
//  SHPTextBoxViewController.m
//  Dressique
//
//  Created by andrea sponziello on 31/01/13.
//
//

#import "SHPTextBoxViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SHPTextBoxViewController ()

@end

@implementation SHPTextBoxViewController

@synthesize applicationContext;

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
//    self.navigationItem.titleView = titleLogo;
    
//    CALayer * layer = [self.textView layer];
//    [layer setMasksToBounds:YES];
//    [layer setBorderWidth:1.0];
//    layer.cornerRadius = 6.0;
//    [layer setBorderColor:[UIColor darkGrayColor].CGColor];
    
    [self.doneButton setTitle:NSLocalizedString(@"DoneLKey", nil)];
    
    if (self.text) {
        self.textView.text = self.text;
    }
    
    [self.textView becomeFirstResponder];
}

//-(void)viewDidAppear:(BOOL)animated {
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    self.completionHandler(self.textView.text, NO);
}

//- (IBAction)cancelAction:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
//    self.completionHandler(nil, YES);
//}

@end
