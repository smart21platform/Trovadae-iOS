//
//  SHPAuthenticationVC.m
//  Sogliano Cavour
//
//  Created by dario de pascalis on 26/03/15.
//
//

#import "SHPAuthenticationVC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "DDPWebPagesVC.h"
#import "SHPUser.h"
#import "SHPSigninServiceDC.h"
#import "MBProgressHUD.h"
#import "SHPSendTokenDC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SHPAuthServiceDC.h"
#import "SHPAuthServiceDCDelegate.h"
#import "SHPSignInTVC.h"
#import "SHPSignInStepEmailVC.h"
#import "SHPImageUtil.h"

@interface SHPAuthenticationVC ()
@end

@implementation SHPAuthenticationVC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    self.textUsername.delegate = self;
    self.textPassword.delegate = self;
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSLog(@"viewWillAppear:::::loggerUser %@",self.applicationContext.loggedUser);
    if (self.applicationContext.loggedUser) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//}


-(void)initialize{
    [self readerPlistConfig];
    [self.buttonRemember setTitle:NSLocalizedString(@"password dimenticata?", nil) forState:UIControlStateNormal];
    [self.buttonFacebook setTitle:NSLocalizedString(@"Accedi con Facebook", nil) forState:UIControlStateNormal];
    self.textUsername.placeholder = NSLocalizedString(@"Nome utente o Email", nil);
    self.textPassword.placeholder = NSLocalizedString(@"Password", nil);
    
    [self addGestureRecognizerToView];
    [self addControllChangeTextField:self.textUsername];
    [self addControllChangeTextField:self.textPassword];
    //[self.textUsername becomeFirstResponder];
    NSLog(@"activeButtonClose: %d", self.disableButtonClose);
    if(self.disableButtonClose == NO){
        [self.buttonClose setTitle:NSLocalizedString(@"CHIUDI", nil) forState:UIControlStateNormal];
    }else{
        [self disableButton:self.buttonClose];
    }
        
    [self enableButton:self.buttonRemember];
    [self disableButton:self.buttonEnter];
    //[self prefersStatusBarHidden];
    //[self readerPlist];
}

//-(BOOL)prefersStatusBarHidden{
//    return NO;
//}

-(void)readerPlistConfig{
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settingsAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    NSDictionary *header_config = [plistDictionary objectForKey:@"Header"];
    NSString *title = [header_config objectForKey:@"title"];
    NSString *titleFont = [header_config objectForKey:@"titleFont"];
    CGFloat titleFontSize = [[header_config objectForKey:@"titleFontSize"] floatValue];
    NSString *titleFontColor = [header_config objectForKey:@"titleFontColor"];
   // NSString *description = [header_config objectForKey:@"description"];
    NSString *description = NSLocalizedString(@"messaggio login", nil);
    NSString *descriptionFont = [header_config objectForKey:@"descriptionFont"];
    CGFloat descriptionFontSize = [[header_config objectForKey:@"descriptionFontSize"] floatValue];
    NSString *descriptionFontColor = [header_config objectForKey:@"descriptionFontColor"];
    NSString *buttonFont = [header_config objectForKey:@"buttonFont"];
    CGFloat buttonFontSize = [[header_config objectForKey:@"buttonFontSize"] floatValue];
    NSString *buttonFontColor = [header_config objectForKey:@"buttonFontColor"];
    
    self.labelHeaderTitle.text = title;
    [self customFontLabel:self.labelHeaderTitle font:titleFont fontSize:titleFontSize color:titleFontColor];
    
    self.labelHeaderDescription.text = description;
    [self customFontLabel:self.labelHeaderDescription font:descriptionFont fontSize:descriptionFontSize color:descriptionFontColor];
    
    [self.buttonAccedi setTitle:NSLocalizedString(@"ACCEDI", nil) forState:UIControlStateNormal];
    [self customFontLabel:self.buttonAccedi.titleLabel font:buttonFont fontSize:buttonFontSize color:buttonFontColor];
    [self.buttonIscriviti setTitle:NSLocalizedString(@"ISCRIVITI", nil) forState:UIControlStateNormal];
    [self customFontLabel:self.buttonIscriviti.titleLabel font:buttonFont fontSize:buttonFontSize color:buttonFontColor];

}

-(NSString *)readerPlistForUrlRememberPsw{
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settingsAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    NSDictionary *settings_config = [plistDictionary objectForKey:@"Settings"];
    NSString *urlRememberPsw = [settings_config objectForKey:@"urlRememberPsw"];
    return urlRememberPsw;
    //NSString *urlPrivacy = [settings_config objectForKey:@"urlPrivacy"];
}

//--------------------------------------------------//
//START TEXTFIELD CONTROLLER
//--------------------------------------------------//
-(void)customFontLabel:(UILabel*)label font:(NSString*)font fontSize:(CGFloat)fontSize color:(NSString*)color {
    [label setFont:[UIFont fontWithName:font size:fontSize]];
    UIColor *textColor = [SHPImageUtil colorWithHexString:color];
    [label setTextColor:textColor];
    //[label setBackgroundColor:[UIColor clearColor]];
    //[label setText:@"Loading ..."];
    //[self.view addSubview:loading];
}

-(void)addGestureRecognizerToView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)
                                   ];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard{
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

//
-(void)addControllChangeTextField:(UITextField *)textField
{
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}
//


-(void)textFieldDidChange:(UITextField *)textField{
    if (textField.tag == 2 && ([self.textPassword.text length]>0)) {
        [self disableButton:self.buttonRemember];
        [self enableButton:self.buttonEnter];
    }
    else if(([self.textPassword.text length]>0) && ([self.textUsername.text length]>0)){
        [self disableButton:self.buttonRemember];
        [self enableButton:self.buttonEnter];
    }else{
        [self enableButton:self.buttonRemember];
        [self disableButton:self.buttonEnter];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if([self.textUsername.text length]==0){
        NSLog(@"textFieldDidBeginEditing");
        [self enableButton:self.buttonRemember];
        [self disableButton:self.buttonEnter];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    [self actionLogin];
    return YES;
}

-(UIButton *)enableButton:(UIButton *)button{
    button.enabled = YES;
    button.hidden = NO;
    [button setAlpha:1];
    return button;
}

-(UIButton *)disableButton:(UIButton *)button{
    button.enabled = NO;
    button.hidden = YES;
    [button setAlpha:0.5];
    return button;
}
//--------------------------------------------------//
//END TEXTFIELD CONTROLLER
//--------------------------------------------------//

//--------------------------------------------------//
//START FUNCTIONS
//--------------------------------------------------//
-(void)animationMessageError:(NSString *)msg{
    self.buttonEnter.enabled = NO;
    [self disableButton:self.buttonClose];
    self.labelError.text = msg;
    self.viewError.alpha = 0.0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.viewError.alpha = 0.9;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:3.0
                                          animations:^{
                                              self.viewError.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.5
                                                               animations:^{
                                                                   self.viewError.alpha = 0.0;
                                                                   [self enableButton:self.buttonEnter];
                                                                   [self enableButton:self.buttonClose];
                                                               }];
                                          }];
                     }];
    
}

-(void)showWaiting:(NSString *)label {
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:self.hud];
    }
    self.hud.center = self.view.center;
    self.hud.labelText = label;
    self.hud.animationType = MBProgressHUDAnimationZoom;
    [self.hud show:YES];
}

-(void)hideWaiting {
    [self.hud hide:YES];
}
//--------------------------------------------------//
//END FUNCTIONS
//--------------------------------------------------//


//--------------------------------------------------------------------//
//START SEND LOGIN AND PSW
//--------------------------------------------------------------------//
-(void)sendLoginAndPsw{
    NSLog(@"actionEnter...");
    [self showWaiting:NSLocalizedString(@"AuthenticatingLKey", nil)];
    [self.buttonEnter setEnabled:NO];
    SHPSigninServiceDC *dc = [[SHPSigninServiceDC alloc] init];
    dc.delegate = self;
    NSString *username = [self.textUsername.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.textPassword.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    SHPUser *user = [[SHPUser alloc] init];
    user.username = username;
    [dc signinWith:user andPassword:password];
}

-(void)signedin:(SHPUser *)justSignedUser {
    NSLog(@"Signin successfull!");
    [self hideWaiting];
    [self didSignedIn:justSignedUser];
}

-(void)didSignedIn:(SHPUser *)user {
    NSLog(@"didSignedIn........................");
    [self prepareSignedUser:user];
}

-(void)prepareSignedUser:(SHPUser *)user {
    NSLog(@"prepareSignedUser. %@",self.applicationContext);
    [self.applicationContext signin:user];
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
    [self hideWaiting];
    [self registerOnProviderForNotifications];
}

-(void)registerOnProviderForNotifications {
    SHPSendTokenDC *tokenDC = [[SHPSendTokenDC alloc] init];
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *devToken = appDelegate.deviceToken;
    if (devToken) {
        [tokenDC sendToken:devToken withUser:self.applicationContext.loggedUser lang:langID completionHandler:^(NSError *error) {
            if (!error) {
                NSLog(@"Successfully registered DEVICE to Provider WITH USER.");
            }
            else {
                NSLog(@"Error while registering devToken to Provider!");
            }
        }];
    }
}

//--------------------------------------------------------------------//
//END SEND LOGIN AND PSW
//--------------------------------------------------------------------//

//--------------------------------------------------------------------//
//DELEGATE CALLED BY [dc signinWith:user andPassword:password];
//--------------------------------------------------------------------//
-(void)signinServiceDCSignedIn:(SHPUser *)user error:(NSError *) error {
    if (!error) {
        NSLog(@"Signed in! %@", user);
        [self signedin:user];
    } else if (error.code == 900) {
        NSLog(@"Signin error! %@", error);
        [self hideWaiting];
        NSString *msg = NSLocalizedString(@"UseramePasswordInvalidLKey", nil);
        [self animationMessageError:msg];
        //[self.buttonEnter setEnabled:YES];
    } else if (error.code == -1009 ) {
        [self hideWaiting];
        NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
        [self animationMessageError:msg];
        //[self.buttonEnter setEnabled:YES];
    } else {
        [self hideWaiting];
        NSString *msg = NSLocalizedString(@"UnknownErrorLKey", nil);
        [self animationMessageError:msg];
        //[self.buttonEnter setEnabled:YES];
    }
}
//--------------------------------------------------------------------//
//END DELEGATE
//--------------------------------------------------------------------//


//--------------------------------------------------------------------//
//START FACEBOOK LOGIN
//--------------------------------------------------------------------//
-(void)facebookLogin{
    [self showWaiting:NSLocalizedString(@"AuthenticatingLKey", nil)];
    NSLog(@"opening facebook session...");
    __weak SHPAuthenticationVC *weakSelf = self;
    [FBSession openActiveSessionWithReadPermissions:
    [[NSArray alloc] initWithObjects:@"public_profile", @"email", @"user_friends", nil]
                                        allowLoginUI:YES
                                        completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                            [weakSelf sessionStateChanged:session state:state error:error];
                                        }];
}


//-(void)facebookLogin{
//    FBSDKLoginManager *login = [FBSDKLoginManager alloc] init];
//    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        if (error) {
//            // Process error
//        } else if (result.isCancelled) {
//            // Handle cancellations
//        } else {
//            // If you ask for multiple permissions at once, you
//            // should check if specific permissions missing
//            if ([result.grantedPermissions containsObject:@"email"]) {
//                // Do work
//            }
//        }
//    }];
//}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    NSString *errorFacebook;
    NSLog(@"----------------sessionStateChanged------------>: %@", errorFacebook);
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"facebookAccessToken ---------------------------->: %@", session.accessTokenData.accessToken);
            self.fbAccessToken = session.accessTokenData.accessToken;
            SHPUser *fbUser = [[SHPUser alloc] init];
            fbUser.facebookAccessToken = self.fbAccessToken;
            self.authDC = [[SHPAuthServiceDC alloc] init];
            self.authDC.authServiceDelegate = self;
            [self.authDC findFacebookUser:fbUser];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        [self hideWaiting];
        NSLog(@"Alerting the error with a popup... %@", error);
        NSString *errorFacebook =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"FacebookConnectionError", nil), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
        [self animationMessageError:errorFacebook];
    }
}

//DELEGATE from: self.authDC findFacebookUser
-(void)authServiceDCFacebookUser:(SHPUser *)user found:(BOOL)found {
    if (found) {
        NSLog(@"User found...USER : %@ ",user);
        [self didSignedIn:user];
    } else {
        // register
        NSLog(@"User not found...request user data > register...USER : %@ ",user.photoUrl);
        [self requestUserDataForRegistration];
    }
}



-(void)requestUserDataForRegistration {
    NSString *requestPath = @"me/?fields=name,id,email,location,picture";
    FBRequest *me = [FBRequest requestForGraphPath:requestPath];
    [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                      NSDictionary<FBGraphUser> *my,
                                      NSError *error) {
        [self hideWaiting];
        if (!error) {
            NSLog(@"User data retriving successfull: %@", my);
            self.fbName = [my objectForKey:@"name"];//my.name;
            self.fbUsername = @"";//my.username;
            self.fbUserEmail = [my objectForKey:@"email"];
            self.fbUserId = [my objectForKey:@"id"];
            self.fbPictureUrl = [my objectForKey:@"picture"];
            [self performSegueWithIdentifier:@"toSignInUser" sender:self];
        } else {
            NSString *errorFacebook =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"A Request Error occurred:", nil), error];
            [self animationMessageError:errorFacebook];
            NSLog(@"A Request Error occurred: %@", error);
        }
    }];
}
//--------------------------------------------------------------------//
//END FACEBOOK LOGIN
//--------------------------------------------------------------------//


-(NSString*)getUrlPageRememberPassword{
    NSDictionary *configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    NSString *hostSite = [NSString stringWithFormat:@"http://%@",[configDictionary objectForKey:@"phpextensionsHost"]];
    NSString *tenant = [configDictionary objectForKey:@"wordpressTenant"];
    NSString *domain = [configDictionary objectForKey:@"serviceDomain"];
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [thisBundle localizedStringForKey:@"phpextensions.path_services" value:@"KEY NOT FOUND" table:@"services"];
    
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    NSString *urlPageForgotPassword = [settingsDictionary valueForKey:@"urlPageForgotPassword"];
    NSString *urlWeb=[NSString stringWithFormat:@"%@%@/%@?tenant=%@&domain=%@", hostSite, path, urlPageForgotPassword, tenant, domain];
    NSString *urlForgotPassword = [urlWeb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlForgotPassword:%@", urlForgotPassword);
    return urlForgotPassword;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toSignInEmail"]) {
        NSLog(@"prepareForSegue toSignInUser");
        SHPSignInStepEmailVC *vc = (SHPSignInStepEmailVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.disableButtonClose = self.disableButtonClose;
        vc.labelHeaderTitle = self.labelHeaderTitle;
        vc.labelHeaderDescription = self.labelHeaderDescription;
        vc.buttonAccedi = self.buttonAccedi;
        vc.buttonIscriviti = self.buttonIscriviti;
        
    }
    else if ([[segue identifier] isEqualToString:@"toWebView"]) {
        UINavigationController *nc = [segue destinationViewController];
        DDPWebPagesVC *vc = (DDPWebPagesVC *)[[nc viewControllers] objectAtIndex:0];
        vc.urlPage = [self readerPlistForUrlRememberPsw];//[self getUrlPageRememberPassword];
    }
    else if ([[segue identifier] isEqualToString:@"toSignInUser"]) {
        NSLog(@"Signin SEGUE");
        UINavigationController *nc = [segue destinationViewController];
        SHPSignInTVC *vc = (SHPSignInTVC *)[[nc viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.fbUserEmail = self.fbUserEmail;
        vc.fbName = self.fbName;
        vc.fbUsername = self.fbUsername;
        vc.fbUserId = self.fbUserId;
        vc.fbPictureUrl = self.fbPictureUrl;
        vc.fbAccessToken = self.fbAccessToken;
        vc.userFB = self.userFB;
        
    }

}


-(void)actionLogin{
    self.buttonEnter.enabled = NO;
    if([self.textPassword.text length]>0 && [self.textUsername.text length]>0){
        NSLog(@"INVIA actionLogin");
        [self sendLoginAndPsw];
    }else{
        NSString *msg = NSLocalizedString(@"UseramePasswordInvalidLKey", nil);
        [self animationMessageError:msg];
    }
}


- (IBAction)actionFacebook:(id)sender {
    [self facebookLogin];
}

- (IBAction)actionRemember:(id)sender {
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}

- (IBAction)actionIscriviti:(id)sender {
     NSLog(@"actionIscriviti");
    [self performSegueWithIdentifier:@"toSignInEmail" sender:self];
}

- (IBAction)actionEnter:(id)sender {
    NSLog(@"actionEnter");
    [self actionLogin];
}

- (IBAction)actionClose:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindToAuthentication:(UIStoryboardSegue*)sender
{
    NSLog(@"unwindToAuthentication:");
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[UIView setAnimationsEnabled:YES];//SETTATO A NO NELLA VIEW CHIAMANTE
}

-(void)dealloc {
    NSLog(@"SIGNIN DEALLOCATING");
    self.textUsername.delegate = nil;
    self.textPassword.delegate = nil;
}

//metodi non utilizzati anti warning
-(void)authServiceDCErrorWithCode:(NSString *)code{
}

@end
