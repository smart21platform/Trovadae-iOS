//
//  SHPWebViewCartVC.m
//  Eurofood
//
//  Created by Dario De Pascalis on 30/09/14.
//
//


#import "SHPWebViewCartVC.h"
#import "SHPNotificationsViewController.h"
#import "SHPProduct.h"
#import "SHPProductDetail.h"
//#import "DDPPlistReader.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
//#import "SHPUserProfileViewController.h"
#import "SHPAppDelegate.h"
#import "SHPConstants.h"
#import "SHPImageUtil.h"
#import "SHPWebViewVC.h"

@interface SHPWebViewCartVC ()
@end
@implementation SHPWebViewCartVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.variable = [[NSString alloc] init];
    [self.navigationItem setHidesBackButton:YES];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    self.webView.delegate=self;
    
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarNavigation"];
    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    NSDictionary *ecommerceDictionary = [viewDictionary objectForKey:@"Ecommerce"];
    urlPageCart=[ecommerceDictionary valueForKey:@"urlPageCart"];
    
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    TAB_NOTIFICATIONS_CART = [settingsDictionary valueForKey:@"TAB_NOTIFICATIONS_CART"];
    /***********************************************************************************/
    //inizializzo un'activity indicator view
    refreshButtonItem = self.navigationItem.rightBarButtonItem;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    bool statusBarStyle = [[settingsDictionary objectForKey:@"setStatusBarStyle"] boolValue];
    if(statusBarStyle == YES){
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }else{
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    /***********************************************************************************/
    self.navigationItem.title = @"STORICO ORDINI";//titleLogo;
    [self.navigationItem.rightBarButtonItem setTintColor:tintColor];
    [self.navigationItem.leftBarButtonItem setTintColor:tintColor];
    [self.navigationItem.titleView setTintColor:tintColor];
    /***********************************************************************************/
    [self initialize];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    UITabBarItem *tbi = (UITabBarItem*)[[[self.tabBarController tabBar] items] objectAtIndex:[TAB_NOTIFICATIONS_CART intValue]];
    int badgeValue = [[NSString stringWithFormat:@"%d",[tbi.badgeValue intValue]] intValue];
    //[tbi setBadgeValue:badgeValue];
    if(badgeValue>0){
        [self.view setUserInteractionEnabled:NO];
        [self initialize];
    }
    else if(!(loggedUser==self.applicationContext.loggedUser.httpBase64Auth) || !self.applicationContext.loggedUser){
        [self initialize];
    }
}

- (void)initialize {
    NSLog(@"*****httpBase64Auth******: %@",self.applicationContext.loggedUser.httpBase64Auth);
    loggedUser = self.applicationContext.loggedUser.httpBase64Auth;
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [activityIndicator startAnimating];
    /***********************************************************************************/
    
    NSDictionary *configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    hostSite = [NSString stringWithFormat:@"http://%@",[configDictionary objectForKey:@"phpextensionsHost"]];
    tenant = [configDictionary objectForKey:@"wordpressTenant"];
    domain = [configDictionary objectForKey:@"serviceDomain"];
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    //hostSite = [thisBundle localizedStringForKey:@"phpextensions.host" value:@"KEY NOT FOUND" table:@"services"];
    pathEcommerce = [thisBundle localizedStringForKey:@"phpextensions.path_ecommerce" value:@"KEY NOT FOUND" table:@"services"];
    //tenant = [thisBundle localizedStringForKey:@"wordpress.tenant" value:@"KEY NOT FOUND" table:@"services"];
    //domain = [thisBundle localizedStringForKey:@"service.path.domain" value:@"KEY NOT FOUND" table:@"services"];
    /***********************************************************************************/
    NSString *urlPage;
    if(!self.url){
        NSString *basicAuth = [NSString stringWithFormat:@""];
        if(self.applicationContext.loggedUser.httpBase64Auth)basicAuth=self.applicationContext.loggedUser.httpBase64Auth;
        urlPage=[NSString stringWithFormat:@"%@%@/%@?basicAuth=%@&tenant=%@&domain=%@&username=%@", hostSite, pathEcommerce, urlPageCart, basicAuth, tenant, domain, self.applicationContext.loggedUser.username];
    }else{
        urlPage=self.url;
    }
    //NSLog(@"urlPage:%@", urlPage);
    NSURL *url = [NSURL URLWithString:urlPage];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    /***************************************************************************************************************/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    NSLog(@"************************ URL %@", [url scheme]);
    if([[url scheme] isEqualToString:@"segue"]) {
        NSLog(@"host %@", [url host] );
        if ([[url host] isEqualToString:@"productDetail"]) {
            NSArray *variables;
            //NSLog(@"query %@", [url query] );
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
        else if ([[url host] isEqualToString:@"toWebView"]) {
            NSArray *variables;
            //NSLog(@"query %@", [url query] );
            variables = [[url query] componentsSeparatedByString: @"url="];
            self.variable=variables[1];
            NSLog(@"variable:%@",self.variable);
            [self performSegueWithIdentifier:@"toWebView" sender:self];
        }
    }else{
        //NSLog(@"query %@", [url query] );
        NSString *string = [NSString stringWithFormat:@"%@",url];
        if ([string rangeOfString:@"detailOrder.php"].location == NSNotFound) {
            //NSLog(@"string does not contain bla");
        } else {
            self.variable=string;
            //NSLog(@"key:%@",self.variable);
            [self performSegueWithIdentifier:@"toWebView" sender:self];
        }
    }
    return YES;
}





-(void)openViewForProductID:(NSString *)productID {
    //NSLog(@"openViewForProductID");
    self.selectedProductID = productID;
    [self performSegueWithIdentifier:@"toProductDetail" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [activityIndicator stopAnimating];
    if ([[segue identifier] isEqualToString:@"toProductDetail"]) {
        //NSLog(@"Opening Product Detail for product %@", self.selectedProductID);
        SHPProduct *product = [[SHPProduct alloc] init];
        product.oid = self.selectedProductID;
        self.selectedProductID=nil;
        SHPProductDetail *productViewController = [segue destinationViewController];
        productViewController.product = product;
        productViewController.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toWebView"]) {
        //UINavigationController *navigationController = [segue destinationViewController];
        //SHPWebViewVC *vc = (SHPWebViewVC *)[[navigationController viewControllers] objectAtIndex:0];
        SHPWebViewVC *vc = (SHPWebViewVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.url = self.variable;
        vc.titlePage = @"DETTAGLIO ORDINE";
    }
    
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
    [self.activityIndicatorLoading stopAnimating];
    [self.activityIndicatorLoading setHidden:YES];
    UITabBarItem *tbi = (UITabBarItem*)[[[self.tabBarController tabBar] items] objectAtIndex:[TAB_NOTIFICATIONS_CART intValue]];
    [tbi setBadgeValue:nil];
    [self.view setUserInteractionEnabled:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //NSLog(@"error: %@",error);
    [activityIndicator stopAnimating];
}

- (IBAction)actionClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reloadWebPage:(id)sender {
    [self initialize];
}


- (IBAction)returnCartVC:(UIStoryboardSegue *)segue {
    //NSLog(@"from segue id: %@", segue.identifier);
    [self initialize];
}

@end
