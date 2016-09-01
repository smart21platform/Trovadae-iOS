//
//  SHPWizardStep5Poi.m
//  Galatina
//
//  Created by dario de pascalis on 18/02/15.
//
//

#import "SHPWizardStep5Poi.h"
#import "SHPApplicationContext.h"
#import "SHPConstants.h"
#import "SHPComponents.h"
#import "SHPCategory.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPImageUtil.h"
#import "SHPShop.h"
#import "SHPChooseShopViewController.h"
#import "SHPWizardStep6Date.h"
#import "SHPWizardStep7Price.h"
#import "SHPWizardStepFinal.h"

@interface SHPWizardStep5Poi ()
@end

static NSString *LAST_LOADED_NEAREST_SHOPS = @"lastLoadedNearestShops";

@implementation SHPWizardStep5Poi

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"WIZARD_POI_KEY: %@ - %@", [self.wizardDictionary objectForKey:WIZARD_POI_KEY], self.selectedShop.name);
    if(self.selectedShop){
        [self titleForShopLabel];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepPoi type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.selectedShop && ![self.selectedShop.name isEqualToString:@""]){
        [self.wizardDictionary setObject:self.selectedShop forKey:WIZARD_POI_KEY];
    }else{
        [self.wizardDictionary removeObjectForKey:WIZARD_POI_KEY];
    }
}

-(void)initialize{
    [self getTypeAndCategory];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
    
    // SET TITLE NAV BAR
    UIImage *title_image;
    NSString *categoryIconURL = [self.selectedCategory iconURL];
    NSLog(@".......cat URL %@", categoryIconURL);
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
    [self customStepSetup];
}

-(void)getTypeAndCategory{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
}

-(void)basicSetup {
    // init next button
    self.nextButton.title = NSLocalizedString(@"wizardNextButton", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"wizardNextButton", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];
    
    //NSLog(@"WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY %@", [self.wizardDictionary objectForKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY]);
    NSLog(@"topMessageLabel %@", self.topMessageLabel);
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step5-poi-%@", typeSelected];
    NSString *hintLabel = [[NSString alloc] initWithFormat:@"hint-step5-poi-%@", typeSelected];
    NSString *textHeader = NSLocalizedString(headerLabel, nil);
    NSString *textHint = NSLocalizedString(hintLabel, nil);
    
    
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHint  toAttributedLabel:self.hintLabel];
}

-(void)customStepSetup {
    SHPShop *lastUsedShop;
     BOOL valid = true;
    if([self.wizardDictionary objectForKey:WIZARD_POI_KEY]){
        self.selectedShop = [self.wizardDictionary objectForKey:WIZARD_POI_KEY];
    }
    else{
        lastUsedShop = [SHPApplicationContext restoreLastWizardShop];
        if (lastUsedShop) {
            valid = true;
            self.selectedShop = lastUsedShop;
            [self titleForShopLabel];
        } else {
            valid = false;
            self.selectedShop = nil;
            [self titleForShopLabel];
        }
    }
    
    NSString *checkType = [typeDictionary valueForKey:@"poi"];
    NSLog(@"checkType: %@ - valid:%d",checkType, valid);
    if([checkType isEqualToString:@"2"]){
        if(valid == false){
            self.nextButton.enabled = NO;
            self.buttonCellNext.enabled = NO;
            self.buttonCellNext.alpha = 0.5;
        }else{
            self.nextButton.enabled = YES;
            self.buttonCellNext.enabled = YES;
            self.buttonCellNext.alpha = 1;
        }
    }else{
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
    }

    //NSLog(@"SHOP OID---------------> %@", lastUsedShop.oid);
    //NSLog(@"SHOP NAME---------------> %@", lastUsedShop.name);
}

-(void)titleForShopLabel {
    if (self.selectedShop) {
        NSLog(@"OK SELECTED SHOP!");
        self.selectedShopLabel.text = self.selectedShop.name;
        self.shopAddress.text = self.selectedShop.formattedAddress;
        [self.buttonChange setTitle:NSLocalizedString(@"wizardChangeButton", nil) forState:UIControlStateNormal];
        [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonChange layer]];
    } else {
        NSLog(@"NO SELECTED SHOP!");
        self.selectedShopLabel.text = NSLocalizedString(@"poiPlaceholderLKey", nil);
        self.shopAddress.text = @"";
        [self.buttonChange setTitle:NSLocalizedString(@"wizardAddButton", nil) forState:UIControlStateNormal];
        [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonChange layer]];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)selectSegue
{
    NSLog(@"typeDictionary %@ - %@",typeDictionary, typeSelected);
//    if(![[typeDictionary valueForKey:@"title"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepTitle" sender:self];
//    }else if(![[typeDictionary valueForKey:@"poi"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepPOI" sender:self];
//    }else
    if(![[typeDictionary valueForKey:@"date"] isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"toStepDate" sender:self];
    }else if(![[typeDictionary valueForKey:@"price"] isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"toStepPrice" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toStepFinal" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    if(self.selectedShop){
        [self.wizardDictionary setObject:self.selectedShop forKey:WIZARD_POI_KEY];
        [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
    }
    
    if ([[segue identifier] isEqualToString:@"toStepDate"]) {
        SHPWizardStep6Date *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"ChooseShop"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SHPChooseShopViewController *chooseShopVC = (SHPChooseShopViewController *)[[navigationController viewControllers] objectAtIndex:0];
        chooseShopVC.modalCallerDelegate = self;
        chooseShopVC.shops = (NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_NEAREST_SHOPS];
        chooseShopVC.lastUsedShops = self.applicationContext.onDiskLastUsedShops;
        chooseShopVC.applicationContext = self.applicationContext;
        chooseShopVC.category = self.selectedCategory.oid;
    }
    else if ([[segue identifier] isEqualToString:@"toStepPrice"]) {
        SHPWizardStep7Price *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toStepFinal"]) {
        SHPWizardStepFinal *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
}


- (IBAction)actionButtonCellNext:(id)sender {
    [self selectSegue];
}

- (IBAction)actionButtonChange:(id)sender {
    [self performSegueWithIdentifier:@"ChooseShop" sender:self];
}

- (IBAction)actionNext:(id)sender {
    [self selectSegue];
}

- (IBAction)unwindToWizardStep5Poi:(UIStoryboardSegue*)sender
{
    NSLog(@"SELECTED SHOP: %@", self.selectedShop);
    if(self.selectedShop){
        [self titleForShopLabel];
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
    }
}

@end
