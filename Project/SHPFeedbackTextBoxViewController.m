//
//  SHPFeedbackTextBoxViewController.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 28/03/14.
//
//

#import "SHPFeedbackTextBoxViewController.h"
#import "SHPReportDC.h"
#import "SHPApplicationContext.h"
#import "MBProgressHUD.h"
#import "SHPUserMenuTVC.h"
#import "SHPImageUtil.h"

@interface SHPFeedbackTextBoxViewController ()

@end

@implementation SHPFeedbackTextBoxViewController
UIColor *tintColor;

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

    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarNavigation"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    
    
    if (self.applicationContext.loggedUser) {
        self.emailTextField.hidden = YES;
    }
    else {
        self.emailTextField.hidden = NO;
    }
    [self.doneButton setTitle:NSLocalizedString(@"DoneLKey", nil)];
    self.doneButton.enabled = NO;
    self.doneButton.tintColor = [UIColor lightGrayColor];
    
    [self.cancelButton setTitle:NSLocalizedString(@"CancelLKey", nil)];
    self.cancelButton.tintColor = tintColor;
    self.emailTextField.placeholder = NSLocalizedString(@"yourEmailOptional", nil);
    
    if (self.applicationContext.loggedUser) {
        self.emailTextField.hidden = YES;
    }
    else {
        self.emailTextField.hidden = NO;
    }
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneAction:(id)sender {
    self.hud.labelText = @"Sending...";
    
    self.hud.animationType = MBProgressHUDAnimationZoom;
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.center = self.view.center;
    self.hud.userInteractionEnabled = YES;
    [self.hud show:YES];
    
//    self.hud.mode = MBProgressHUDAnimationFade;
//    self.hud.center = self.view.center;
//    [self.hud show:YES];
//    [self.hud hide:YES afterDelay:0.8222];
    // save with reportDC
    self.dc = [[SHPReportDC alloc] init];
    self.dc.delegate = self;
    NSString *text_to_send = [[NSString alloc] initWithFormat:@"From: %@\n%@", self.emailTextField.text, self.textView.text ];
    [self.dc sendReportForObject:@"Feedback" withId:@"" withAbuseType:5000 withText:text_to_send withUser:self.applicationContext.loggedUser];
}

-(void)textViewDidChange:(UITextView *)textView {
    //NSLog(@"TEXT CHANGED %@", textView.text);
    NSString *trimmedDescription = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger characterCount = [trimmedDescription length];
    
    if([trimmedDescription isEqualToString:@""] || characterCount < 10) {
        self.doneButton.enabled = NO;
        self.doneButton.tintColor = [UIColor lightGrayColor];
    }else{
        NSLog(@"TEXT ACTIVED");
        self.doneButton.enabled = YES;
        self.doneButton.tintColor = tintColor;
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)didFinishReport:(SHPReportDC *)dc withError:(id)error {
    NSLog(@"Finished Report");
    [self.hud hide:YES];
    if (error) {
        NSLog(@"With error!");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Errore di rete" message:@"Si è verificato un errore." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    //    [self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo:nil];
//    NSLog(@"parent view controller %@", self.parentViewController);
//    NSLog(@"responds: %d", [self.parentViewController respondsToSelector:@selector(justReported)]);
//    if (self.parentViewController && [self.parentViewController respondsToSelector:@selector(justReported)]) {
//        NSLog(@"OK: parent view controller %@", self.parentViewController);
        [self.userMenuTVC justReported];
//    }
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
