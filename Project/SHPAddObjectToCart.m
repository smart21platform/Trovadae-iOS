//
//  SHPAddObjectToCart.m
//  Eurofood
//
//  Created by Dario De Pascalis on 10/09/14.
//
//

#import "SHPAddObjectToCart.h"
#import "SHPAppDelegate.h"
#import "SHPImageUtil.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "SHPProduct.h"
#import "SHPProductDetail.h"

@interface SHPAddObjectToCart ()

@end

@implementation SHPAddObjectToCart

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
    [self.navigationItem setHidesBackButton:YES];
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    self.webView.delegate=self;
    
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarNavigation"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    /***********************************************************************************/
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    bool statusBarStyle = [[settingsDictionary objectForKey:@"setStatusBarStyle"] boolValue];
    if(statusBarStyle == YES){
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }else{
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    /***********************************************************************************/
    //    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    //    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.title = @"SELEZIONA LA QUANTITA'";//titleLogo;
    [self.navigationItem.rightBarButtonItem setTintColor:tintColor];
    [self.navigationItem.leftBarButtonItem setTintColor:tintColor];
    //[self.navigationItem.titleView setTintColor:tintColor];
    /***********************************************************************************/
    NSLog(@"viewDidLoad-USER: %@",self.applicationContext.loggedUser);
    [self initialize];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    //[self initialize];
}

- (void)initialize {
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [activityIndicator startAnimating];
    /***********************************************************************************/
    NSDictionary *configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    hostSite=[NSString stringWithFormat:@"http://%@",[configDictionary objectForKey:@"phpextensionsHost"]];
    tenant=[configDictionary objectForKey:@"wordpressTenant"];
    domain=[configDictionary objectForKey:@"serviceDomain"];
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    //hostSite = [thisBundle localizedStringForKey:@"phpextensions.host" value:@"KEY NOT FOUND" table:@"services"];
    pathEcommerce = [thisBundle localizedStringForKey:@"phpextensions.path_ecommerce" value:@"KEY NOT FOUND" table:@"services"];
    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    NSDictionary *ecommerceDictionary = [viewDictionary objectForKey:@"Ecommerce"];
    urlPageAddToCart = [ecommerceDictionary valueForKey:@"urlPageAddToCart"];
    /***************************************************************************************************************/
    
    NSString *available = [self.product returnProperty:@"available"];
    NSString *personalCod = [self.product returnProperty:@"codEurofood"];
    NSString *orderable = [self.product returnProperty:@"orderable"];
    
    NSString *urlWeb=[NSString stringWithFormat:@"%@%@/%@?basicAuth=%@&tenant=%@&domain=%@&productId=%@&available=%@&personalCod=%@&orderable=%@&price=%@&title=%@", hostSite, pathEcommerce, urlPageAddToCart, self.applicationContext.loggedUser.httpBase64Auth, tenant, domain, self.product.oid, available, personalCod, orderable, self.product.price, self.product.title];
    NSString *urlAddToCart = [urlWeb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlAddToCart:%@", urlAddToCart);
    NSURL *url = [NSURL URLWithString:urlAddToCart];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    /***************************************************************************************************************/
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [activityIndicator stopAnimating];
    //self.navigationItem.rightBarButtonItem = refreshButtonItem;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    [activityIndicator stopAnimating];
    //self.navigationItem.rightBarButtonItem = refreshButtonItem;
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    NSLog(@"url %@", url );//[url scheme]);
    if([[url scheme] isEqualToString:@"segue"]) {
        NSLog(@"host %@", [url host] );
        if ([[url host] isEqualToString:@"back"]) {
            NSLog(@"query %@", [url query] );
            NSArray *response = [[url query] componentsSeparatedByString: @"="];
            NSLog(@"key:%@",response);
            if([response[0] isEqual:@"response"]){
                responseAddProdToCart = response[1]; //[[NSString alloc] initWithData:response[1] encoding:NSUTF8StringEncoding];
            }
            [self performSegueWithIdentifier:@"returnToProductDetail" sender:self];
        }
    }
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"returnToProductDetail"]){
        SHPProductDetail *vc = [segue destinationViewController];
        //vc.responseAddProdToCart = responseAddProdToCart;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
