//
//  SHPSignInTVC.m
//  Sogliano Cavour
//
//  Created by dario de pascalis on 27/03/15.
//
//

#import "SHPSignInTVC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPImageUtil.h"
#import "SHPComponents.h"
#import "SHPUser.h"
#import "SHPImageRequest.h"
#import "MBProgressHUD.h"
#import "SHPStringUtil.h"
#import "SHPServiceUtil.h"
#import "SHPConstants.h"
#import "SHPSendTokenDC.h"
#import "DDPWebPagesVC.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SHPSignInTVC ()
@end

@implementation SHPSignInTVC



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
    USERNAME_MIN_LENGTH = 6;
    PASSWORD_MIN_LENGTH = 6;
    NAME_MIN_LENGTH = 1;
    
    self.textEmail.delegate = self;
    self.textUsername.delegate = self;
    self.textPassword.delegate = self;
    self.textNameComplete.delegate = self;
    self.textTelephone.delegate = self;

    [SHPComponents titleLogoForViewController:self];
    [self initialize];
}

-(void)initialize
{
    [SHPImageUtil arroundImage:(self.viewPhotoUser.frame.size.height/2) borderWidth:0.0 layer:[self.viewPhotoUser layer]];
    [SHPImageUtil arroundImage:(self.imageProfile.frame.size.height/2) borderWidth:0.0 layer:[self.imageProfile layer]];
    UIColor *borderColor = [SHPImageUtil colorWithHexString:@"4E6CA7"];
    [[self.imageProfile layer] setBorderColor:[borderColor CGColor]];
    self.imageProfile.userInteractionEnabled = TRUE;
    
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapImage)];
    [self.imageProfile addGestureRecognizer:tapRec];
    
    NSLog(@"USERID FB: %@", self.fbUserId);
    [self resetUserPhoto];
    if(self.fbUserId){
        [self loadImageProfileFB:self.fbUserId];
        [self loadImageCoverFB:self.fbUserId];
        self.textEmail.text = self.fbUserEmail;
        self.textNameComplete.text = self.fbName;
    }else{
        self.textEmail.text = self.emailUser;
    }
    
    [self.buttonPrivacy setTitle:NSLocalizedString(@"accetta la normativa sulla privacy", nil) forState:UIControlStateNormal];
    self.textEmail.placeholder = NSLocalizedString(@"Inserisci la tua e-mail", nil);
    self.textUsername.placeholder = NSLocalizedString(@"Crea un nome utente", nil);
    self.textNameComplete.placeholder = NSLocalizedString(@"Nome completo", nil);
    self.textPassword.placeholder = NSLocalizedString(@"Crea una password", nil);
    //self.textPassword.placeholder = NSLocalizedString(@"Crea una password", nil);
//    [self addControllChangeTextField:self.textEmail];
//    [self addControllChangeTextField:self.textUsername];
//    [self addControllChangeTextField:self.textPassword];
//    [self addControllChangeTextField:self.textNameComplete];
    

}

//-------------------------------------------------------------------//
//START FUNCTION
//-------------------------------------------------------------------//
-(void)loadImageProfileFB:(NSString *)idFacebook
{
    SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
    NSString *fbProfilePictureURL = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large", idFacebook];
    [imageRequest downloadImage:fbProfilePictureURL
              completionHandler:
     ^(UIImage *image, NSString *imageURL, NSError *error) {
         if (image) {
             self.imageProfile.image = image;
             [self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
         } else {
             NSLog(@"Image not loaded!");
             //self.imageProfile.image = [UIImage imageNamed:@"noProfile"];
             //put an image that indicates "no image profile"
         }
     }];
}

-(void)loadImageCoverFB:(NSString *)idFacebook
{
    /* make the API call */
    NSString *urlRequest =[[NSString alloc] initWithFormat:@"/%@?fields=cover", idFacebook];
    [FBRequestConnection startWithGraphPath:urlRequest //@"...?fields={fieldname_of_type_CoverPhoto}"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSDictionary *userCover = [result valueForKey:@"cover"];
                              NSString *urlCover = [userCover valueForKey:@"source"];
                              NSLog(@"result! %@",urlCover);
                              
                              SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
                              [imageRequest downloadImage:urlCover
                                        completionHandler:
                               ^(UIImage *image, NSString *imageURL, NSError *error) {
                                   if (image) {
                                      
                                       //UIImageView *tempImageView = [[UIImageView alloc] init];
                                       //[tempImageView setContentMode: UIViewContentModeScaleAspectFill];
                                       //tempImageView.frame = CGRectMake(self.imageBackground.frame.origin.x, self.imageBackground.frame.origin.y, self.imageBackground.frame.size.width, self.imageBackground.frame.size.height);
                                       //tempImageView.alpha = 0;
                                       //tempImageView.image = image;
                                       //[self.viewHeader addSubview:tempImageView];
                                       self.imageFirstBackground.image = image;
                                       [self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
                                       [UIView animateWithDuration:1.0
                                                        animations:^{
                                                            self.imageBackground.alpha = 0.0;
                                                            //tempImageView.alpha = 0.0;
                                                        }
                                                        completion:^(BOOL finished){
                                                            //self.imageBackground.alpha = 0.0;
                                                            //self.imageBackground.image = image;
                                                            //tempImageView.alpha = 1.0;
                                                            //[tempImageView removeFromSuperview];
                                                        }];
                                       
                                   } else {
                                       NSLog(@"Image not loaded!");
                                       self.imageBackground.image = [UIImage imageNamed:@"headerBackground"];
                                   }
                               }];

                          }];
}

//-------------------------------------------------------------------//
//END FUNCTION
//-------------------------------------------------------------------//


//--------------------------------------------------//
//START TEXTFIELD CONTROLLER
//--------------------------------------------------//
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

//-(void)addControllChangeTextField:(UITextField *)textField
//{
//    [textField addTarget:self
//                  action:@selector(textFieldDidChange:)
//        forControlEvents:UIControlEventEditingChanged];
//}
//
//-(void)textFieldDidChange:(UITextField *)textField{
//    NSLog(@"textFieldDidChange %@",textField);
//    NSString *error;
//    emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (textField.tag == 1 && ![SHPStringUtil validEmail:emailValue]) {
//        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Email non corretta", nil)];
//        [self animationMessageError:error];
//    }
//    else if (textField.tag == 2 && ([textField.text length]<USERNAME_MIN_LENGTH)) {
//        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Il nome utente deve essere di almeno 6 caratteri", nil)];
//        [self animationMessageError:error];
//    }
//    else if (textField.tag == 3 && ([textField.text length]<PASSWORD_MIN_LENGTH)) {
//        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"La password deve essere di almeno 6 caratteri", nil)];
//        [self animationMessageError:error];
//    }
//    else if (textField.tag == 4 && ([textField.text length]<NAME_MIN_LENGTH)) {
//        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Il nome utente deve essere di almeno 6 caratteri", nil)];
//        [self animationMessageError:error];
//    }
//}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (textField.tag == 1){
        self.imageEmail.image = [UIImage imageNamed:@"mail"];
    }
    else if (textField.tag == 2){
        self.imageUsername.image = [UIImage imageNamed:@"real_name"];
    }
    else if (textField.tag == 3){
        self.imagePassword.image = [UIImage imageNamed:@"pswd"];
    }
    else if (textField.tag == 4){
        self.imageNameComplete.image = [UIImage imageNamed:@"badge"];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    NSString *error;
    emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textField.tag == 1 && ![SHPStringUtil validEmail:emailValue]) {
        //self.imageEmail.image = [UIImage imageNamed:@"mail_red"];
        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Email non corretta", nil)];
        [self animationMessageError:error];
    }else if (textField.tag == 1){
        //self.imageEmail.image = [UIImage imageNamed:@"mail_green"];
    }
    else if (textField.tag == 2){
        if([textField.text length]<USERNAME_MIN_LENGTH) {
            self.imageUsername.image = [UIImage imageNamed:@"real_name_red"];
            error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Il nome utente deve essere di almeno 6 caratteri", nil)];
            [self animationMessageError:error];
        }else if([textField.text length]==0){
            self.imageUsername.image = [UIImage imageNamed:@"real_name"];
        }else{
            self.imageUsername.image = [UIImage imageNamed:@"real_name_green"];
        }
    }
    else if (textField.tag == 3) {
        if([textField.text length]<PASSWORD_MIN_LENGTH){
            self.imagePassword.image = [UIImage imageNamed:@"pswd_red"];
            error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"La password deve essere di almeno 6 caratteri", nil)];
            [self animationMessageError:error];
        }else if ([textField.text length]==0){
            self.imagePassword.image = [UIImage imageNamed:@"pswd"];
        }else{
            self.imagePassword.image = [UIImage imageNamed:@"pswd_green"];
        }
    }
    else if (textField.tag == 4){
        if([textField.text length]<NAME_MIN_LENGTH) {
            self.imageNameComplete.image = [UIImage imageNamed:@"badge_red"];
            error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Il nome utente deve essere di almeno 6 caratteri", nil)];
            [self animationMessageError:error];
        }else if([textField.text length]==0) {
            self.imageNameComplete.image = [UIImage imageNamed:@"badge"];
        }else{
            self.imageNameComplete.image = [UIImage imageNamed:@"badge_green"];
        }
    }
}

-(BOOL)validateForm{
    NSLog(@"validateForm");
    NSLog(@"switchTermOfUse STATE: %u", self.switchPrivacy.on);
    NSString *error;
    emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    usernameValue = [self.textUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    nameValue = [self.textNameComplete.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (![SHPStringUtil validEmail:emailValue]) {
        self.imageEmail.image = [UIImage imageNamed:@"email_red"];
        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Email non corretta", nil)];
        [self animationMessageError:error];
        return false;
    }
    else if ([usernameValue length]<USERNAME_MIN_LENGTH) {
        self.imageUsername.image = [UIImage imageNamed:@"real_name_red"];
        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Il nome utente deve essere di almeno 6 caratteri", nil)];
        [self animationMessageError:error];
        return false;
    }
    else if ([passwordValue length]<PASSWORD_MIN_LENGTH  && !self.fbUserId) {
        self.imagePassword.image = [UIImage imageNamed:@"pswd_red"];
        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"La password deve essere di almeno 6 caratteri", nil)];
        [self animationMessageError:error];
        return false;
    }
    else if ([nameValue length]<NAME_MIN_LENGTH) {
        self.imageNameComplete.image = [UIImage imageNamed:@"badge_red"];
        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Inserisci un nome utente valido", nil)];
        [self animationMessageError:error];
        return false;
    }
    if (self.switchPrivacy.on==NO) {
        error = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Devi accettare i termini sulla privacy", nil)];
        [self animationMessageError:error];
        return false;
    }
    return true;
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
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: 0 inSection: 0];
    [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    
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


-(NSString *)readerPlistForUrlPagePrivacy{
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settingsAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    NSDictionary *settings_config = [plistDictionary objectForKey:@"Settings"];
    NSString *urlPrivacy = [settings_config objectForKey:@"urlPrivacy"];
    return urlPrivacy;
}
//--------------------------------------------------//
//END FUNCTIONS
//--------------------------------------------------//

//-----------------------------------------------------------//
//START TAKE PHOTO SECTION
//-----------------------------------------------------------//
// **** USER PHOTO MENU ****

-(void)didTapImage {
    NSLog(@"tapped");
    [self dismissKeyboard];
    [self.takePhotoMenu showInView:self.view];
}

-(void)resetUserPhoto {
    self.image = nil;
    self.imageProfile.image = nil;
    //[UIImage imageNamed:@"user_image_null"];
    [self buildMenuWithoutRemovePhotoButton];
}

-(void)buildMenuWithRemovePhotoButton {
    self.takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), NSLocalizedString(@"RemoveProfilePhotoLKey", nil), nil];
    self.takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}

-(void)buildMenuWithoutRemovePhotoButton {
    self.takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), nil];
    self.takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Alert Button!");
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:NSLocalizedString(@"TakePhotoLKey", nil)]) {
        NSLog(@"Take Photo");
        [self takePhoto];
    }
    else if ([option isEqualToString:NSLocalizedString(@"PhotoFromGalleryLKey", nil)]) {
        NSLog(@"Choose from Gallery");
        [self chooseExisting];
    }
    else if ([option isEqualToString:NSLocalizedString(@"RemoveProfilePhotoLKey", nil)]) {
        NSLog(@"Choose from Gallery");
        [self resetUserPhoto];
    }
}

- (void)takePhoto{
    if (self.imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)chooseExisting {
    //    NSLog(@"choose existing...");
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // enable to crop
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // enable to crop
    self.photoLibraryController.allowsEditing = YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    self.image = selectedImage;
    self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // enable to crop
    self.image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (!self.image) {
        UIImage *photo = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        CGSize size = CGSizeMake(200, 200); // using facebook type=large image size.
        self.image = [SHPImageUtil scaleImage:photo toSize:size];
        //self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    }
    self.imageProfile.image = self.image;
    [self buildMenuWithRemovePhotoButton];
}
//-----------------------------------------------------------//
//END TAKE PHOTO SECTION
//-----------------------------------------------------------//


//-----------------------------------------------------------//
//START REGISTRATION FORM DATA
//-----------------------------------------------------------//
-(void)sendRegistrationWithFormData {
    NSString *actionUrl = [SHPServiceUtil serviceUrl:@"service.signupwithphoto"];
    NSLog(@"Signup with photo. Action url: %@", actionUrl);
    NSString * boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    //NSLog(@"randomString: -%@-", randomString);
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    NSString * boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString * boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.imageProfile.image];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
    NSLog(@"IMAGE DATA::::::::::::::::::::::::::::::::::::::::::::::::::: %@", imageData);
    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    NSLog(@"POST DATA:::::: %@", postData);
    
    NSString *fullNameString = [self stringParameter:@"fullName" withValue:self.textNameComplete.text];
    NSString *usernameString = [self stringParameter:@"username" withValue:self.textUsername.text];
    NSString *emailString = [self stringParameter:@"email" withValue:self.textEmail.text];
    NSString *passwordString;
    if(self.textPassword.text){
        passwordString = [self stringParameter:@"password" withValue:self.textPassword.text];
    }else{
        passwordString = [self stringParameter:@"password" withValue:@""];
    }
    NSString *facebookTokenString;
    if (self.fbAccessToken) {
        facebookTokenString= [self stringParameter:@"facebookToken" withValue:self.fbAccessToken];
    } else {
        facebookTokenString = [self stringParameter:@"facebookToken" withValue:@""];
    }

    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[fullNameString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[usernameString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[emailString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[passwordString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[facebookTokenString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photofile\"; filename=\"photofile.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    NSString * dataLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    currentConnection = conn;
    if (conn) {
        receivedData = [NSMutableData data];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        NSLog(@"Could not connect to the network");
    }
}


-(NSString *)stringParameter:(NSString *)name withValue:(NSString *)value {
    NSString *part = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", name, value];
    return part;
}

- (void)cancelConnection {
    [currentConnection cancel];
    currentConnection = nil;
}

// CONNECTION DELEGATE
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    statusCode = code;
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    receivedData = nil;
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@ %d",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey],
          (int)error.code);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideWaiting];
    //NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    [self animationMessageError:msg];
    [self.barButtonNext setEnabled:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (statusCode < 400) {
        SHPUser *justRegisteredUser = [[SHPUser alloc] init];
        justRegisteredUser.username = self.textUsername.text;
        justRegisteredUser.fullName = self.textNameComplete.text;
        justRegisteredUser.httpBase64Auth = [self httpBase64FromJson:receivedData];
        [self registered:justRegisteredUser];
    } else {
        NSLog(@"HTTP Error %d", (int)statusCode);
        if (statusCode == ERROR_HTTP_USERNAME_USED) {
            //NSString *title = NSLocalizedString(@"RegistrationErrorTitleLKey", nil);
            NSString *msg = NSLocalizedString(@"UsernameAlreadyUsedLKey", nil);
            [self animationMessageError:msg];
            currentValidationError = @"username";
             self.imageUsername.image = [UIImage imageNamed:@"real_name_red"];
            [self.barButtonNext setEnabled:YES];
            [self hideWaiting];

        } else if (statusCode == ERROR_HTTP_EMAIL_USED) {
            //NSString *title = NSLocalizedString(@"RegistrationErrorTitleLKey", nil);
            NSString *msg = NSLocalizedString(@"EmailAlreadyUsedLKey", nil);
            [self animationMessageError:msg];
            currentValidationError = @"email";
            [self.barButtonNext setEnabled:YES];
            [self hideWaiting];
        } else if (statusCode == ERROR_HTTP_USERNAME_INVALID) {
            //NSString *title = NSLocalizedString(@"RegistrationErrorTitleLKey", nil);
            NSString *msg = NSLocalizedString(@"UsernameInvalidLKey", nil);
            [self animationMessageError:msg];
            currentValidationError = @"username";
            self.imageUsername.image = [UIImage imageNamed:@"real_name_red"];
            [self.barButtonNext setEnabled:YES];
            [self hideWaiting];
        } else {
            NSLog(@"Unknown error!");
            //NSString *title = NSLocalizedString(@"RegistrationErrorTitleLKey", nil);
            NSString *msg = NSLocalizedString(@"UnknownRegistrationErrorLKey", nil);
            [self animationMessageError:msg];
            currentValidationError = @"unknown";
            [self.barButtonNext setEnabled:YES];
            [self hideWaiting];
        }
        return;
    }
}

- (NSString *)httpBase64FromJson:(NSData *)jsonData {
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    NSString *basicAuth64 = [objects valueForKey:@"basicAuth"];
    return basicAuth64;
}
//-----------------------------------------------------------//
//END REGISTRATION FORM DATA
//-----------------------------------------------------------//


//----------------------------------------------------------------------//
//START REGISTERED
//----------------------------------------------------------------------//
-(void)registered:(SHPUser *)justRegisteredUser {
    NSLog(@"Registration successfull!");
    [self hideWaiting];
    [self prepareSignedUser:justRegisteredUser];
}

-(void)prepareSignedUser:(SHPUser *)user {
    NSLog(@"prepareSignedUser.");
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
                //appDelegate.registeredToProvider = YES;
            }
            else {
                NSLog(@"Error while registering devToken to Provider!");
                //[self hideWaiting];
            }
        }];
    }
}
//----------------------------------------------------------------------//
//END REGISTERED
//----------------------------------------------------------------------//


-(void)singInViewController{
    if([self validateForm]){
        [self.barButtonNext setEnabled:NO];
        [self dismissKeyboard];
        [self showWaiting:NSLocalizedString(@"AuthenticatingLKey", nil)];
        [self sendRegistrationWithFormData];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    if([identifierCell isEqualToString:@"idCellPassword"]){
       if(self.fbUserId){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellHeader"]){
        return 190.0;
    }
    return 40.0;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toWebView"]) {
        UINavigationController *nc = [segue destinationViewController];
        DDPWebPagesVC *vc = (DDPWebPagesVC *)[[nc viewControllers] objectAtIndex:0];
        vc.urlPage = [self readerPlistForUrlPagePrivacy];
    }
}



- (IBAction)actionPrivacyWebPage:(id)sender {
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}

- (IBAction)actionNext:(id)sender {
    [self singInViewController];
}

- (IBAction)actionPrivacy:(id)sender {
    //[self validateForm];
}

- (IBAction)actionPrevious:(id)sender {
    self.fbUserId = nil;
    self.userFB = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc {
    NSLog(@"SIGNIN DEALLOCATING");
}
@end
