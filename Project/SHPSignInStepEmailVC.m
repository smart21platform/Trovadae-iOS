//
//  SHPSignInStepEmailVC.m
//  Sogliano Cavour
//
//  Created by dario de pascalis on 30/03/15.
//
//

#import "SHPSignInStepEmailVC.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPStringUtil.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SHPUser.h"
#import "SHPAuthServiceDC.h"
#import "SHPSendTokenDC.h"
#import "SHPSignInTVC.h"
#import "SHPAuthenticationVC.h"
#import "SHPImageUtil.h"


@interface SHPSignInStepEmailVC ()
@end

@implementation SHPSignInStepEmailVC

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
    self.textEmail.delegate = self;
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textEmail becomeFirstResponder];
}

-(void)initialize{
    [self readerPlistConfig];
    //[self.buttonAccedi setTitle:NSLocalizedString(@"ACCEDI", nil) forState:UIControlStateNormal];
    //[self.buttonIscriviti setTitle:NSLocalizedString(@"ISCRIVITI", nil) forState:UIControlStateNormal];
    [self.buttonNext setTitle:NSLocalizedString(@"Avanti", nil) forState:UIControlStateNormal];
    [self.buttonFacebook setTitle:NSLocalizedString(@"Accedi con Facebook", nil) forState:UIControlStateNormal];
    self.textEmail.placeholder = NSLocalizedString(@"Inserisci la tua e-mail", nil);
    
    if(self.disableButtonClose == NO){
        [self.buttonClose setTitle:NSLocalizedString(@"CHIUDI", nil) forState:UIControlStateNormal];
    }else{
        [self disableButton:self.buttonClose];
    }
    
    [self.textEmail becomeFirstResponder];
    [self addControllChangeTextField:self.textEmail];
    [self enableButton:self.buttonFacebook];
    [self disableButton:self.buttonNext];
}

-(void)readerPlistConfig{
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settingsAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    NSDictionary *header_config = [plistDictionary objectForKey:@"Header"];
    NSString *title = [header_config objectForKey:@"title"];
    NSString *titleFont = [header_config objectForKey:@"titleFont"];
    CGFloat titleFontSize = [[header_config objectForKey:@"titleFontSize"] floatValue];
    NSString *titleFontColor = [header_config objectForKey:@"titleFontColor"];
    NSString *description = [header_config objectForKey:@"description"];
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
//--------------------------------------------------//
//START TEXTFIELD CONTROLLER
//--------------------------------------------------//

-(void)customFontLabel:(UILabel*)label font:(NSString*)font fontSize:(CGFloat)fontSize color:(NSString*)color {
    [label setFont:[UIFont fontWithName:font size:fontSize]];
    UIColor *textColor = [SHPImageUtil colorWithHexString:color];
    [label setTextColor:textColor];
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

-(void)addControllChangeTextField:(UITextField *)textField
{
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

-(void)textFieldDidChange:(UITextField *)textField{
    if ([self.textEmail.text length]>0) {
        [self disableButton:self.buttonFacebook];
        [self enableButton:self.buttonNext];
    }
    else{
        [self enableButton:self.buttonFacebook];
        [self disableButton:self.buttonNext];
    }
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
    self.labelError.text = msg;
    self.viewError.alpha = 0.0;
    [self disableButton:self.buttonClose];
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
//START FACEBOOK LOGIN
//--------------------------------------------------------------------//
-(void)facebookLogin{
    [self showWaiting:NSLocalizedString(@"AuthenticatingLKey", nil)];
    NSLog(@"opening facebook session...");
    __weak SHPSignInStepEmailVC *weakSelf = self;
    [FBSession openActiveSessionWithReadPermissions:
    [[NSArray alloc] initWithObjects:@"public_profile", @"email", @"user_friends", nil]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [weakSelf sessionStateChanged:session state:state error:error];
                                  }];
    
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    NSString *errorFacebook;
    NSLog(@"----------------sessionStateChanged------------>: %@", errorFacebook);
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"Session token---------------------------->: %@", session.accessTokenData.accessToken);
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
//            NSLog(@"Name: %@", my.name);
//            NSLog(@"UserName: %@", my.username);
//            NSLog(@"Email: %@", [my objectForKey:@"email"]);
//            NSLog(@"User id - [my objectForKey:@'id']: %@", [my objectForKey:@"id"]);
//            NSLog(@"self.fbUserId: %@", self.fbUserId);
//            NSLog(@"pictureUrl %@", self.fbPictureUrl);
            
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

//--------------------------------------------------------------------//
//START SEND LOGIN AND PSW
//--------------------------------------------------------------------//
-(void)didSignedIn:(SHPUser *)user {
    NSLog(@"didSignedIn........................");
    [self prepareSignedUser:user];
}

-(void)prepareSignedUser:(SHPUser *)user {
    NSLog(@"prepareSignedUser. %@",self.applicationContext);
    [self.applicationContext signin:user];
    [self performSegueWithIdentifier:@"returnToAuthenticationVC" sender:self];
    //[self dismissViewControllerAnimated:YES completion:^{}];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"returnToAuthenticationVC"]) {

    }
    else if ([[segue identifier] isEqualToString:@"toSignInUser"]) {
        NSLog(@"Signin SEGUE");
        UINavigationController *nc = [segue destinationViewController];
        SHPSignInTVC *vc = (SHPSignInTVC *)[[nc viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
         if ([self.textEmail.text length]>0){
            vc.emailUser = self.textEmail.text;
        }else{
            vc.fbUserEmail = self.fbUserEmail;
            vc.fbName = self.fbName;
            vc.fbUsername = self.fbUsername;
            vc.fbUserId = self.fbUserId;
            vc.fbPictureUrl = self.fbPictureUrl;
            vc.fbAccessToken = self.fbAccessToken;
            vc.userFB = self.userFB;
        }
    }
}


- (IBAction)actionClose:(id)sender {
      [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)actionFacebook:(id)sender {
    [self facebookLogin];
}

- (IBAction)actionAccedi:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)actionNext:(id)sender {
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![SHPStringUtil validEmail:emailValue]) {
        NSString *msg = NSLocalizedString(@"Email non corretta", nil);
        [self animationMessageError:msg];
    }else{
        [self performSegueWithIdentifier:@"toSignInUser" sender:self];
    }
}

-(void)dealloc {
    NSLog(@"SIGNIN DEALLOCATING SHPSignInStepEmailVC");
}

@end
