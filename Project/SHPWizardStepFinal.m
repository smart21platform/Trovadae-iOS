//
//  SHPWizardStepFinal.m
//  Galatina
//
//  Created by dario de pascalis on 21/02/15.
//
//

#import "SHPWizardStepFinal.h"
#import "SHPConstants.h"
#import "SHPApplicationContext.h"
#import "SHPObjectCache.h"
#import "SHPShop.h"
#import "SHPShopDC.h"
#import "SHPSelectFacebookAccountViewController.h"
#import "SHPCategory.h"
#import "SHPProductUploaderDC.h"
#import "SHPConnectionsController.h"
#import "SHPUser.h"
#import "SHPFacebookPage.h"
#import "SHPImageUtil.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPStringUtil.h"
#import "SHPWizardHelper.h"
#import "SHPComponents.h"
#import "SHPProductUpdateDC.h"
#import "MBProgressHUD.h"
#import "SHPCaching.h"

@interface SHPWizardStepFinal ()
@end

@implementation SHPWizardStepFinal


- (void)viewDidLoad
{
    NSLog(@"....... Step FINAL");
    [super viewDidLoad];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    singlePoi=[[settingsDictionary objectForKey:@"singlePoi"] boolValue];
    shopOid=[settingsDictionary objectForKey:@"shopOid"];
    opened = false;
    self.telephoneNumberTextField.delegate = self;
    [self initialize];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(![self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] || [[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] isEqualToString:@""]){
        opened = false;
        [self resetPostMessage];
    }
    
//    if (self.applicationContext.postToFacebookPage) {
//        [self.changeFacebookAccountButton setTitle:self.applicationContext.postToFacebookPage.name forState:UIControlStateNormal];
//    } else {
//        [self.changeFacebookAccountButton setTitle:NSLocalizedString(@"FacebookDiaryLKey", nil) forState:UIControlStateNormal];
//    }
    
    if([self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY] && ![[self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY] isEqualToString:@""]){
        self.telephoneNumberTextField.placeholder =  nil;
        self.telephoneNumberTextField.text = [self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepFinal type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)initialize{
    [self getTypeAndCategory];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];

    // GET TYPE AND CATEGORY
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
    // SET TITLE NAV BAR
    UIImage *title_image;
    NSString *categoryIconURL = [self.selectedCategory iconURL];
    NSLog(@"....... %@", categoryIconURL);
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *staticIcon = [self.selectedCategory getStaticIconFromDisk];
    if (cacheIcon) {
        title_image = cacheIcon;
    }
    else if (staticIcon) {
        title_image = staticIcon;
    }
    [SHPComponents customizeTitleWithImage:title_image vc:self];
    
    [self basicSetup];
    [self localizeLabels];
    [self showPreview];
}

-(void)getTypeAndCategory{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
}

-(void)basicSetup
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = YES;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
    //---------------------------------------//
    // controllo se esiste un POI selezionato
    //---------------------------------------//
    self.selectedShop = [self.wizardDictionary objectForKey:WIZARD_POI_KEY];
    if(!self.selectedShop.name){
        self.uploadButton.enabled = NO;
        [self setupShopOnLoad];
    }
    //---------------------------------//
    self.switchFBAccount.on = NO;
    //self.changeFacebookAccountButton.enabled = NO;
    self.fbImageView.image = [UIImage imageNamed:@"FB-f-Logo__gray_144"];
    
    [self.uploadButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Helvetica-Bold" size:17.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

//--------------------------------------------------------------------------------//
// controllo se esiste un POI nella cache altrimenti lo carico passando l'id
//--------------------------------------------------------------------------------//
-(void)setupShopOnLoad {
    NSLog(@"Shop setup...");
    SHPShop *cachedShop = (SHPShop *)[self.applicationContext.objectsCache  getObject:shopOid];
    if (cachedShop) {
        self.selectedShop = cachedShop;
        [self updateView];
    }
    else{
        if(![self.wizardDictionary objectForKey:WIZARD_POI_KEY]){
            self.selectedShop.oid = shopOid;
            self.selectedShop.source = @"";
        }
        [self loadShop];
    }
}

-(void)loadShop {
    
    self.shopDC = [[SHPShopDC alloc] init];
    [self.shopDC setShopsLoadedDelegate:self];
    [self.shopDC searchByShopId:shopOid];
}

// SHOP DELEGATE
- (void)shopsLoaded:(NSArray *)shops {
    NSLog(@"Nr of Shops in delegate: %lu", (unsigned long)[shops count]);
    if(shops.count > 0) {
        self.selectedShop = [shops objectAtIndex:0];
        NSLog(@"ADDING SHOP TO OBJECTS CACHE");
        [self.applicationContext.objectsCache addObject:self.selectedShop withKey:self.selectedShop.oid];
        NSLog(@"SHOP LOADED: %@ ", self.selectedShop);
        [self.wizardDictionary setObject:self.selectedShop forKey:WIZARD_POI_KEY];
        [self updateView];
    } else {
        NSLog(@"Shop not found!");
    }
}

-(void)updateView{
    self.uploadButton.enabled = YES;
    [self showPreview];
}

//end detect POI
//--------------------------------------------------------------------------------//


-(void)localizeLabels {
    NSLog(@"localizeLabels!...........................");
    // init top message
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step8-end-%@", typeSelected];
    NSString *textHeader = [[NSString alloc] initWithFormat:@"%@ *%@*", NSLocalizedString(headerLabel, nil), self.selectedCategory.label];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)NSLocalizedString(@"header-step8-end", nil)  toAttributedLabel:self.labelHeader];

    // init next button
    self.uploadButton.title = NSLocalizedString(@"SendLKey", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"SendLKey", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];
    
    [self.buttonAddDescription setTitle:NSLocalizedString(@"labelAddDescription", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonAddDescription layer]];

    //self.labelDescription.text = NSLocalizedString(@"DescriptionLabelLKey", nil);
    self.labelValidita.text = NSLocalizedString(@"offerValidLKey", nil);
    self.shopLabel.text = NSLocalizedString(@"ShopLabelLKey", nil);
    
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

-(void)showPreview {
    //TITLE
    NSLog(@"................. TITLE %@", [self.wizardDictionary objectForKey:WIZARD_TITLE_KEY]);
    titlePost=[self.wizardDictionary objectForKey:WIZARD_TITLE_KEY];
    if(titlePost && ![titlePost isEqualToString:@""]){
        self.titleLabel.text=titlePost;
    }else{
        if(self.selectedShop.name)titlePost = self.selectedShop.name;
        self.titleLabel.text=titlePost;
    }
    //NSLog(@"................. TITLE %@",titlePost);
    //NSLog(@"................. TITLE %@",self.selectedShop.name);
    
    //DESCRIPTION
    NSLog(@"..XXX........... DESCRIPTION %@", [self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY]);
    if([self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY]){
        opened=true;
    }
    
    //[self validateForm];
//    descriptionPost=[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY];
//    if(!descriptionPost || [descriptionPost isEqualToString:@""] ){
//        if(!titlePost || [titlePost isEqualToString:@""]){
//            descriptionPost=self.selectedShop.name;
//        }
//    }
//    self.descriptionLabel.text = descriptionPost;
    
    
    //DATE-FORMATTER
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy HH:mm Z"];
    NSDate *startDate = [df dateFromString: [self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY]];
    NSDate *endDate = [df dateFromString: [self.wizardDictionary objectForKey:WIZARD_DATE_END_KEY]];
    NSString *labelDateStart = [dateFormatter stringFromDate:startDate];
    NSString *labelDateEnd = [dateFormatter stringFromDate:endDate];
    if([labelDateEnd isEqual:labelDateStart] ) {
        labelDurate = [[[NSString alloc] initWithFormat:@"%@", labelDateStart] capitalizedString];
        NSLog(@"1%@ %@ ",NSLocalizedString(@"offerValidLKey", nil),labelDateStart);
    }else{
        NSLog(@"SONO DIFFERENTI!");
        // NSLocalizedString(@"offerValidLKey", nil),
        labelDurate = [[NSString alloc] initWithFormat:@"%@ *%@* %@ *%@*",NSLocalizedString(@"fromLKey", nil),[labelDateStart capitalizedString], NSLocalizedString(@"toLKey", nil),[labelDateEnd capitalizedString]];
    }
    [SHPUserInterfaceUtil applyTitleString:(NSString *)labelDurate toAttributedLabel:self.dateStartLabel];
    //self.dateEndLabel.text = labelDateEnd;
    NSLog(@"................. DATE_START %@", [self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY]);
    NSLog(@"................. DATE_END %@", [self.wizardDictionary objectForKey:WIZARD_DATE_END_KEY]);
    NSLog(@"................. ds: %@", labelDateStart);
    NSLog(@"................. de: %@", labelDateEnd);
    
    //SHOP FORMATTER
    NSLog(@"shop: %@",self.selectedShop);
    self.shopNameLabel.text = @"";
    self.shopLabel.text = @"";
    if(self.selectedShop.name)self.shopNameLabel.text = self.selectedShop.name;
    if(self.selectedShop.formattedAddress)self.shopLabel.text = self.selectedShop.formattedAddress;
    
    //PRICE FORMATTER
    price_text_start=@"";
    startPriceNum = [SHPStringUtil string2Number:[[self.wizardDictionary objectForKey:WIZARD_START_PRICE_KEY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (startPriceNum) {
        price_text_start = [NSString stringWithFormat:@"%.2f", [startPriceNum floatValue]];
        self.startPriceLabel.text=[price_text_start stringByAppendingString:NSLocalizedString(@"wizardCurrencyLKey", nil)];
    }
    price_text_end=@"";
    endPriceNum = [SHPStringUtil string2Number:[[self.wizardDictionary objectForKey:WIZARD_PRICE_KEY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (endPriceNum) {
        price_text_end = [NSString stringWithFormat:@"%.2f", [endPriceNum floatValue]];
        self.endPriceLabel.text=[price_text_end stringByAppendingString:NSLocalizedString(@"wizardCurrencyLKey", nil)];
    }

    if(!endPriceNum || endPriceNum<=0){
        self.priceLabel.text=[price_text_start stringByAppendingString:NSLocalizedString(@"wizardCurrencyLKey", nil)];
        self.startPriceLabel.text=@"";
    }

    if ([self.wizardDictionary objectForKey:WIZARD_PERCENT_KEY]) {
        self.dealLabel.text=[self.wizardDictionary objectForKey:WIZARD_PERCENT_KEY];
    }else{
        self.dealLabel.hidden=YES;
        self.startPriceLabel.hidden=YES;
    }
    
    //PHOTO FORMATTER
    self.photoImageView.image = (UIImage *)[self.wizardDictionary objectForKey:WIZARD_IMAGE_KEY];
    
    //TELEPHON FORMATTER
    if ([SHPApplicationContext restoreLastPhone] && ![self.wizardDictionary objectForKey:WIZARD_TELEPHONE_KEY]) {
        self.telephoneNumberTextField.text = [SHPApplicationContext restoreLastPhone];
    }
    
    //CATEGORY ICON FORMATTER
    NSString *categoryIconURL = [self.selectedCategory iconURL];
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
    //UIImage *staticIcon = [self.selectedCategory getStaticIconFromDisk];
    if (cacheIcon) {
        self.categoryImageView.image = cacheIcon;
    }
    else if (archiveIcon) {
        NSLog(@"archiveIcon");
        self.categoryImageView.image = archiveIcon;
    }
    //    else if (staticIcon) {
    //        self.categoryImageView.image = staticIcon;
    //    }
}

//-----------------------------------------------//
//START ADD DESCRIPTION
//-----------------------------------------------//
-(void)customSetup
{
    NSString *trimmedDescription = [[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedDescription) {
        self.descriptionTextView.text = trimmedDescription;
        self.descriptionTextView.textColor = [UIColor blackColor];
    }
    [self validateForm];
}


-(void)dismissKeyboard {
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

- (void) displayViewController: (UIViewController*) controller;
{
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)resetPostMessage
{
    NSLog(@"resetPostMessage...");
    self.descriptionTextView.text = kPlaceholderDescription;
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Begin...");
    // Clear the message text when the user starts editing
    if ([textView.text isEqualToString:kPlaceholderDescription]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"End...");
    // Reset to placeholder text if the user is done
    // editing and no message has been entered.
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
    //NSUInteger characterCount = [trimmedDescription length];
    BOOL valid = true;
    if([descriptionPost isEqualToString:@""]){
        //[self resetPostMessage];
        //self.minimumWordsMessageLabel.hidden = NO;
        valid = false;
        //self.nextButton.enabled = NO;
    }else if([descriptionPost isEqualToString:kPlaceholderDescription]) {// || characterCount < MIN_CHARACTERS_DESCRIPTION
        //NSLog(@"INVALID");
        //self.minimumWordsMessageLabel.hidden = NO;
        valid = false;
        //self.nextButton.enabled = NO;
    } else {
        //NSLog(@"VALID!");
        //self.minimumWordsMessageLabel.hidden = YES;
        valid = true;
        [self.wizardDictionary setObject:descriptionPost forKey:WIZARD_DESCRIPTION_KEY];
    }
    
}
//-----------------------------------------------//
//END ADD DESCRIPTION
//-----------------------------------------------//
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing...");
    textField.placeholder = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing...");
    textField.placeholder =  NSLocalizedString(@"telephone-number-textField", nil);
}


// TABLE VIEW

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger super_height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    NSLog(@"................. identifierCell %@ - %@ - %d", identifierCell,[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY] ,opened );
    if([identifierCell isEqualToString:@"idCellTitle"]){
        if (!titlePost || [titlePost isEqualToString:@""] || [[typeDictionary valueForKey:@"title"] isEqualToString:@"0"]){
            //return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellAddDescription"] && opened==false){
        return 0.0;
    }
    else if([identifierCell isEqualToString:@"idCellButtonDescription"] && (opened==true || [[typeDictionary valueForKey:@"description"] isEqualToString:@"0"])){
        return 0.0;
    }
    else if([identifierCell isEqualToString:@"idCellTime"]){
        if (![self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY]){
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idDivisorTime"]){
        if (![self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY]){
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellPrice"]){
        if (!startPriceNum || endPriceNum){
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellDiscount"]){
        if (!endPriceNum){
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idDivisorPrice"]){
        if ((!startPriceNum || endPriceNum) && !endPriceNum){
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellShared"]){
        if (!self.applicationContext.loggedUser.facebookAccessToken){
            return 0.0;
        }
    }
    else if([identifierCell isEqualToString:@"idCellTelephone"] && [[typeDictionary valueForKey:@"telephone"] isEqualToString:@"0"]){
            return 0.0;
    }

    return super_height;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"returnToSelectFacebook"]) {
        SHPSelectFacebookAccountViewController *selectVC = (SHPSelectFacebookAccountViewController *)[segue destinationViewController];
        selectVC.applicationContext = self.applicationContext;
    } else if ([[segue identifier] isEqualToString:@"selectFacebookAccountSegue"]) {
        SHPSelectFacebookAccountViewController *selectVC = (SHPSelectFacebookAccountViewController *)[segue destinationViewController];
        selectVC.applicationContext = self.applicationContext;
    }
}

//------------------------------------//
// START SAVE POST
//------------------------------------//
-(void)sendPhotoWithMetadata {
    if(!descriptionPost){
        descriptionPost = @" ";
    }
    if(!titlePost){
        titlePost = @" ";
    }
    self.uploaderDC = [[SHPProductUploaderDC alloc] init];
    if (self.switchFBAccount.on) {
        NSLog(@">>>>>> sharing on facebook is on.");
        self.uploaderDC.onFinishPublishToFacebook = YES;
    }
    [self.applicationContext.connectionsController addDataController:self.uploaderDC];
    NSString *start_date_s = [self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY] ? [self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY] : @"";
    
    // persist last phone number
    [SHPApplicationContext saveLastPhone:self.telephoneNumberTextField.text];
    self.uploaderDC.applicationContext = self.applicationContext;
    [self.uploaderDC setMetadata:[self.wizardDictionary objectForKey:WIZARD_IMAGE_KEY]
                           brand:@"" //unused
                     categoryOid:self.selectedCategory.oid
                         shopOid:self.selectedShop.oid
                      shopSource:self.selectedShop.source
                             lat:nil
                             lon:nil
       shopGooglePlacesReference:self.selectedShop.googlePlacesReference
                           title:titlePost //[self.wizardDictionary objectForKey:WIZARD_TITLE_KEY]
                     description:descriptionPost//[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY]
                           price:price_text_end
                      startprice:price_text_start
                       telephone:self.telephoneNumberTextField.text
                       startDate:start_date_s
                         endDate:[self.wizardDictionary objectForKey:WIZARD_DATE_END_KEY]
                      properties:nil];
    [self.uploaderDC send];
}
//------------------------------------//
// END SAVE POST
//------------------------------------//



//------------------------------------//
// START UPDATE POST
//------------------------------------//
-(void)sendMetadataForUpdate{
    //Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"SavingLKey", nil);
    [hud show:YES];
    
    if(!descriptionPost){
        descriptionPost = @" ";
    }
    if(!titlePost){
        titlePost = @" ";
    }
    
    NSString *start_date_s = [self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY] ? [self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY] : @"";
    SHPProductUpdateDC *productUpload = [[SHPProductUpdateDC alloc]init];
    productUpload.delegateViewController = self;
    productUpload.applicationContext = self.applicationContext;
    
    [productUpload update: [self.wizardDictionary objectForKey:WIZARD_PRODUCT_ID_KEY]
                    title:titlePost//[self.wizardDictionary objectForKey:WIZARD_TITLE_KEY]
              description:descriptionPost//[self.wizardDictionary objectForKey:WIZARD_DESCRIPTION_KEY]
                    price:price_text_end
               startprice:price_text_start
                telephone:self.telephoneNumberTextField.text
                startDate:start_date_s
                  endDate:[self.wizardDictionary objectForKey:WIZARD_DATE_END_KEY]];
}
//------------------------------------//
// END UPDATE POST
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
        NSLog(@"sendPhotoWithMetadata");
        [self sendPhotoWithMetadata];
        NSLog(@"performSegueWithIdentifier");
        [self performSegueWithIdentifier:@"toFirstStep" sender:self];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


//- (IBAction)facebookSwitchValueChanged:(id)sender {
//    NSLog(@"facebookSwitchValueChanged %d", opened);
//    switch (self.switchFBAccount.on) {
//        case YES:
//            self.fbImageView.image = [UIImage imageNamed:@"FB-f-Logo__blue_144"];
//            self.changeFacebookAccountButton.enabled = YES;
//            //            if (!self.applicationContext.loggedUser.facebookAccessToken) {
//            //                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Connect to Facebook" message:@"You must connect your profile to Facebook to use this option. This option" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            //                [alertView show];
//            //                self.facebookSwitch.on = NO;
//            //            }
//            break;
//        case NO:
//            self.fbImageView.image = [UIImage imageNamed:@"FB-f-Logo__gray_144"];
//            self.changeFacebookAccountButton.enabled = NO;
//            break;
//        default:
//            break;
//    }
//}

- (IBAction)uploadAction:(id)sender {
    [self executeUploadAction];
}

- (IBAction)actionButtonCellNext:(id)sender {
    [self executeUploadAction];
}

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

- (IBAction)actionSwitchFBAccount:(id)sender {
    NSLog(@"actionSwitchFBAccount %d", opened);
    switch (self.switchFBAccount.on) {
        case YES:
            self.fbImageView.image = [UIImage imageNamed:@"FB-f-Logo__blue_144.png"];
//self.changeFacebookAccountButton.enabled = YES;
            //            if (!self.applicationContext.loggedUser.facebookAccessToken) {
            //                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Connect to Facebook" message:@"You must connect your profile to Facebook to use this option. This option" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //                [alertView show];
            //                self.facebookSwitch.on = NO;
            //            }
            break;
        case NO:
            self.fbImageView.image = [UIImage imageNamed:@"FB-f-Logo__gray_144.png"];
//self.changeFacebookAccountButton.enabled = NO;
            break;
        default:
            break;
    }
}


@end
