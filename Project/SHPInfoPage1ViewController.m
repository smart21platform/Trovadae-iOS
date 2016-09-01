//
//  SHPInfoPage1ViewController.m
//  Dressique
//
//  Created by andrea sponziello on 21/03/13.
//
//

#import "SHPInfoPage1ViewController.h"
#import "SHPComponents.h"
#import <QuartzCore/QuartzCore.h>
#import "SHPImageUtil.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPMiniWebBrowserVC.h"

@interface SHPInfoPage1ViewController ()
@end

@implementation SHPInfoPage1ViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    
    
    NSLog(@"self.applicationContext = %@",self.applicationContext);
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarNavigation"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    colorBackground = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"colorBackground"]];
    
    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    NSDictionary *informationsDictionary = [viewDictionary objectForKey:@"Informations"];
    urlWebSite = [informationsDictionary valueForKey:@"urlWebSite"];
    copyright = [informationsDictionary valueForKey:@"copyright"];
    claim = [informationsDictionary valueForKey:@"claim"];
    email = [informationsDictionary valueForKey:@"email"];
    phoneNumber = [informationsDictionary valueForKey:@"phoneNumber"];
    smartphoneNumber = [informationsDictionary valueForKey:@"smartphoneNumber"];
    urlMoreInfo = [informationsDictionary valueForKey:@"urlMoreInfo"];
    [self inizialize];
    
}

-(void)inizialize{
    // Do any additional setup after loading the view.
    //[self customizeTitle:@"Benvenuto"];
    NSLog(@"version = %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]);
   // NSString *nameApp = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *versionApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    self.labelVersion.text = [NSString stringWithFormat:@"Ver %@",versionApp];
    
    self.close.tintColor = tintColor;
    self.labelCopyright.text = [[NSString alloc] initWithFormat:@"Powered by\n%@", copyright];
    self.labelClaim.text = claim;
    
    [self.buttonWebPage setTitle:urlWebSite forState:UIControlStateNormal];
    [self.buttonEmail setTitle:email forState:UIControlStateNormal];
    [self.buttonCell1 setTitle:phoneNumber forState:UIControlStateNormal];
    [self.buttonCell2 setTitle:smartphoneNumber forState:UIControlStateNormal];
    
    [self.imageLogo setBackgroundColor:colorBackground];
    
    
}

-(void)customizeTitle:(NSString *)title {
    self.navigationItem.title = title;
    UILabel *navTitleLabel = [SHPComponents appTitleLabel:title withSettings:self.applicationContext.settings];
    self.navigationItem.titleView = navTitleLabel;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue: %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"toWebViewNav"]) {
        NSLog(@"Opening toWebViewNav...%@",self.applicationContext);
        /***************************************************************************************************************/
        UINavigationController *navigationController = [segue destinationViewController];
        SHPMiniWebBrowserVC *vc = (SHPMiniWebBrowserVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.hiddenToolBar = YES;
        vc.titlePage = @"";
        vc.urlPage = urlMoreInfo;
        NSLog(@"urlPageConsole:  %@",vc.urlPage);
        /***************************************************************************************************************/
    }
}

//-------------------------------------------------------------//

-(void)callNumberTelephon:(NSString *)numberTelephone{
    NSString *telURL = [[NSString alloc] initWithFormat:@"tel://%@", numberTelephone];
    telURL = [telURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Sto chiamando %@...", telURL);
    NSURL *url = [NSURL URLWithString:telURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionPhoneNumber1:(id)sender {
    [self callNumberTelephon:self.buttonCell1.titleLabel.text];
}

- (IBAction)actionPhoneNumber2:(id)sender {
    [self callNumberTelephon:self.buttonCell2.titleLabel.text];
}

- (IBAction)actionToWebSite:(id)sender {

    NSLog(@"show website %@", urlWebSite);
    if (urlWebSite  && ![urlWebSite  isEqualToString:@""]) {
        //NSString *url = [NSString stringWithFormat:@"%@", self.buttonWebSiteApp.titleLabel.text];
         NSString *url = [NSString stringWithFormat:@"http://%@", urlWebSite];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        //self.buttonWebSiteApp.titleLabel.text = urlWebSite;
    }
    
}

- (IBAction)actionMoreInfo:(id)sender {
    [self performSegueWithIdentifier:@"toWebViewNav" sender:self];
}

- (IBAction)emailAction:(id)sender {
    NSLog(@"send email");
    if (self.buttonEmail.titleLabel.text  && ![self.buttonEmail.titleLabel.text  isEqualToString:@""]) {
        NSString *url = [NSString stringWithFormat:@"mailto:%@", self.buttonEmail.titleLabel.text];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

- (IBAction)websiteAction:(id)sender {
    NSLog(@"show website %@", urlWebSite);
    NSString *url;
    if (urlWebSite  && ![urlWebSite  isEqualToString:@""]) {
        if(![urlWebSite hasPrefix:@"http"]){
            url = [NSString stringWithFormat:@"http://%@", urlWebSite];
        }else{
            url = urlWebSite;
        }
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}


- (IBAction)DoneAction:(id)sender {
    [self dismiss];
}

- (IBAction)CloseButtonAction:(id)sender {
    [self dismiss];
}


-(void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)openDressiqueInAppStore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/Dressique"]];
}

@end
