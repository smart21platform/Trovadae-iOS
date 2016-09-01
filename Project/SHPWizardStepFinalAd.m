//
//  SHPWizardStepFinalAd.m
//  Salve Smart
//
//  Created by Dario De Pascalis on 22/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPWizardStepFinalAd.h"
#import "SHPCategory.h"
#import "SHPProduct.h"
#import "SHPComponents.h"
#import "SHPConstants.h"
#import "SHPCategory.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPImageUtil.h"
#import "SHPConnectionsController.h"

#import "SHPShop.h"
#import "SHPImageRequest.h"
#import "SHPObjectCache.h"
#import "SHPShopDC.h"
#import "SHPSelectFacebookAccountViewController.h"
#import "SHPUser.h"
#import "SHPFacebookPage.h"
#import "SHPWizardHelper.h"
#import "SHPCaching.h"


@interface SHPWizardStepFinalAd ()

@end
//
//static int one_day_seconds = 86400;
//static int last_day_seconds = 86399;
//static int max_start_day_from_today = 365;
//static int max_duration_in_days = 120;

@implementation SHPWizardStepFinalAd

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
    opened = false;
    self.telephoneNumberTextField.delegate = self;
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    NSLog(@"....... Step FINAL %@",self.wizardDictionary);
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *viewDictionary = [plistDictionary objectForKey:@"Settings"];
    lat = [NSString stringWithString:[viewDictionary objectForKey:@"latitude"]];
    lon = [NSString stringWithString:[viewDictionary objectForKey:@"longitude"]];
    dateEnd = nil;
    [self getTypeAndCategory];
    [self localizeLabels];
    [self initializeLocation];
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
    if(self.textFieldEmail.text && ![self.textFieldEmail.text isEqualToString:@""]){
        [self.wizardDictionary setObject:self.textFieldEmail.text forKey:WIZARD_EMAIL_KEY];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(![self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] || [[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] isEqualToString:@""]){
        opened = false;
        [self resetPostMessage];
    }
    if([self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY] && ![[self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY] isEqualToString:@""]){
        self.telephoneNumberTextField.placeholder =  nil;
        self.telephoneNumberTextField.text = [self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY];
    }
    if([self.wizardDictionary objectForKey:WIZARD_EMAIL_KEY] && ![[self.wizardDictionary objectForKey:WIZARD_EMAIL_KEY] isEqualToString:@""]){
        self.textFieldEmail.placeholder =  nil;
        self.textFieldEmail.text = [self.wizardDictionary objectForKey:WIZARD_EMAIL_KEY];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepFinal type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getTypeAndCategory{
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
}

-(void)localizeLabels {
    NSLog(@"localizeLabels!...........................%@ - %@ X", [self.wizardDictionary objectForKey:WIZARD_IMAGE_KEY], typeSelected );
    // init top message
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step8-end-%@", typeSelected];
    NSString *textHeader = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(headerLabel, nil)];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    
    // init next button
    self.uploadButton.title = NSLocalizedString(@"Send2LKey", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"Send2LKey", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];
    
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
    
    //TELEPHON FORMATTER
    if ([SHPApplicationContext restoreLastPhone] && ![self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY]) {
        self.telephoneNumberTextField.text = [SHPApplicationContext restoreLastPhone];
    }
    
    self.textFieldEmail.placeholder =  NSLocalizedString(@"email-textField", nil);
    if([self.wizardDictionary objectForKey:WIZARD_EMAIL_KEY] && ![[self.wizardDictionary objectForKey:WIZARD_EMAIL_KEY] isEqualToString:@""]){
        self.textFieldEmail.placeholder =  nil;
        self.textFieldEmail.text = [self.wizardDictionary objectForKey:WIZARD_EMAIL_KEY];
    }
    
    //EMAIL FORMATTER
    if ([SHPApplicationContext restoreLastEmail] && ![self.wizardDictionary objectForKey:WIZARD_EMAIL_KEY]) {
        self.textFieldEmail.text = [SHPApplicationContext restoreLastEmail];
    }


    self.textFieldPartenza.placeholder =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"poi-start-textField", nil), NSLocalizedString(@"label-obbligatorio", nil)];
    self.textFieldDestinazione.placeholder =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"poi-end-textField", nil), NSLocalizedString(@"label-obbligatorio", nil)];
    placeholderDuration = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"label-duration-placeholder", nil), NSLocalizedString(@"label-obbligatorio", nil)];
    placeholderDate = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"label-data-partenza-placeholder", nil), NSLocalizedString(@"label-obbligatorio", nil)];
    self.labelDuration.text = placeholderDuration;
    self.labelDate.text = placeholderDate;
    
     self.labelHeaderDescription.text =  NSLocalizedString(@"label-header-description-textField", nil);
    
}

-(void)initializeLocation {
    NSLog(@"INITIALIZING LOCATION! XXXXXX");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    NSLog(@"self.locationManager %@",self.locationManager.location);
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    //[self enableLocationServices];
    //self.locationSelected = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
}

-(void)initialize
{
    selectingDate = NO;
    selectingDuration = NO;
    
    // GET TYPE AND CATEGORY
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
    
    // SET TITLE NAV BAR
    UIImage *title_image = [[UIImage alloc] init];
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
    
    //PHOTO FORMATTER
    self.photoImageView.image = (UIImage *)[self.wizardDictionary objectForKey:WIZARD_IMAGE_KEY];
    
    //DESCRIPTION
    descriptionPost = [[NSString alloc] init];
    
    //TITLE
    titlePost = [[NSString alloc] init];
    
    //DATE
    self.startDatePicker.datePickerMode = UIDatePickerModeDateAndTime; //UIDatePickerModeDate;
    NSDate *today = [NSDate date];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, dd MMMM HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [dateFormatter dateFromString:[[NSString alloc] initWithFormat:@"%@", today]];
    self.startDatePicker.minimumDate = date;
    
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
    //[self validateForm];
}

-(void)validateForm {
    NSLog(@"validateForm");
    
    BOOL valid = true;
    descriptionPost = [[NSString alloc] init];
    
    //check poi partenza
    NSString *startPoi = [self.textFieldPartenza.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([startPoi isEqualToString:@""]){
        valid = false;
    }else if([startPoi isEqualToString:NSLocalizedString(@"poi-start-textField", nil)]) {
        valid = false;
    } else {
        //valid = true;
        NSString *stringAddDesc = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"poi-start-textField", nil), self.textFieldPartenza.text];
        descriptionPost = [descriptionPost stringByAppendingString:stringAddDesc];
        titlePost = [titlePost stringByAppendingString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"poi-start-textField", nil), startPoi]];
    }
    
    //check poi destinazione
    NSString *endPoi = [self.textFieldDestinazione.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([endPoi isEqualToString:@""]){
        valid = false;
    }else if([endPoi isEqualToString:NSLocalizedString(@"poi-end-textField", nil)]) {
        valid = false;
    } else {
        //valid = true;
        NSString *stringAddDesc = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"poi-end-textField", nil), self.textFieldDestinazione.text];
        descriptionPost = [descriptionPost stringByAppendingString:stringAddDesc];
        titlePost = [titlePost stringByAppendingString:[NSString stringWithFormat:@" - %@: %@", NSLocalizedString(@"poi-end-textField", nil), endPoi]];
    }

    
    //check data
    if([self.labelDate.text isEqualToString:@""]){
        valid = false;
    }else if([self.labelDate.text isEqualToString:placeholderDate]) {
        valid = false;
    } else {
        //valid = true;
        NSString *stringAddDesc = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"label-data-partenza-placeholder", nil), self.labelDate.text];
        descriptionPost = [descriptionPost stringByAppendingString:stringAddDesc];
    }

    //check durata
    if([self.labelDuration.text isEqualToString:@""]){
        valid = false;
    }else if([self.labelDuration.text isEqualToString:placeholderDuration]) {
        valid = false;
    } else {
        //valid = true;
        NSString *stringAddDesc = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"label-duration-placeholder", nil), self.labelDuration.text];
        descriptionPost = [descriptionPost stringByAppendingString:stringAddDesc];
    }
    
    //check description
    NSString *desc = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([desc isEqualToString:@""]){
        //[self resetPostMessage];
        valid = true;
    }else if([desc isEqualToString:kPlaceholderDescription]) {// || characterCount <
        valid = false;
    } else {
        //valid = true;
        descriptionPost = [descriptionPost stringByAppendingString:desc];
        
    }

    if(valid == false){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert-invalid-form", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }else{
        [self.wizardDictionary setObject:titlePost forKey:WIZARD_TITLE_KEY];
        [self.wizardDictionary setObject:descriptionPost forKey:WIZARD_DESCRIPTION_KEY];
        [self.wizardDictionary setObject:self.labelDate.text forKey:WIZARD_DATE_START_KEY];
        
        [self executeUploadAction];
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
    if([self.descriptionTextView.text isEqualToString:@""])[self resetPostMessage];
    if([self.textFieldEmail.text isEqualToString:@""])self.textFieldEmail.placeholder =  NSLocalizedString(@"email-textField", nil);
    
    //[self setProperties];
}

-(void)setProperties{
    NSDictionary *finalData = [[NSDictionary alloc]init];
    NSString *phoneProperty = [self.telephoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(phoneProperty && ![phoneProperty isEqualToString:@""]){
        NSArray *values = @[phoneProperty];
        NSDictionary *propertyPhoneDictionary = [SHPProduct setProperties:@"phone" displayName:@"phone" oid:@"phone" values:values];
        //NSLog(@"JSON finalData: %@ \n", propertyPhoneDictionary);
        finalData = [SHPComponents mergeDictionaries:finalData second:propertyPhoneDictionary];
    }

    
    NSString *emailAddress = [self.textFieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(emailAddress && ![emailAddress isEqualToString:@""]){
        NSArray *values = @[emailAddress];
        NSDictionary *propertyEmailDictionary = [SHPProduct setProperties:@"email" displayName:@"email" oid:@"email" values:values];
        //NSLog(@"JSON finalData: %@ \n", propertyEmailDictionary);
        finalData = [SHPComponents mergeDictionaries:finalData second:propertyEmailDictionary];
    }
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalData options:NSJSONWritingPrettyPrinted error:nil];
    properties = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSLog(@"\n--------------------\n %@ \n--------------------\n",properties);

}
//------------------------------------------------------//
//END FUNCTION TEXT
//------------------------------------------------------//

-(void)setDuration:(UIDatePicker *)targetedDatePicker
{
    NSString *ore;
    NSString *min;
    dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm Z"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"HH"];
    ore = [dateFormatter stringFromDate:targetedDatePicker.date];
    [dateFormatter setDateFormat:@"mm"];
    min = [dateFormatter stringFromDate:targetedDatePicker.date];
    self.labelDuration.text = [NSString stringWithFormat:@"%@ore : %@min",ore,min];
}

-(void)setDate:(UIDatePicker *)targetedDatePicker
{
    NSLog(@"START DATE");
    dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm Z"];
    //[dateFormatter setDateFormat:@"EEEE, dd MMMM yyyy"];
    [dateFormatter setDateFormat:@"EEEE, dd MMMM yy HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    self.labelDate.text = [dateFormatter stringFromDate:targetedDatePicker.date];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"dd/MM/yyyy HH:mm Z"];
    [timeFormat setTimeZone:[NSTimeZone localTimeZone]];
    dateEnd = [timeFormat stringFromDate:targetedDatePicker.date];
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
    self.uploaderDC.applicationContext = self.applicationContext;
    //---------------------------------------------------//
    [SHPApplicationContext saveLastPhone:self.telephoneNumberTextField.text];
    [SHPApplicationContext saveLastEmail:self.textFieldEmail.text];
    if(self.locationManager){
        //lat = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
        //lon = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    }
    [self setProperties];
    NSLog(@"titlePost: %@",titlePost);
    //---------------------------------------------------//
    [self.uploaderDC setMetadata:[self.wizardDictionary objectForKey:WIZARD_IMAGE_KEY]
                           brand:nil
                     categoryOid:self.selectedCategory.oid
                         shopOid:nil
                      shopSource:nil
                             lat:lat
                             lon:lon
       shopGooglePlacesReference:nil
                           title:titlePost
                     description:descriptionPost
                           price:nil
                      startprice:nil
                       telephone:self.telephoneNumberTextField.text
                       startDate:nil
                         endDate:dateEnd
                      properties:properties];
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



//--------------------------------------------//
//START TABLEVIEW
//--------------------------------------------//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger super_height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    NSLog (@"selectingDate %@ - %@: %f",identifierCell,  self.photoImageView.image, self.photoImageView.image.size.height  );
    if([identifierCell isEqualToString:@"idCellImage"]){
        if(self.photoImageView.image != NULL){
            float nwH =  (self.view.frame.size.width * self.photoImageView.image.size.height)/self.view.frame.size.height;
            return nwH;
        }
        else{
            return 0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellAddDataPartenza"] && selectingDate == NO){
        return 41.0;
    }
    else if([identifierCell isEqualToString:@"idCellAddDurata"] && selectingDuration == NO){
        return 41.0;
    }
    return super_height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    if([identifierCell isEqualToString:@"idCellAddDataPartenza"]){
        selectingDate = (selectingDate == YES)? NO:YES;
        NSLog (@"selectingDate %d",selectingDate);
        [self.tableView beginUpdates];
        [self setDate:self.startDatePicker];
        [self.tableView endUpdates];
    }
    else if([identifierCell isEqualToString:@"idCellAddDurata"]){
        selectingDuration = (selectingDuration == YES)? NO:YES;
        NSLog (@"selectingDurata %d",selectingDuration);
        [self.tableView beginUpdates];
        [self setDuration:self.datePickerDuration];
        [self.tableView endUpdates];
        //[self.tableView reloadData];
    }
}
//--------------------------------------------//
//END TABLEVIEW
//--------------------------------------------//




- (IBAction)actionDatePicker:(id)sender {
    UIDatePicker *targetedDatePicker = sender;
    NSLog(@"%@", targetedDatePicker.date);
    if (sender == self.startDatePicker) {
        NSLog(@"START DATE");
        [self setDate:sender];
    }
}

- (IBAction)actionDatePickerDuration:(id)sender {
    //UIDatePicker *targetedDatePicker = sender;
    NSLog(@"%@", sender);
    [self setDuration:sender];
}

- (IBAction)actionPubblica:(id)sender {
    [self validateForm];
}

- (IBAction)actionPubblicaUp:(id)sender {
    [self validateForm];
}

@end
