//
//  SHPWizardStep7Price.m
//  Galatina
//
//  Created by dario de pascalis on 20/02/15.
//
//

#import "SHPWizardStep7Price.h"
#import "SHPConstants.h"
#import "SHPApplicationContext.h"
#import "SHPCategory.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPImageUtil.h"
#import "SHPStringUtil.h"
#import "SHPComponents.h"
#import "SHPWizardHelper.h"
#import "SHPWizardStepFinal.h"
#import "SHPImageUtil.h"

@interface SHPWizardStep7Price ()
@end

@implementation SHPWizardStep7Price

//********************* LOCAL VARS ******************************/
static int PRICE_MAX_LENGTH = 8;
//*********************    END     ******************************/

- (void)viewDidLoad
{
    NSLog(@"....... Step PRICE");
    [super viewDidLoad];
    opened = false;
    valid = false;
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepPrice type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.priceTextView && ![self.priceTextView.text isEqualToString:@""]){
        [self.wizardDictionary setObject:self.priceTextView.text forKey:WIZARD_PRICE_KEY];
    }else{
        [self.wizardDictionary removeObjectForKey:WIZARD_PRICE_KEY];
    }
}

-(void)initialize{
    /********************************/
    [self getTypeAndCategory];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
    price_num = 0.0;
    start_price_num = 0.0;
    PRICE_MAX_LENGTH = 8;
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
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    NSLog(@"wizardDictionary %@", self.wizardDictionary);
    
    if([self.wizardDictionary objectForKey:WIZARD_PRICE_KEY] && ![[self.wizardDictionary objectForKey:WIZARD_PRICE_KEY] isEqualToString:@""]){
        opened = true;
    }
    [self basicSetup];
    [self customStepSetup];
    [self validateForm];
    [self enableButtonNextStep];
}

-(void)getTypeAndCategory{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
}

-(void)basicSetup {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
    
    // init wizard dictionary
    self.percPrice.hidden = true;
    self.errorMessageLabel.hidden=false;
    
    // init next button
    self.nextButton.title = NSLocalizedString(@"wizardNextButton", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"wizardNextButton", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];
    
    [self.buttonAddDiscount setTitle:NSLocalizedString(@"labelPriceDiscount", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonAddDiscount layer]];
    
    
    // init top message
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step7-price-%@", typeSelected];
    NSString *hintLabel = [[NSString alloc] initWithFormat:@"hint-step7-price-%@", typeSelected];
    NSString *textHeader = NSLocalizedString(headerLabel, nil);
    NSString *textHint = NSLocalizedString(hintLabel, nil);
    
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHint  toAttributedLabel:self.hintLabel];

    
//    //    NSLog(@"....... %@", [self.wizardDictionary objectForKey:WIZARD_STEP_PRICE_TOP_MESSAGE_KEY]);
//    //    self.topMessageLabel.text = (NSString *) [self.wizardDictionary objectForKey:WIZARD_STEP_PRICE_TOP_MESSAGE_KEY];
//    [SHPUserInterfaceUtil applyTitleString:(NSString *) [self.wizardDictionary objectForKey:WIZARD_STEP_PRICE_TOP_MESSAGE_KEY] toAttributedLabel:self.topMessageLabel];
//    [SHPUserInterfaceUtil applyTitleString:(NSString *) [self.wizardDictionary objectForKey:WIZARD_STEP_PRICE_HINT_MESSAGE_KEY] toAttributedLabel:self.hintLabel];
//    
//    [self.nextButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} forState:UIControlStateDisabled];
//    UIImage *backImage = [[UIImage imageNamed:@"button_navbar_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0.0f, 0, 24.0f)];
//    UIImage *backImageDisabled = [[UIImage imageNamed:@"button_navbar_disabled_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0.0f, 0, 24.0f)];
//    
//    [self.nextButton setBackgroundImage:backImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.nextButton setBackgroundImage:backImageDisabled forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
}

-(void)customStepSetup {
    // localize
    self.currencyLabel.text = NSLocalizedString(@"wizardCurrencyLKey", nil);
    self.currencyDiscountLabel.text = NSLocalizedString(@"wizardCurrencyLKey", nil);
    self.errorMessageLabel.text = NSLocalizedString(@"wizardPriceErrorLKey", nil);
    //self.freeLabel.text = NSLocalizedString(@"freePriceLKey", nil);
    if([self.wizardDictionary objectForKey:WIZARD_PRICE_KEY]){
        self.priceTextView.text=[self.wizardDictionary objectForKey:WIZARD_PRICE_KEY];
    }else{
        self.priceTextView.placeholder = NSLocalizedString(@"PriceLabelLKey", nil);
    }
    if([self.wizardDictionary objectForKey:WIZARD_START_PRICE_KEY]){
        self.startPriceTextView.text=[self.wizardDictionary objectForKey:WIZARD_START_PRICE_KEY];
    }else{
        self.startPriceTextView.placeholder = NSLocalizedString(@"PriceLabelLKey", nil);
    }
    self.labelStartPriceText.text = NSLocalizedString(@"wizardDealStartPricePlaceholderLKey", nil);
    self.labelPriceText.text = NSLocalizedString(@"wizardDealPricePlaceholderLKey", nil);
    self.priceTextView.delegate = self;
    self.startPriceTextView.delegate = self;
    self.freeLabel.hidden = YES;
    self.errorMessageLabel.hidden = YES;
}

-(void)dismissKeyboard {
    NSLog(@"dismissing keyboard");
    //[self enableButtonNextStep];
    if([self.priceTextView.text isEqualToString:@""]){
        opened = false;
    }
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat super_height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.row == 3 && opened == true) {
        return 110;
    }
    else if (indexPath.row == 3 ) {
        return 0;
    }
    if (indexPath.row == 2 && opened == true) {
        return 65;
    }
    return super_height;
}

-(void)validateForm
{
    self.adviceMessageLabel.text = @"";
    self.errorMessageLabel.text = @"";
    self.adviceMessageLabel.hidden = true;
    self.adviceMessageLabel.textColor = [UIColor whiteColor];
    self.percPrice.hidden = true;
    self.errorMessageLabel.hidden=false;
    self.errorMessageLabel.textColor = [UIColor redColor];
    self.percPrice.text = @"";
    price_num=0;
    start_price_num=0;
    
    NSLog(@"validating...");
    NSString *start_price_text = [self.startPriceTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *price_text = [self.priceTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSNumber *ns_num = [SHPStringUtil string2Number:price_text];
    if (ns_num) {
        price_num = [ns_num floatValue];
    }
    
    ns_num = [SHPStringUtil string2Number:start_price_text];
    if (ns_num) {
        start_price_num = [ns_num floatValue];
    }
    
    if ((price_num && !start_price_num) || (price_num && start_price_num && price_num >= start_price_num)) {
        NSString *msg = NSLocalizedString(@"PriceGreaterThanOrEqualToStartPriceNotAllowed", nil);
        self.errorMessageLabel.text = msg;
        self.percPrice.hidden = true;
        self.adviceMessageLabel.hidden = true;
        valid = false;
        return;
    }else if(start_price_num >0 && price_num<=0) {
        valid = true;
        return;
    }
    
    if(price_num>0 && start_price_num>0){
        // calcolo percentuale sconto.
        float perc_point = start_price_num / 100.0;
        float diff = start_price_num - price_num;
        float perc = diff / perc_point;
        NSLog(@"perc %f", perc);
        int percRound = (int) round(perc);
        NSLog(@"percRound %d", percRound);
        self.percPrice.text = [NSString stringWithFormat:NSLocalizedString(@"SCONTO %d%%",nil), percRound];
        NSString *msg;
        if(percRound<33.34){
            msg = NSLocalizedString(@"smallDealer", nil);
            self.adviceMessageLabel.backgroundColor = [UIColor orangeColor];
        }else if (percRound<66.67){
            msg = NSLocalizedString(@"mediumDealer", nil);
            self.adviceMessageLabel.textColor = [UIColor grayColor];
            self.adviceMessageLabel.backgroundColor = [UIColor yellowColor];
        }else{
            msg = NSLocalizedString(@"bigDealer", nil);
            self.adviceMessageLabel.backgroundColor = [UIColor greenColor];
        }
        self.adviceMessageLabel.text = msg;
        self.percPrice.hidden = NO;
        self.adviceMessageLabel.hidden = false;
        valid = true;
        return;
    } else {
        self.percPrice.text = @"";
        self.percPrice.hidden = true;
        self.adviceMessageLabel.hidden = true;
        valid = false;
        return;
    }

    return;
}

-(void)enableButtonNextStep{
    NSString *checkType = [typeDictionary valueForKey:@"price"];
    NSLog(@"checkType: %@ - valid:%d",checkType, valid);
    if([checkType isEqualToString:@"2"] && valid == true){
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
    }
    else if([checkType isEqualToString:@"2"]){
        self.nextButton.enabled = NO;
        self.buttonCellNext.enabled = NO;
        self.buttonCellNext.alpha = 0.5;
    }
    else{
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > PRICE_MAX_LENGTH) ? NO : YES;
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Alert Button!");
    switch (buttonIndex) {
        case 0:
        {
            break;
        }
        case 1:
        {
            [self executeNextAction];
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // update wizard with user data
    NSString *price_to_send = [self.priceTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *start_price_to_send = [self.startPriceTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *percent_price =self.percPrice.text;
    
    [self.wizardDictionary setObject:price_to_send forKey:WIZARD_PRICE_KEY];
    [self.wizardDictionary setObject:start_price_to_send forKey:WIZARD_START_PRICE_KEY];
    [self.wizardDictionary setObject:percent_price forKey:WIZARD_PERCENT_KEY];
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
    
    if ([[segue identifier] isEqualToString:@"toStepFinal"]) {
        SHPWizardStepFinal *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
}

-(void)executeNextAction {
    NSLog(@"wizardDictionary %@", self.wizardDictionary);
    [self performSegueWithIdentifier:@"toStepFinal" sender:self];
}

- (IBAction)priceEditingChanged:(id)sender {
    NSLog(@"changed %@", self.priceTextView.text);
    //    NSString *price_text = [self.priceTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self validateForm];
    [self enableButtonNextStep];
}

- (IBAction)nextAction:(id)sender {
    [self executeNextAction];
}


- (IBAction)actionAddDiscount:(id)sender {
     NSLog(@"actionAddDiscount %d", opened);
    if(opened == true){
        opened = false;
    }else{
        opened = true;
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)actionButtonCellNext:(id)sender {
   [self executeNextAction];
}

@end