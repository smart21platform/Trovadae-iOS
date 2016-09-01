//
//  SHPWebViewController.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 07/02/14.
//
//

#import "SHPWebViewController.h"

@interface SHPWebViewController ()

@end

UIBarButtonItem *refreshButtonItem;
UIActivityIndicatorView *activityIndicator;
UIBarButtonItem *activityButtonItem;

@implementation SHPWebViewController

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
    self.webView.delegate=self;
    /***********************************************************************************/
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.titleView = titleLogo;
    /***********************************************************************************/
    //inizializzo un'activity indicator view
    refreshButtonItem = self.navigationItem.rightBarButtonItem;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    /***********************************************************************************/
    [self initialize];
}

- (void)initialize {
    NSLog(@"initialize");
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [activityIndicator startAnimating];
    /***********************************************************************************/
    
   /***************************************************************************************************************/
    NSLog(@"urlPage: %@", self.urlPage);
    NSURL *url = [NSURL URLWithString:self.urlPage];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    /***************************************************************************************************************/
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    [activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    
    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [userAdviceAlert show];
    //[alertView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reloadPage:(id)sender {
    [self initialize];
}
@end
