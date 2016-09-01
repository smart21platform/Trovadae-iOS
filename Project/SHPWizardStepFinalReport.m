//
//  SHPWizardStepFinalReport.m
//  Salve Smart
//
//  Created by Dario De Pascalis on 20/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPWizardStepFinalReport.h"
#import "SHPComponents.h"
#import "SHPConstants.h"
#import "SHPApplicationContext.h"
#import "SHPCategory.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPImageUtil.h"
#import "SHPShop.h"
#import "SHPImageRequest.h"
#import "SHPConnectionsController.h"



#import "SHPObjectCache.h"
#import "SHPShopDC.h"
#import "SHPSelectFacebookAccountViewController.h"
#import "SHPProductUploaderDC.h"
#import "SHPUser.h"
#import "SHPFacebookPage.h"
#import "SHPWizardHelper.h"
#import "SHPProductUpdateDC.h"
#import "MBProgressHUD.h"
#import "SHPCaching.h"


@interface SHPWizardStepFinalReport ()

@end

@implementation SHPWizardStepFinalReport

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"....... Step FINAL");

    //typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
    //NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    //singlePoi=[[settingsDictionary objectForKey:@"singlePoi"] boolValue];
    //shopOid=[settingsDictionary objectForKey:@"shopOid"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = YES;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
    
    opened = false;
    self.telephoneNumberTextField.delegate = self;
    [self getTypeAndCategory];
    [self localizeLabels];
    [self initialize];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(![self.descriptionTextView.text isEqualToString:kPlaceholderDescription]){
        [self.wizardDictionary setObject:self.descriptionTextView.text forKey:WIZARD_DESCRIPTION_KEY];
    }
    if(self.telephoneNumberTextField.text && ![self.telephoneNumberTextField.text isEqualToString:@""]){
        [self.wizardDictionary setObject:self.telephoneNumberTextField.text forKey:WIZARD_TELEPHONE_KEY];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize
{
    // SET TITLE NAV BAR
    UIImage *title_image;
    NSString *categoryIconURL = [self.selectedCategory iconURL];
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *staticIcon = [self.selectedCategory getStaticIconFromDisk];
    if (cacheIcon) {
        title_image = cacheIcon;
    }
    else if (staticIcon) {
        title_image = staticIcon;
    }
    [SHPComponents customizeTitleWithImage:title_image vc:self];
    
    //PHOTO MAP
    if(self.imageMap){
        self.imageViewMap.image = self.imageMap;
    }else{
        [self initializeMapImage];
    }
    
    //PHOTO FORMATTER
    self.photoImageView.image = (UIImage *)[self.wizardDictionary objectForKey:WIZARD_IMAGE_KEY];
    descriptionPost = [[NSString alloc] init];
   // [self basicSetup];
   // [self localizeLabels];
   // [self showPreview];
}

-(void)getTypeAndCategory{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
}

-(void)localizeLabels {
    NSLog(@"localizeLabels!...........................");
    // init top message
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step8-end-%@", typeSelected];
    NSString *textHeader = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(headerLabel, nil)];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    
    // init next button
    self.uploadButton.title = NSLocalizedString(@"Send2LKey", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"Send2LKey", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];
    
    [self.buttonAddDescription setTitle:NSLocalizedString(@"labelAddDescription", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonAddDescription layer]];
    
    self.descriptionTextView.delegate = self;
    if([self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] && ![[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] isEqualToString:@""]){
        self.descriptionTextView.text = [self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY];
    }else{
        kPlaceholderDescription = NSLocalizedString(@"UserStoryDescriptionPlaceholderLKey", nil);
        [self resetPostMessage];
    }
    self.telephoneNumberTextField.placeholder =  NSLocalizedString(@"telephone-number-textField", nil);
    if([self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY] && ![[self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY] isEqualToString:@""]){
        NSLog(@"WIZARD_TELEPHONE_KEY!..........................%@", [self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY]);
        self.telephoneNumberTextField.placeholder =  nil;
        self.telephoneNumberTextField.text = [self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY];
    }
}


//------------------------------------------------------//
//START FUNCTION TEXT
//------------------------------------------------------//
- (void)resetPostMessage
{
    NSLog(@"resetPostMessage...");
    self.descriptionTextView.text = kPlaceholderDescription;
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Begin...");
    if ([textView.text isEqualToString:kPlaceholderDescription]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"End...");
    if ([textView.text isEqualToString:@""]) {
        //[self resetPostMessage];
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    NSLog(@"TEXT CHANGED %@", textView.text);
    [self validateForm];
}

-(void)validateForm {
    NSLog(@"validateForm");
    
    descriptionPost = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL valid = true;
    if([descriptionPost isEqualToString:@""]){
        //[self resetPostMessage];
        //valid = false;
    }else if([descriptionPost isEqualToString:kPlaceholderDescription]) {// || characterCount <
        valid = false;
    } else {
        valid = true;
        [self.wizardDictionary setObject:descriptionPost forKey:WIZARD_DESCRIPTION_KEY];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing...");
    textField.placeholder = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing...");
    textField.placeholder =  NSLocalizedString(@"telephone-number-textField", nil);
}

-(void)dismissKeyboard {
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}
//------------------------------------------------------//
//END FUNCTION TEXT
//------------------------------------------------------//

-(void)initializeMapImage {
    self.selectedShop = [self.wizardDictionary objectForKey:WIZARD_POI_KEY];
    if(self.selectedShop){
        NSString *location = [[NSString alloc] initWithFormat:@"%f,%f", self.selectedShop.lat, self.selectedShop.lon];
        urlImgPoiMap = [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=16&size=320x320&maptype=roadmap&markers=color:blue|label:|%@",location,location];
        if(![self.applicationContext.productDetailImageCache getImage:urlImgPoiMap]) {
            self.imageMap = nil;
            [self startImageMap:urlImgPoiMap];
        } else {
            self.imageMap = [self.applicationContext.productDetailImageCache getImage:urlImgPoiMap];
        }
    }
}

- (void)startImageMap:(NSString*)detailImageURL {
    NSLog(@"startImageMap................. %@", detailImageURL);
    detailImageURL = [detailImageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
    __weak SHPWizardStepFinalReport *weakSelf = self;
    [imageRequest downloadImage:detailImageURL
              completionHandler:
     ^(UIImage *image, NSString *imageURL, NSError *error) {
         if (image) {
             [weakSelf.applicationContext.productDetailImageCache addImage:image withKey:imageURL];
             weakSelf.imageMap = image;
             weakSelf.imageViewMap.image = self.imageMap;
             //loadImageMap = NO;
             [self.tableView reloadData];
             NSLog(@"reloadData................startImageMap ");
         } else {
             NSLog(@"reloadData..........startImageMap error: %@", error);
             // put an image that indicates "no image profile"
         }
     }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger super_height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
   if([identifierCell isEqualToString:@"idCellAddDescription"] && opened==false){
        return 0.0;
    }
    else if([identifierCell isEqualToString:@"idCellButtonDescription"] && opened==true){
        return 0.0;
    }
    return super_height;
}



-(void)executeUploadAction
{
    self.uploadButton.enabled = NO;
    self.buttonCellNext.enabled = NO;
    self.buttonCellNext.alpha = 0.5;
    BOOL em = [[self.wizardDictionary objectForKey:WIZARD_EDIT_MODE_KEY] boolValue];
    NSLog(@"EDIT MODE: %d",em);
    if(em){
        [self sendMetadataForUpdate];
    }else{
        [self sendPhotoWithMetadata];
        [self performSegueWithIdentifier:@"toFirstStep" sender:self];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//------------------------------------//
// START UPDATE POST
//------------------------------------//
-(void)sendMetadataForUpdate{
    //Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"SavingLKey", nil);
    [hud show:YES];
    SHPProductUpdateDC *productUpload = [[SHPProductUpdateDC alloc]init];
    productUpload.delegateViewController = self;
    productUpload.applicationContext = self.applicationContext;
}
//------------------------------------//
// END UPDATE POST
//------------------------------------//

-(void)sendPhotoWithMetadata
{
    self.uploaderDC = [[SHPProductUploaderDC alloc] init];
    [self.applicationContext.connectionsController addDataController:self.uploaderDC];
    // persist last phone number
    [SHPApplicationContext saveLastPhone:self.telephoneNumberTextField.text];
    self.uploaderDC.applicationContext = self.applicationContext;
    NSString *latitudine = [NSString stringWithFormat:@"%f",self.selectedShop.lat];
    NSString *longitudine = [NSString stringWithFormat:@"%f",self.selectedShop.lon];

    [self.uploaderDC setMetadata:[self.wizardDictionary objectForKey:WIZARD_IMAGE_KEY]
                           brand:nil
                     categoryOid:self.selectedCategory.oid
                         shopOid:nil
                      shopSource:nil
                             lat:latitudine
                             lon:longitudine
       shopGooglePlacesReference:nil
                           title:nil
                     description:descriptionPost
                           price:nil
                      startprice:nil
                       telephone:self.telephoneNumberTextField.text
                       startDate:nil
                         endDate:nil
                        properties:nil];
    [self.uploaderDC sendReport];
}
//------------------------------------//
// END SAVE POST
//------------------------------------//


//------------------------------------//
// DELEGATE SAVE AND UPDATE POST
//------------------------------------//
-(void)itemUpdatedWithError:(NSString *)error{
    [hud hide:YES];
    NSLog(@"ERROR %@",error);
    if(error==nil){
        //        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"error-update-reload", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alertError show];
        [self performSegueWithIdentifier:@"toFirstStep" sender:self];
    }else{
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"error-update-reload", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertError show];
    }
}
//------------------------------------//



- (IBAction)actionButtonAddDescription:(id)sender {
    NSLog(@"actionButtonAddDescription %d", opened);
    if(opened == true){
        opened = false;
    }else{
        opened = true;
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (IBAction)actionButtonCellNext:(id)sender {
    [self executeUploadAction];
}

- (IBAction)uploadAction:(id)sender {
    [self executeUploadAction];
}
@end
