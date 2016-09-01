//
//  SHPWebViewVC.m
//  Vacanze in Puglia
//
//  Created by Dario De Pascalis on 31/07/14.
//
//

#import "SHPWebViewVC.h"
#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPImageUtil.h"
#import "SHPCartVC.h"
#import "SHPProduct.h"
#import "SHPProductDetail.h"

@interface SHPWebViewVC ()
@end

@implementation SHPWebViewVC


enum actionSheetButtonIndex {
	kSafariButtonIndex,
	kChromeButtonIndex,
};



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES];
    self.webView.delegate=self;
    
    self.navigationItem.title = self.titlePage;
    //[SHPComponents titleLogoForViewController:self];
    
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarNavigation"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    colorBackground = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"colorBackground"]];
    [self.toolBar setBarTintColor:colorBackground];
    /***********************************************************************************/
    //inizializzo un'activity indicator view
    refreshButtonItem = self.navigationItem.rightBarButtonItem;
    
    bool statusBarStyle = [[settingsDictionary objectForKey:@"setStatusBarStyle"] boolValue];
    if(statusBarStyle == YES){
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }else{
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    /***********************************************************************************/
    
    [self initialize];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)initialize {
    NSLog(@"initialize");
    
    /***************************************************************************************************************/
    NSLog(@"urlPage: %@", self.url);
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    /***************************************************************************************************************/
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [activityIndicator startAnimating];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    [activityIndicator stopAnimating];
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
}


- (void)showActionSheet {
    NSString *urlString = @"";

    NSURL* url = [self.webView.request URL];
    urlString = [url absoluteString];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = urlString;
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil)];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
        // Chrome is installed, add the option to open in chrome.
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Chrome", nil)];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    

    
    NSURL *theURL = [self.webView.request URL];
    if (theURL == nil || [theURL isEqual:[NSURL URLWithString:@""]]) {
        //theURL = urlToLoad;
    }
    
    if (buttonIndex == kSafariButtonIndex) {
        [[UIApplication sharedApplication] openURL:theURL];
    }
    else if (buttonIndex == kChromeButtonIndex) {
        NSString *scheme = theURL.scheme;
        
        // Replace the URL Scheme with the Chrome equivalent.
        NSString *chromeScheme = nil;
        if ([scheme isEqualToString:@"http"]) {
            chromeScheme = @"googlechrome";
        } else if ([scheme isEqualToString:@"https"]) {
            chromeScheme = @"googlechromes";
        }
        
        // Proceed only if a valid Google Chrome URI Scheme is available.
        if (chromeScheme) {
            NSString *absoluteString = [theURL absoluteString];
            NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
            NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
            NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
            NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
            
            // Open the URL with Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
        }
    }
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    NSLog(@"url %@", [url scheme]);
    if([[url scheme] isEqualToString:@"segue"]) {
        NSLog(@"host %@", [url host] );
        if ([[url host] isEqualToString:@"back"]) {
            [self performSegueWithIdentifier:@"returnCartVC" sender:self];
        }
        else if ([[url host] isEqualToString:@"productDetail"]) {
                NSArray *variables;
                NSLog(@"query %@", [url query] );
                variables = [[url query] componentsSeparatedByString: @"&"];
                NSArray *keyValue;
                for (NSString *key in variables) {
                    keyValue = [key componentsSeparatedByString: @"="];
                    NSLog(@"key:%@",keyValue);
                    if([keyValue[0] isEqual:@"idProduct"]){
                        self.selectedProductID=keyValue[1];
                        [self openViewForProductID:self.selectedProductID];
                        break;
                    }
                }
        }
    }
    else if([[url scheme] isEqualToString:@"http://"]) {
        NSString *urlPage = [NSString stringWithFormat:@"%@", url];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: urlPage]];
    }
    return YES;
}

-(void)openViewForProductID:(NSString *)productID {
    NSLog(@"openViewForProductID");
    self.selectedProductID = productID;
    [self performSegueWithIdentifier:@"toProductDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   // [activityIndicator stopAnimating];
    if ([[segue identifier] isEqualToString:@"returnCartVC"]) {
        SHPCartVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toProductDetail"]) {
        NSLog(@"Opening Product Detail for product %@", self.selectedProductID);
        SHPProduct *product = [[SHPProduct alloc] init];
        product.oid = self.selectedProductID;
        self.selectedProductID=nil;
        SHPProductDetail *productViewController = [segue destinationViewController];
        productViewController.product = product;
        productViewController.applicationContext = self.applicationContext;
    }

}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)forwardLink:(id)sender {
    [self showActionSheet];
}

- (IBAction)reloadPage:(id)sender {
    [self.webView reload];
    //[self initialize];
}

- (IBAction)nextPage:(id)sender {
}

- (IBAction)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
