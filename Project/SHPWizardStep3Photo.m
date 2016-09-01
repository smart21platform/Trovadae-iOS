//
//  SHPWizardStep3Photo.m
//  Galatina
//
//  Created by dario de pascalis on 17/02/15.
//
//

#import "SHPWizardStep3Photo.h"

//#import "SHPPhotoStepWizardTVC.h"
#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPCategory.h"
#import "SHPCaching.h"
#import "SHPConstants.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPImageUtil.h"
#import "SHPWizardStep4Title.h"
#import "SHPWizardStep5Poi.h"
#import "SHPWizardStepFinal.h"
#import "SHPWizardStepStartReport.h"
#import "SHPWizardStepFinalReport.h"
#import "SHPWizardStepFinalAd.h"

@interface SHPWizardStep3Photo ()
@end

@implementation SHPWizardStep3Photo

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    singlePoi=[[settingsDictionary objectForKey:@"singlePoi"] boolValue];
    shopOid=[settingsDictionary objectForKey:@"shopOid"];
    
    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    viewDictionary = [viewDictionary objectForKey:@"Wizard"];
    otypeAd =[NSString stringWithString:[viewDictionary objectForKey:@"OTYPE_AD"]];
    
    NSLog(@"+++++++++++ self.parentViewController: %@", self.caller);
    [self customBackButton];
    [self initialize];
}


-(void)customBackButton{
    UIImage *faceImage = [UIImage imageNamed:@"buttonArrow.png"];
    CGFloat angle = 180;
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
    [face setImage:faceImage forState:UIControlStateNormal];
    face.transform = CGAffineTransformMakeRotation(angle*M_PI/180);
    if(self.backActionClose == YES){
        [face addTarget:self action:@selector(goToClose) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [face addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepPhoto type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)initialize{
    //self.scaledImage = nil;
    [self getTypeAndCategory];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
    
    self.nextButton.title = NSLocalizedString(@"wizardNextButton", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"wizardNextButton", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];

    
    if ([self.caller isKindOfClass:[SHPWizardStepStartReport class]] || [[self.wizardDictionary objectForKey:WIZARD_TYPE_KEY] isEqualToString:otypeAd]) {
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
    }else{
        self.nextButton.enabled = NO;
        self.buttonCellNext.enabled = NO;
        self.buttonCellNext.alpha = 0.5;
    }
    
    
    
    // SET TITLE NAV BAR
    UIImage *title_image;
    NSString *categoryIconURL = [self.selectedCategory iconURL];
    NSLog(@"....... %@", categoryIconURL);
    
    
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
    //UIImage *staticIcon = [self.selectedCategory getStaticIconFromDisk];
    
    if (cacheIcon) {
        title_image = cacheIcon;
    }
    else if (archiveIcon) {
        NSLog(@"archiveIcon");
        title_image = archiveIcon;
    }
    //else if (staticIcon) {
    //NSLog(@"staticIcon");
    //iconView.image = staticIcon;
    //}
    
    NSLog(@"ICON    ....... %@ - %@", cacheIcon, archiveIcon);
    [SHPComponents customizeTitleWithImage:title_image vc:self];
    [self basicSetup];
}

-(void)getTypeAndCategory{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
}

-(void)basicSetup {
    self.cancelButton.title = NSLocalizedString(@"CancelLKey", nil);
    //self.wizardDictionary = (NSMutableDictionary *)[self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    
    //NSLog(@"ALT! DOCT: %@", self.wizardDictionary);
    [self.takePhotoButton setTitle:NSLocalizedString(@"TakePhotoLKey", nil) forState:UIControlStateNormal];
    [self.ChooseFromGalleryButton setTitle:NSLocalizedString(@"PhotoFromGalleryLKey", nil) forState:UIControlStateNormal];
    //NSLog(@"takePhotoButton %@", self.takePhotoButton);
    
    //NSLog(@"WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY %@", [self.wizardDictionary objectForKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY]);
    NSLog(@"topMessageLabel %@", self.topMessageLabel);
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step3-photo-%@", typeSelected];
    NSString *hintLabel = [[NSString alloc] initWithFormat:@"hint-step3-photo-%@", typeSelected];
    NSString *textHeader = NSLocalizedString(headerLabel, nil);
    NSString *textHint = NSLocalizedString(hintLabel, nil);

    [SHPUserInterfaceUtil applyTitleString:(NSString *) textHeader toAttributedLabel:self.topMessageLabel];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHint  toAttributedLabel:self.hintLabel];
    NSLog(@"topMessageLabel %@", self.topMessageLabel);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// **************** TAKE PHOTO SECTION **************


- (void)takePhoto {
    NSLog(@"taking photo with user %@...", self.applicationContext.loggedUser);
    if (self.imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:^{NSLog(@"FINITO!");}];
}

- (void)chooseExisting {
    NSLog(@"choose existing...");
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    NSLog(@"cinitializeCamera...");
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // enable to crop
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    NSLog(@"initializePhotoLibrary...");
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;// SavedPhotosAlbum;// SavedPhotosAlbum;
    self.photoLibraryController.allowsEditing = YES;
    //self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self afterPickerCompletion:picker withInfo:info];
}

-(void)afterPickerCompletion:(UIImagePickerController *)picker withInfo:(NSDictionary *)info {
    self.bigImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"BIG IMAGE: %@", self.bigImage);
    // enable to crop
    // self.scaledImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"edited image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    if (!self.bigImage) {
        self.bigImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSLog(@"original image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    }
    // end
    
    self.scaledImage = [SHPImageUtil scaleImage:self.bigImage toSize:CGSizeMake(self.applicationContext.settings.uploadImageSize, self.applicationContext.settings.uploadImageSize)];
    NSLog(@"SCALED IMAGE w:%f h:%f", self.scaledImage.size.width, self.scaledImage.size.height);
    
    if (picker == self.imagePickerController) {
        UIImageWriteToSavedPhotosAlbum(self.bigImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    self.previewImage.image = self.scaledImage;
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.previewImage layer]];
    
    self.nextButton.enabled = YES;
    self.buttonCellNext.enabled = YES;
    self.buttonCellNext.alpha = 1;
}

- (void)goToClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)goToBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionNext:(id)sender {
    [self selectSegue];
}

- (IBAction)actionButtonCellNext:(id)sender {
     [self selectSegue];
}





-(void)selectSegue
{
    //NSLog(@"typeDictionary %@ - %@",typeDictionary, typeSelected);
    if ([self.caller isKindOfClass:[SHPWizardStepStartReport class]]) {
        [self performSegueWithIdentifier:@"toStepFinalReport" sender:self];
    }
    else if([[self.wizardDictionary objectForKey:WIZARD_TYPE_KEY] isEqualToString:otypeAd]){
        [self performSegueWithIdentifier:@"toStepFinalAd" sender:self];
    }
    else if(![[typeDictionary valueForKey:@"title"] isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"toStepTitle" sender:self];
    }else if(![[typeDictionary valueForKey:@"poi"] isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"toStepPOI" sender:self];
    }
    else{
        [self performSegueWithIdentifier:@"toStepFinal" sender:self];
    }
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue -> self.scaledImage %@",self.scaledImage);
    if(self.scaledImage)[self.wizardDictionary setObject:self.scaledImage forKey:WIZARD_IMAGE_KEY];
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
   
    if ([[segue identifier] isEqualToString:@"toStepFinalReport"]) {
        SHPWizardStepFinalReport *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if([[segue identifier] isEqualToString:@"toStepFinalAd"]){
        SHPWizardStepFinalAd *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toStepTitle"]) {
        SHPWizardStep4Title *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toStepPOI"]) {
        SHPWizardStep5Poi *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toStepFinal"]) {
        SHPWizardStepFinal *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        NSLog(@"(SHPTakePhotoViewController) Error saving image to camera roll.");
    }
    else {
        //NSLog(@"(SHPTakePhotoViewController) Image saved to camera roll. w:%f h:%f", self.image.size.width, self.image.size.height);
    }
}
// *****************

@end