//
//  SHPUserMenuTVC.m
//  San Vito dei Normanni
//
//  Created by Dario De Pascalis on 15/07/14.
//
//

#import "SHPUserMenuTVC.h"
#import "SHPAppDelegate.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "SHPWebViewController.h"
#import "SHPShareSettingsViewController.h"
#import "SHPFeedbackTextBoxViewController.h"
#import "SHPImageRequest.h"
#import "MBProgressHUD.h"
#import "SHPVerifyUploadPermissionsDC.h"
#import "SHPFirstStepWizardTVC.h"
#import "SHPInfoPage1ViewController.h"
#import "SHPWebViewCartVC.h"
#import "SHPMiniWebBrowserVC.h"
#import "SHPAuthenticationVC.h"
#import "ChatManager.h"
#import "SHPHomeProfileTVC.h"
#import "Appirater.h"

@interface SHPUserMenuTVC ()
@end

@implementation SHPUserMenuTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    userMenuDictionary=[[NSDictionary alloc] init];
    allSections=[[NSMutableArray alloc] init];
    userProfile = [[SHPUser alloc] init];
    [allSections addObject:@" "];
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.titleView = titleLogo;
    self.navigationItem.title = nil;
    [self setupUser];
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    self.applicationContext = appDelegate.applicationContext;
    if(self.applicationContext.loggedUser){
        
        userProfile = self.applicationContext.loggedUser;
        self.fullNameLabel = self.applicationContext.loggedUser.fullName;
        self.userName = self.applicationContext.loggedUser.username;
        self.profileImage = self.applicationContext.loggedUser.photoImage;
        [self setupUser];
         NSLog(@"\n \n -----------1 viewWillAppear  = %@ - %@",  userProfile.httpBase64Auth, self.applicationContext.loggedUser);
    }else{
         NSLog(@"\n \n -----------2 viewWillAppear  = %@ - %@",  userProfile.httpBase64Auth, self.applicationContext.loggedUser);
        userProfile = nil;
        [self.tableView reloadData];
    }
   
}


- (void)initialize {
    NSLog(@"\n ******************** initialize ********************");
    viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    userMenuDictionary = [viewDictionary objectForKey:@"UserMenu"];
    [allSections addObjectsFromArray:[userMenuDictionary allKeys]];
    [allSections addObject:NSLocalizedString(@"log out", nil) ];
    // numero di sezioni del plist più una sezione di login + una sezione di info app
    numberSection = (int)userMenuDictionary.count+2;
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    addObjetFromMenu = [[settingsDictionary valueForKey:@"addObjetFromMenu"] boolValue];

    NSDictionary *informationsDictionary = [viewDictionary objectForKey:@"Informations"];
    copyright = [[NSString alloc] initWithFormat:@"Powered by %@", [informationsDictionary valueForKey:@"copyright"]];
    urlMoreInfo = [informationsDictionary valueForKey:@"urlMoreInfo"];
    nameApp = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    versionApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

-(void)setupUser {
    NSLog(@"NOME COMPLETO: %@ - %@",userProfile.username, userProfile.fullName);
    self.userDC = [[SHPUserDC alloc] init];
    self.userDC.delegate = self;
    [self.userDC findByUsername:self.applicationContext.loggedUser.username];
   
    self.userName = userProfile.username;
    UIImage *cached_image = [self.applicationContext.smallImagesCache getImage:userProfile.photoUrl];
    self.profileImage = cached_image;
    if (!self.profileImage) {
        NSLog(@"photoURL: %@", userProfile.photoUrl);
        SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
        [imageRquest downloadImage:userProfile.photoUrl
                 completionHandler:
         ^(UIImage *image, NSString *imageURL, NSError *error) {
             if (image) {
                 self.profileImage = image;
                 [self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
                 NSLog(@"image ok: %@", self.profileImage);
                 [self.tableView reloadData];
             } else {
                 NSLog(@"no image: %@", image);
             }
         }];
    }else{
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberSection: %d",numberSection);
    return numberSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSLog(@"heightForHeaderInSection: %ld",(long)section);
    if(section == 0){
        return 0;
    }
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSLog(@"titleForHeaderInSection: %@",allSections[section]);
     if(section==numberSection-1){
         return @"";
    }
    NSString *labelSection = NSLocalizedString(allSections[section], nil);
    return labelSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"numberOfRowsInSection: %d: %@",section, allSections[section]);
    if(section==0){
        NSLog(@"section==0");
        return 4;
    }else if(section==(numberSection-1)){
        return 1;
    }else{
        NSLog(@"allSections: %@",allSections[section]);
        NSArray *array = [userMenuDictionary objectForKey:allSections[section]];
        return [array count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    if([identifierCell isEqualToString:@"idCellUser"]){
        if (self.applicationContext.loggedUser){
            return 50.0;
        }else{
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellAdd"]){
//        if(addObjetFromMenu == YES && self.applicationContext.loggedUser && publicUpload== YES){
//            return 50.0;
//        }
//        else if(self.applicationContext.permissionUpload==TRUE && self.applicationContext.loggedUser && publicUpload== NO){
//            return 50.0;
//        }
//        else{
//            return 0.0;
//        }
        return 0.0;
    }
    else if([identifierCell isEqualToString:@"idCellDocument"]){
        if(self.applicationContext.loggedUser && userProfile.urlDocuments){
            return 50.0;
        }else{
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellLogin"]){
        if(self.applicationContext.loggedUser){
            return 0.0;
        }else{
            return 100.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellInfoApp"]){
        return 160.0;
    }
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSArray *arrayRows =[userMenuDictionary objectForKey:allSections[indexPath.section]];
    NSLog(@"arrayRows: %@", arrayRows[indexPath.row]);
    static NSString *CellIdentifier;
    if(indexPath.section==0){
        if(indexPath.row==0){
            CellIdentifier = @"idCellUser";
        }
        else if(indexPath.row==1){
            CellIdentifier = @"idCellAdd";
        }
        else if(indexPath.row==2){
            CellIdentifier = @"idCellDocument";
        }
        else{
            CellIdentifier = @"idCellLogin";
        }
    }else if(indexPath.section == numberSection-1){
        CellIdentifier = @"idCellInfoApp";
    }else{
        CellIdentifier = @"idCellLink";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag:101];
    UIButton *buttonLogin = (UIButton *)[cell viewWithTag:103];
    NSString *label;
    if(indexPath.section==0){
         NSLog(@"cellForRowAtIndexPath 0: %@",indexPath);
        if(indexPath.row==0){
            UILabel *labelFullName = (UILabel *)[cell viewWithTag:102];
            UIImageView *imageProfile = (UIImageView *)[cell viewWithTag:100];
            label = self.userName;
            labelFullName.text = NSLocalizedString(self.fullNameLabel, nil);
            if(self.profileImage){
                imageProfile.image =  self.profileImage;
            }else{
                imageProfile.image = [UIImage imageNamed: @"avatar.png"];
            }
        }
        else if(indexPath.row==1){
//            if(publicUpload==YES){
//                label = NSLocalizedString(@"AddOffert", nil);
//            }else{
//                label = NSLocalizedString(@"ControlPanel", nil);
//            }
            label = NSLocalizedString(@"ControlPanel", nil);
        }
        else if(indexPath.row==2){
            label = NSLocalizedString(@"ShareDocuments", nil);
        }
        else{
            [buttonLogin setTitle:NSLocalizedString(@"Login/Registrati", nil) forState:UIControlStateNormal];
            [buttonLogin addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
            label = NSLocalizedString(@"messaggio login", nil);
        }
    }
    else if(indexPath.section==numberSection-1){
        NSLog(@"cellForRowAtIndexPath 3: %@",indexPath);
        UILabel *labelVer = (UILabel *)[cell viewWithTag:11];
        UILabel *labelPowered = (UILabel *)[cell viewWithTag:12];
        labelVer.text = [NSString stringWithFormat:@"%@ v%@",nameApp,versionApp];
        labelPowered.text = copyright;
        
        UIButton *buttonLogin = (UIButton *)[cell viewWithTag:13];
        [buttonLogin setTitle:NSLocalizedString(@"Altre informazioni", nil) forState:UIControlStateNormal];
        [buttonLogin addTarget:self action:@selector(goToWebView) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        NSLog(@"cellForRowAtIndexPath 1-2: %@",indexPath);
        NSString *link = [arrayRows[indexPath.row] objectForKey:@"link"];
        label = [arrayRows[indexPath.row] objectForKey:@"label"];
        if([link isEqualToString:@"go:rateApp"]){
            label = [NSString stringWithFormat:@"%@ %@?",label,nameApp];
        }
    }
    textLabel.text = NSLocalizedString(label, nil);
    return cell;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:_tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    if([theString isEqualToString:@"idCellUser"]){
        NSLog(@"OK toProfileUser");
        //[self performSegueWithIdentifier:@"toProfileUser" sender:self];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"navigationProfile"];
        SHPHomeProfileTVC *VC = (SHPHomeProfileTVC *)[[nc viewControllers] objectAtIndex:0];
        VC.applicationContext = self.applicationContext;
        VC.user = self.applicationContext.loggedUser;
        [self.navigationController pushViewController:VC animated:YES];
    }
    else if([theString isEqualToString:@"idCellAdd"] && self.applicationContext.loggedUser){
        //NSLog(@"VADO A : toWizardAddOffert");
//        if(publicUpload == YES){
//            [self performSegueWithIdentifier:@"toWizardAddOffert" sender:self];
//        }else{
            webViewHiddenToolBar = YES;
            webViewTitlePage = @"PANNELLO DI CONTROLLO";
            /***********************************************************************************/
            NSDictionary *configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
            NSString *consoleHost = [configDictionary valueForKey:@"consoleHost"];
            NSString *tenantName = [configDictionary valueForKey:@"tenantName"];
            NSString *urlPageConsole = [NSString stringWithFormat:@"http://%@/%@/",consoleHost,tenantName];
            urlPage = urlPageConsole;
            [self performSegueWithIdentifier:@"toWebViewNav" sender:self];
        //}
    }
    else if([theString isEqualToString:@"idCellDocument"]){
        webViewHiddenToolBar = NO;
        webViewTitlePage = NSLocalizedString(@"ShareDocuments", nil);
        urlPage = userProfile.urlDocuments;
        [self performSegueWithIdentifier:@"toWebViewNav" sender:self];
    }
    else if([theString isEqualToString:@"idCellLogin"]){
        [self goToAuthentication];
        //[self performSegueWithIdentifier:@"toLogin" sender:self];
    }
    else if(indexPath.section==numberSection-1){
        NSLog(@"cellForRowAtIndexPath 3: %@",indexPath);
        NSLog(@"LOGOUT");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"SignoutAlertLKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else{
        NSLog(@"cellForRowAtIndexPath 1-2: %@",indexPath);
        /***********************************************************************************/
        NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
        /***********************************************************************************/
        //recupero host del sito da richiamare per caricamento iconcine della lista e per l'url da richiamare nel prepareforsegue
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *configDictionary = [plistDictionary objectForKey:@"Config"];
        NSString *phpextensions_hostSite=[NSString stringWithFormat:@"http://%@",[configDictionary objectForKey:@"phpextensionsHost"]];
        NSString *hostSite=[NSString stringWithFormat:@"http://%@",[configDictionary objectForKey:@"wordpressHost"]];
        NSString *tenant=[configDictionary objectForKey:@"wordpressTenant"];
        NSString *domain=[configDictionary objectForKey:@"serviceDomain"];
        
        NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
        //NSString *phpextensions_hostSite = [thisBundle localizedStringForKey:@"phpextensions.host" value:@"KEY NOT FOUND" table:@"services"];
        NSString *phpextensions_path_ecommerce = [thisBundle localizedStringForKey:@"phpextensions.path_ecommerce" value:@"KEY NOT FOUND" table:@"services"];
        NSString *phpextensions_path_services = [thisBundle localizedStringForKey:@"phpextensions.path_services" value:@"KEY NOT FOUND" table:@"services"];
        
        NSArray *arrayRows =[userMenuDictionary objectForKey:allSections[indexPath.section]];
        NSString *link = [arrayRows[indexPath.row] objectForKey:@"link"];
        
        NSLog(@"************** LINK: %@",link);
        
        if([link hasPrefix:@"http://"]) {
            urlPage=link;
            [self performSegueWithIdentifier:@"toWebView" sender:self];
            //[self performSegueWithIdentifier:@"toWebViewNav" sender:self];
        }
        else if([link hasPrefix:@"go:"]) {
            [self callMethod:[link componentsSeparatedByString:@"go:"][1]];
        }
        else if([link hasPrefix:@"to:"]) {
            NSString *identifier = [link componentsSeparatedByString:@"to:"][1];
            [self performSegueWithIdentifier:identifier sender:self];
        }
        else if([link hasPrefix:@"basicAuth:"]){
            NSString *namePage = [link componentsSeparatedByString:@"basicAuth:"][1];
            urlPage=[NSString stringWithFormat:@"%@/%@/%@?basicAuth=%@&tenant=%@&domain=%@", phpextensions_hostSite, phpextensions_path_services, namePage, self.applicationContext.loggedUser.httpBase64Auth, tenant, domain];
            [self performSegueWithIdentifier:@"toWebViewCart" sender:self];
        }
        else if([link hasPrefix:@"cart:"]){
             NSString *namePage = [link componentsSeparatedByString:@"cart:"][1];
            //urlPage=[NSString stringWithFormat:@"%@%@/%@/%@", hostSite, tenant, langID, link];
            urlPage=[NSString stringWithFormat:@"%@/%@/%@?basicAuth=%@&tenant=%@&domain=%@", phpextensions_hostSite, phpextensions_path_ecommerce, namePage, self.applicationContext.loggedUser.httpBase64Auth, tenant, domain];
            [self performSegueWithIdentifier:@"toWebViewCart" sender:self];
        }
        else{
            urlPage=[NSString stringWithFormat:@"%@/%@/%@/%@", hostSite, tenant, langID, link];
            [self performSegueWithIdentifier:@"toWebView" sender:self];
        }
        
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue: %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"toWebView"]) {
        SHPWebViewController *vc = (SHPWebViewController *)segue.destinationViewController;
        vc.urlPage = urlPage;
        NSLog(@"link page: %@", urlPage);
    }
    else if ([segue.identifier isEqualToString:@"toWebViewCart"]) {
        //SHPCartVC *vc = (SHPCartVC *)segue.destinationViewController;
        UINavigationController *navigationController = [segue destinationViewController];
        SHPWebViewCartVC *vc = (SHPWebViewCartVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.url = urlPage;
        NSLog(@"link page: %@", urlPage);
    }
    else if ([segue.identifier isEqualToString:@"toGeneralView"]) {
        NSLog(@"GO TO GENERAL VIEW");
    }
    else if ([[segue identifier] isEqualToString:@"toLogin"]) {
        NSLog(@"Opening LoginHome...");
        
    }
    else if ([[segue identifier] isEqualToString:@"shareSettingsSegue"]) {
        SHPShareSettingsViewController *vc = (SHPShareSettingsViewController *)segue.destinationViewController;
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"Feedback"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SHPFeedbackTextBoxViewController *vc = (SHPFeedbackTextBoxViewController *)[[navigationController viewControllers] objectAtIndex:0];
        vc.userMenuTVC = self;
        vc.applicationContext = self.applicationContext;
    }
    else if ([segue.identifier isEqualToString:@"toWizardAddOffert"]) {
        NSLog(@"Opening toWizardAddOffert...%@",self.applicationContext);
        SHPFirstStepWizardTVC *vc = (SHPFirstStepWizardTVC *)segue.destinationViewController;
        vc.applicationContext = self.applicationContext;
    }
    else if ([segue.identifier isEqualToString:@"toWebViewNav"]) {
        NSLog(@"Opening toWebViewNav...%@",self.applicationContext);
        /***************************************************************************************************************/
        UINavigationController *navigationController = [segue destinationViewController];
        SHPMiniWebBrowserVC *vc = (SHPMiniWebBrowserVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.hiddenToolBar = webViewHiddenToolBar;
        vc.titlePage = webViewTitlePage;
        vc.urlPage = urlPage;
        NSLog(@"urlPageConsole:  %@",vc.urlPage);
        /***************************************************************************************************************/
    }
    else if ([segue.identifier isEqualToString:@"InfoSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SHPInfoPage1ViewController *vc = (SHPInfoPage1ViewController *)[[navigationController viewControllers] objectAtIndex:0];
        
        //SHPInfoPage1ViewController *vc = (SHPInfoPage1ViewController *)segue.destinationViewController;
        NSLog(@"InfoSegue -> SHPInfoPage1ViewController: %@", self.applicationContext);
        vc.applicationContext = self.applicationContext;
    }
    else if ([segue.identifier isEqualToString:@"toProfileUser"]) {
        //SHPInfoPage1ViewController *vc = (SHPInfoPage1ViewController *)segue.destinationViewController;
        //NSLog(@"InfoSegue -> SHPInfoPage1ViewController: %@", self.applicationContext);
        //vc.applicationContext = self.applicationContext;
    }
}


-(void)callMethod:(NSString *)nameMethod{
    NSLog(@"\n callMethod -> %@", nameMethod);
    if([nameMethod isEqualToString:@"rateApp"]){
        NSLog(@"\n callMethod -> OK");
        //----------------------------------------------------------------------------//
        //START APPIRATER
        //----------------------------------------------------------------------------//
        //https://github.com/arashpayan/appirater/blob/master/README.md
        [Appirater setAppId:appID];
//        [Appirater setDaysUntilPrompt:0];
//        [Appirater setUsesUntilPrompt:0];
//        [Appirater setSignificantEventsUntilPrompt:0];
//        [Appirater setTimeBeforeReminding:0];
        [Appirater setDebug:YES];
        [Appirater appLaunched:YES];
        //----------------------------------------------------------------------------//
        //END APPIRATER
        //----------------------------------------------------------------------------//
    }
}

-(void)goToWebView{
    urlPage = urlMoreInfo;
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}

-(void)goToAuthentication{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    SHPAuthenticationVC *vc = (SHPAuthenticationVC *)[sb instantiateViewControllerWithIdentifier:@"StartAuthentication"];
    vc.applicationContext = self.applicationContext;
    //vc.disableButtonClose = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            break;
        }
        case 1:
        {
            NSLog(@"ESCI");
            [self.applicationContext signout];
            //START LOGOUT CHAT
            ChatManager *chat = [ChatManager getSharedInstance];
            [chat logout];
            //END LOGOUT CHAT
            self.applicationContext.loggedUser=nil;
            self.profileImage = nil;
            [self.tableView reloadData];
            break;
        }
    }
}

-(void)justReported {
    [self showCheckHUD:NSLocalizedString(@"ThanksForReportingMessageLKey", nil)];
}

-(void)showCheckHUD:(NSString *)message {
    MBProgressHUD *thanks_hud = [[MBProgressHUD alloc] initWithWindow:[[[UIApplication sharedApplication] delegate] window]];
    [self.view addSubview:thanks_hud];
    thanks_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox-circle"]];
    thanks_hud.labelText = message;
    thanks_hud.animationType = MBProgressHUDAnimationZoom;
    thanks_hud.mode = MBProgressHUDModeCustomView;
    thanks_hud.center = self.view.center;
    [thanks_hud show:YES];
    [thanks_hud hide:YES afterDelay:1.5];
}


-(void)justRegistered {
    [self initialize];
}

-(void)justSignedIn {
    [self initialize];
}

-(void)usersDidLoad:(NSArray *)__users error:(NSError *) error {
    SHPUser *tmp_user;
    if(__users.count > 0) {
        tmp_user = [__users objectAtIndex:0];
        NSLog(@"USER::: %d",tmp_user.isRivenditore);
        self.applicationContext.loggedUser.urlDocuments = tmp_user.urlDocuments;
        self.applicationContext.loggedUser.fullName = tmp_user.fullName;
        self.applicationContext.loggedUser.isRivenditore = tmp_user.isRivenditore;
        self.applicationContext.loggedUser.productsCreatedByCount = tmp_user.productsCreatedByCount;
        self.applicationContext.loggedUser.productsLikesCount = tmp_user.productsLikesCount;
        self.fullNameLabel = tmp_user.fullName;
        [self.tableView reloadData];
    }
}

- (IBAction)returnPrimo:(UIStoryboardSegue *)segue {
    NSLog(@"primo");
    NSLog(@"from segue id: %@", segue.identifier);
}

- (void)actionLogin:(id)sender {
    [self goToAuthentication];
}

@end
