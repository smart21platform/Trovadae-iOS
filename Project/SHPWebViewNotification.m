//
//  SHPWebViewNotification.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 22/05/14.
//
//

#import "SHPWebViewNotification.h"

@interface SHPWebViewNotification ()

@end

@implementation SHPWebViewNotification


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
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.titleView = titleLogo;
    
    [self initialize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initialize {
    //self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self.activityUrlPage startAnimating];
    NSURL *url = [NSURL URLWithString:self.urlNotification];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityUrlPage stopAnimating];
    //self.navigationItem.leftBarButtonItem=self.refreshButtonItem;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    //azzero notifiche?????
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    [self.activityUrlPage stopAnimating];
    //self.navigationItem.leftBarButtonItem=self.refreshButtonItem;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}


- (IBAction)refreshUrlPage:(id)sender {
     [self initialize];
}
@end
