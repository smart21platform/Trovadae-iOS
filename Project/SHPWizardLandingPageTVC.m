//
//  SHPWizardLandingPageTVC.m
//  Mercatino
//
//  Created by Dario De Pascalis on 18/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "SHPWizardLandingPageTVC.h"
#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPConstants.h"
#import "SHPImageUtil.h"
#import "SHPWizardSelectCategory.h"
#import "SHPCategory.h"
#import "SHPProductUpdateDC.h"
#import "SHPConnectionsController.h"


@interface SHPWizardLandingPageTVC ()

@end

@implementation SHPWizardLandingPageTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@".......viewDidLoad.......");
    // SET TITLE NAV BAR
    [SHPComponents customizeTitle:@"Crea annuncio" vc:self];
    // SET WIZARD PLIST
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"wizard" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    [self.applicationContext setVariable:@"PLIST_WIZARD" withValue:plistDictionary];
    
    configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    tenantName = [configDictionary objectForKey:@"tenantName"];
    
    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    viewDictionary = [viewDictionary objectForKey:@"Wizard"];
    otypeReport =[NSString stringWithString:[viewDictionary objectForKey:@"OTYPE_REPORT"]];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)initialize{
    //INIT TOP MESSAGE
    //self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    // default category
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    SHPCategory *defaultCategory = [cachedCategories objectAtIndex:cachedCategories.count - 1];
    self.selectedCategory = defaultCategory;
    
    self.textViewDescription.text = @"";
    self.textViewDescription.delegate = self;
    [self.barButtonPublish setTitle:@"Pubblica"];
    [self.buttonUpload setTitle:@"Pubblica" forState:UIControlStateNormal];
    [self addGestureRecognizerToView];
    [self refreshPage];
}

-(void)refreshPage
{
    if(self.imageViewPhoto.image){
        [self.buttonAddPhoto setTitle:@"Sostituisci foto" forState:UIControlStateNormal];
    }else{
        [self.buttonAddPhoto setTitle:@"Aggiungi una foto" forState:UIControlStateNormal];
    }

    if(self.applicationContext.lastLocation){
        NSLog(@"\n lastLocation: %f - %f", self.applicationContext.lastLocation.coordinate.latitude, self.applicationContext.lastLocation.coordinate.longitude);
        self.labelCity.text = [NSString stringWithFormat:@"%@",self.applicationContext.lastLocationName];
    }
    if(self.selectedCategory){
        NSLog(@"\n cat: ....... %@", self.selectedCategory);
        NSString *label = [[NSString alloc] initWithFormat:@"%@ (Cambia Categoria)", self.selectedCategory.localName];
        self.labelCategory.text = label;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//------------------------------------------------//
// START TAKE PHOTO SECTION
//------------------------------------------------//
-(void)didTapImage {
    NSLog(@"tapped");
    takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Annulla", @"CZ-Profile", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), NSLocalizedString(@"RemovePhotoLKey", nil), nil];
    takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [takePhotoMenu showInView:self.view];
}

/*
 TakePhotoLKey" = "Scatta una Foto";
 "PhotoFromGalleryLKey" = "Scegli dalla Galleria";
 "AddNewProductsTitleLKey" = "Scegli una categoria e pubblica il tuo post su %@";
 "UploadsInProgressLKey" = "Caricamenti in corso";
 "UploadFailedLKey" = "Caricamento fallito";
 "RemoveProfilePhotoLKey" = "Rimuovi foto";
 */

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"option: %@", option);
    if ([option isEqualToString:NSLocalizedString(@"TakePhotoLKey", nil)]) {
        NSLog(@"Take Photo");
        [self takePhoto];
    }
    else if ([option isEqualToString:NSLocalizedString(@"PhotoFromGalleryLKey", nil)]) {
        NSLog(@"Choose from Gallery");
        [self chooseExisting];
    }
    else if ([option isEqualToString:NSLocalizedString(@"RemovePhotoLKey", nil)]) {
        NSLog(@"Reset photo");
        [self resetUserPhoto];
    }
}

-(void)resetUserPhoto {
    self.imageViewPhoto.image = nil;
    [self refreshPage];
    [self.tableView reloadData];
}

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
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    NSLog(@"initializePhotoLibrary...");
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;// SavedPhotosAlbum;// SavedPhotosAlbum;
    self.photoLibraryController.allowsEditing = YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self afterPickerCompletion:picker withInfo:info];
}

-(void)afterPickerCompletion:(UIImagePickerController *)picker withInfo:(NSDictionary *)info {
    self.bigImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"BIG IMAGE: %@", self.bigImage);
    NSLog(@"edited image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    if (!self.bigImage) {
        self.bigImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSLog(@"original image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    }
    
    self.imageViewPhoto.image = [SHPImageUtil scaleImage:self.bigImage toSize:CGSizeMake(self.applicationContext.settings.uploadImageSize, self.applicationContext.settings.uploadImageSize)];
    NSLog(@"SCALED IMAGE w:%f h:%f", self.bigImage.size.height, self.imageViewPhoto.frame.size.width);
    [self refreshPage];
    [self.tableView reloadData];
    //[self.tableView beginUpdates];
    //[self.tableView endUpdates];
}
//------------------------------------------------//
// END TAKE PHOTO SECTION
//------------------------------------------------//


//--------------------------------------------------------------------//
//START TEXTFIELD CONTROLLER
//--------------------------------------------------------------------//
-(void)addGestureRecognizerToView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)
                                   ];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Begin...%@", textView);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"End...%@", textView);
    if (self.textViewDescription.text.length == 0) {
        self.textFieldDescription.alpha = 1;
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    NSLog(@"TEXT CHANGED %@", textView.text);
    self.textFieldDescription.alpha = 0;
}

-(void)dismissKeyboard{
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}
//--------------------------------------------------------------------//
//END TEXTFIELD CONTROLLER
//--------------------------------------------------------------------//


//----------------------------------------------------------//
//START FUNCTIONS UPLOAD
//----------------------------------------------------------//

-(void)executeUploadAction
{
    self.buttonUpload.enabled = NO;
    self.barButtonPublish.enabled = NO;
    [self sendPhotoWithMetadata];
    NSLog(@"performSegueWithIdentifier");
    [self performSegueWithIdentifier:@"thanksDialog" sender:self];
}


//------------------------------------//
// END UPDATE POST
//------------------------------------//

-(void)sendPhotoWithMetadata
{
    self.uploaderDC = [[SHPProductUploaderDC alloc] init];
    
    // PUBLISH TO FACEBOOK FORCED TO "NO". NEVER PUBLISH ON FACEBOOK ON SAVING.
    self.uploaderDC.onFinishPublishToFacebook = NO;
//    if (self.switchFBAccount.on) {
//        self.uploaderDC.onFinishPublishToFacebook = YES;
//    }
    [self.applicationContext.connectionsController addDataController:self.uploaderDC];
    [SHPApplicationContext saveLastPhone:self.textFieldTel.text];
    self.uploaderDC.applicationContext = self.applicationContext;
    
   
    NSString *title = self.textFieldTitle.text;
    NSString *description = self.textViewDescription.text;
    NSString *trimmedTitle = [title stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedDescription = [description stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceCharacterSet]];
    NSString *finalTitle = trimmedTitle;
    if(!trimmedDescription || [trimmedDescription isEqualToString:@""]){
        trimmedDescription = @" ";
    }
    if ([trimmedTitle isEqualToString:@""]) {
        finalTitle = [self firstWordsOf:trimmedDescription];
    }
    
    NSLog(@"final title %@", finalTitle);
    NSLog(@"trimmed descrition %@", trimmedDescription);
    NSString *price = [NSString stringWithFormat:@"%.2f", [self.textFieldPrice.text floatValue]];
    NSLog(@"\n\n\n self.textFieldPrice.text: ------------------- %@\n\n\n",price);
    NSString *latitudine = [NSString stringWithFormat:@"%f",self.applicationContext.lastLocation.coordinate.latitude];
    NSString *longitudine = [NSString stringWithFormat:@"%f",self.applicationContext.lastLocation.coordinate.longitude];
    
    [self.uploaderDC setMetadata:self.bigImage
                           brand:nil
                     categoryOid:self.selectedCategory.oid
                         shopOid:nil
                      shopSource:nil
                             lat:latitudine
                             lon:longitudine
       shopGooglePlacesReference:nil
                           title:finalTitle
                     description:trimmedDescription
                           price:price
                      startprice:price
                       telephone:self.textFieldTel.text
                       startDate:nil
                         endDate:nil
                      properties:nil];
    
    [self.uploaderDC sendReport];
}

-(NSString *)firstWordsOf:(NSString *)text {
    if ([text isEqualToString:@""]) {
        return text;
    }
    NSInteger nWords = 3;
    NSRange wordRange = NSMakeRange(0, nWords);
//    NSArray *firstWords = [[text componentsSeparatedByString:@" "] subarrayWithRange:wordRange];
    NSCharacterSet *delimiterCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *components = [text componentsSeparatedByCharactersInSet:delimiterCharacterSet];
    if (components.count >= nWords) {
        NSArray *firstWords = [components subarrayWithRange:wordRange];
        NSString *result = [firstWords componentsJoinedByString:@" "];
        return result;
    }
    return text;
}

//----------------------------------------------------------//
//END FUNCTIONS UPLOAD
//----------------------------------------------------------//



//------------------------------------------------//
// START FUNCTIONS TABLEVIEW
//------------------------------------------------//

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Section h %f", height);
    if(indexPath.row == 1){
        if(self.imageViewPhoto.image){
            return (self.bigImage.size.height*self.imageViewPhoto.frame.size.width)/self.bigImage.size.width;
        }else{
            return 0;
        }
    }else if(indexPath.row == 4){
        return 120;
    }else if(indexPath.row == 9){
        return 0;
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toWizardSelectCategory"]) {
        SHPWizardSelectCategory *vc = (SHPWizardSelectCategory *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
}
//------------------------------------------------//
// END FUNCTIONS TABLEVIEW
//------------------------------------------------//

- (IBAction)switchFBAccount:(id)sender {
}

- (IBAction)actionBarButtonPublish:(id)sender {
    [self executeUploadAction];
}

- (IBAction)actionAddPhoto:(id)sender {
    [self didTapImage];
}

- (IBAction)actionUpload:(id)sender {
    [self executeUploadAction];
}

- (IBAction)unwindToWizardLandingPageTVC:(UIStoryboardSegue *)segue{
     NSLog(@"\n BEN TORNATO!");
    [self refreshPage];
}

- (IBAction)actionClose:(id)sender {
    NSLog(@"\n actionClose!");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
@end
