//
//  SHPNotificationsViewController.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 24/01/14.
//
//

#import "SHPNotificationsViewController.h"
#import "SHPProduct.h"
#import "SHPProductDetail.h"

#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "SHPAppDelegate.h"
#import "SHPConstants.h"
#import "SHPImageUtil.h"
#import "SHPHomeProfileTVC.h"

@interface SHPNotificationsViewController ()

@end

NSArray *arrayList;
NSString *hostSite;
NSString *pathSite;
NSString *domain;
NSString *urlPageNotification;
NSDate *startDate;
UIColor *tintColor;

UIActivityIndicatorView *activityIndicator;
UIBarButtonItem *refreshButtonItem;
UIBarButtonItem *activityButtonItem;
static float AUTO_RELOAD_INTERVAL = 180.00f;
int TAB_NOTIFICATIONS_INDEX;


@implementation SHPNotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    NSLog(@"viewDidLoad NOTIFICATION ***********************************************************************************");
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    self.webView.delegate=self;
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarNavigation"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    TAB_NOTIFICATIONS_INDEX = [[settingsDictionary valueForKey:@"TAB_NOTIFICATIONS_INDEX"] intValue];
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
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.titleView = titleLogo;
    [self.navigationItem.rightBarButtonItem setTintColor:tintColor];
    [self.navigationItem.leftBarButtonItem setTintColor:tintColor];
    [self.navigationItem.titleView setTintColor:tintColor];
    /***********************************************************************************/
    NSLog(@"viewDidLoad-USER: %@",self.applicationContext.loggedUser);
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.navigationItem setHidesBackButton:YES];
    if(self.applicationContext.loggedUser){
        /***********************************************************************************/
        //calcolo quanti secondi sono passati dall'ultimo caricamento della pagina delle notifiche
        NSNumber *timeLastRefresh=[[NSNumber alloc]initWithFloat:[[NSDate date] timeIntervalSinceDate: startDate]];
        NSLog(@"Seconds --------> %@",timeLastRefresh);
        /***********************************************************************************/
        int notificationsCount = [[[[[self.applicationContext.tabBarController tabBar] items] objectAtIndex:TAB_NOTIFICATIONS_INDEX] badgeValue] intValue];
        NSLog(@"[self.tabBarItem badgeValue22] %@", [[[[self.applicationContext.tabBarController tabBar] items] objectAtIndex:TAB_NOTIFICATIONS_INDEX] badgeValue]);
        NSLog(@"notificationsCount: %d", notificationsCount);
        NSLog(@"startDate: %@", startDate);
        if(!startDate || [timeLastRefresh floatValue] > AUTO_RELOAD_INTERVAL || notificationsCount > 0) {
            NSLog(@"Ricarico perchè sono passati 3 minuti | notificationsCount > 0.");
            [self initialize];
        }
    }
    if(self.selectedProductID){
        NSLog(@"********** selectedProductID: %@", self.selectedProductID);
        [self performSegueWithIdentifier:@"toProductDetailNoAnimation" sender:self];
    }
}

- (void)initialize {
     NSLog(@"initialize NOTIFICATION ***********************************************************************************");
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [activityIndicator startAnimating];
    /***********************************************************************************/
    //imposta la data di caricamento della pagina delle notifiche
    startDate=[NSDate date];
    NSLog(@"startDate %@",startDate);
    /***********************************************************************************/
    //recupero host del sito da richiamare per caricamento iconcine della lista e per l'url da richiamare nel prepareforsegue
    NSDictionary *configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    hostSite = [configDictionary objectForKey:@"wordpressHost"];
    pathSite = [NSString stringWithFormat:@"%@",[configDictionary objectForKey:@"serviceCategoriesTenant"]];
    domain = [configDictionary objectForKey:@"serviceDomain"];
    hostSite = [NSString stringWithFormat:@"http://%@",[configDictionary objectForKey:@"phpextensionsHost"]];
    
    //NSString *tenant = [configDictionary objectForKey:@"wordpressTenant"];
    
    
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    hostSite = [thisBundle localizedStringForKey:@"wordpress.host" value:@"KEY NOT FOUND" table:@"services"];
//    pathSite = [thisBundle localizedStringForKey:@"service.tenant" value:@"KEY NOT FOUND" table:@"services"];
//    domain = [thisBundle localizedStringForKey:@"service.path.domain" value:@"KEY NOT FOUND" table:@"services"];
//    NSLog(@"hostSite:%@", hostSite);
    /***********************************************************************************/

    /***********************************************************************************/
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    urlPageNotification = [settingsDictionary objectForKey:@"urlPageNotification"];
    //NSLog(@"settingsDictionary: %@ - urlPageNotification: %@", settingsDictionary,urlPageNotification);
//    NSArray *arrayLabel;
//    NSString *nameFile = @"settings";
//    //DEPA CONTROLLO
//    arrayLabel =[NSArray arrayWithObjects:@"Settings", nil];
    //arrayList = [DDPPlistReader parsePlist:(NSString *)nameFile arrayLabel:(NSArray *)arrayLabel];
    //pathSite=[arrayList valueForKey:@"pathTenant"];
    //urlPageNotification=[arrayList valueForKey:@"urlPageNotification"];
    //NSLog(@"pathSite: %@ - urlPageNotification: %@", pathSite,urlPageNotification);

    /***************************************************************************************************************/

    /***************************************************************************************************************/
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *urlPage=[NSString stringWithFormat:@"%@/%@?basicAuth=%@&tenant=%@&domain=%@&lang=%@", hostSite, urlPageNotification, self.applicationContext.loggedUser.httpBase64Auth, pathSite, domain,langID];
    
    urlPage = [urlPage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    //-------------------------------------------------------------------------------------------------------------//
    //se nn viene passato alcun domain di default viene preso "ciaotrip.it" nella pagina di wordpress notification
    //urlPage=[NSString stringWithFormat:@"%@&domain=%@", urlPage, domain];
    //-------------------------------------------------------------------------------------------------------------//
    NSLog(@"urlPage:%@", urlPage);
    
   // NSString *fullURL=[NSString stringWithFormat:@"%@/",urlPage];
    NSURL *url = [NSURL URLWithString:urlPage];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    //NSLog(@"carico pagina web: %@",urlPage);
    [_webView loadRequest:requestObj];
    /***************************************************************************************************************/
    
    //[self.reload setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"************* to notification page LOGIN *************** %@", self.applicationContext);
    if(!self.applicationContext.loggedUser){
       startDate=nil;
       [self performSegueWithIdentifier:@"toSwitchNotification" sender:self];
    }
//    if(self.selectedProductID){
//        [self performSegueWithIdentifier:@"toProductDetailNoAnimation" sender:self];
//    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    NSLog(@"url %@", [url scheme]);
    if([[url scheme] isEqualToString:@"segue"]) {
        NSLog(@"host %@", [url host] );
        if ([[url host] isEqualToString:@"userProfile"]) {
            NSArray *variables;
            NSLog(@"query %@", [url query] );
            variables = [[url query] componentsSeparatedByString: @"&"];
            NSString *stringlVariables;
            NSArray *keyValue;
            for (NSString *key in variables) {
                keyValue = [key componentsSeparatedByString: @"="];
                NSLog(@"key:%@",keyValue);
                if([keyValue[0] isEqual:@"username"]){
                    self.selectedUsername=keyValue[1];
                    stringlVariables=[NSString stringWithFormat:@"%@ key:%@ value:%@",stringlVariables,keyValue[0],keyValue[1]];
                    NSLog(@"variables %@", stringlVariables );
                    break;
                }
            }
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"navigationProfile"];
            SHPHomeProfileTVC *VC = (SHPHomeProfileTVC *)[[nc viewControllers] objectAtIndex:0];
            VC.applicationContext = self.applicationContext;
            SHPUser *tmp_user = [[SHPUser alloc]init];
            tmp_user.username = self.selectedUsername;
            VC.user = tmp_user;
            [self.navigationController pushViewController:VC animated:YES];
        }else if ([[url host] isEqualToString:@"productDetail"]) {
            NSArray *variables;
            NSLog(@"query %@", [url query] );
            variables = [[url query] componentsSeparatedByString: @"&"];
            //NSString *stringlVariables;
            NSArray *keyValue;
            for (NSString *key in variables) {
                keyValue = [key componentsSeparatedByString: @"="];
                NSLog(@"key:%@",keyValue);
                if([keyValue[0] isEqual:@"idProduct"]){
                    self.selectedProductID=keyValue[1];
                    break;
                }
            }
            [self performSegueWithIdentifier:@"ProductDetail" sender:self];
        }
    }
    return YES;
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [activityIndicator stopAnimating];
    if([segue.identifier isEqualToString:@"toUserProfile"]){
    }
    else if ([[segue identifier] isEqualToString:@"ProductDetail"]) {
        NSLog(@"Opening Product Detail for product %@", self.selectedProductID);
        SHPProduct *product = [[SHPProduct alloc] init];
        product.oid = self.selectedProductID;
        self.selectedProductID=nil;
        SHPProductDetail *vc = [segue destinationViewController];
        vc.product = product;
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toProductDetailNoAnimation"]) {
        NSLog(@"Opening Product Detail for product %@", self.selectedProductID);
        SHPProduct *product = [[SHPProduct alloc] init];
        product.oid = self.selectedProductID;
        self.selectedProductID=nil;
        SHPProductDetail *productViewController = [segue destinationViewController];
        productViewController.product = product;
        productViewController.applicationContext = self.applicationContext;
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    //azzero notifiche
    //[self.tabBarItem setBadgeValue:nil];
    [[[[self.applicationContext.tabBarController tabBar] items] objectAtIndex:TAB_NOTIFICATIONS_INDEX] setBadgeValue:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //self.webView.alpha=1;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    [activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
}

- (IBAction)reloadWebPage:(id)sender {
    [self initialize];
    
}

- (IBAction)toNotificationView:(UIStoryboardSegue *)segue {
    NSLog(@"toNotificationView");
    NSLog(@"from segue id: %@", segue.identifier);
}


-(void)dealloc {
    NSLog(@"SIGNIN DEALLOCATING");
}

@end
