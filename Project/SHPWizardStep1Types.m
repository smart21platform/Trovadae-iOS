//
//  SHPWizardStep1Categories.m
//  Galatina
//
//  Created by dario de pascalis on 16/02/15.
//
//

#import "SHPWizardStep1Types.h"
#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPConstants.h"
#import "SHPCategory.h"
#import "SHPImageUtil.h"
#import "SHPWizardStep2Categories.h"
#import "SHPWizardStep3Photo.h"
#import "SHPUserInterfaceUtil.h"

@implementation SHPWizardStep1Types

- (void)viewDidLoad
{
    [super viewDidLoad];
     NSLog(@"....... SHPWizardStep1Types  viewDidLoad");
    // SET COLOR CELL
    UIColor *tintColor = [UIColor clearColor];
    selectedCellBGColor = tintColor;
    
    // SET TITLE NAV BAR
    [SHPComponents customizeTitle:nil vc:self];
    
    // SET BACKGROUND+IMAGE COLOR TABLE
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
//    [self.tableView setBackgroundView:imageView];
    
    // SET WIZARD PLIST
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"wizard" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    [self.applicationContext setVariable:@"PLIST_WIZARD" withValue:plistDictionary];
    
    configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    tenantName = [configDictionary objectForKey:@"tenantName"];
    
    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    viewDictionary = [viewDictionary objectForKey:@"Wizard"];
    otypeReport =[NSString stringWithString:[viewDictionary objectForKey:@"OTYPE_REPORT"]];
    //otypeAd =[NSString stringWithString:[viewDictionary objectForKey:@"OTYPE_AD"]];

    
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepType"];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)initialize{
    //INIT TOP MESSAGE
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    //self.topMessageLabel.text = NSLocalizedString(@"header-step1-types", nil);
    self.buttonCancel.title = NSLocalizedString(@"CancelLKey", nil);
    [SHPUserInterfaceUtil applyTitleString:(NSString *)NSLocalizedString(@"header-step1-types", nil) toAttributedLabel:self.topMessageLabel];
    arrayType = [[NSMutableArray alloc] init];
    if(self.typeSelected){
        [arrayType addObject:self.typeSelected];
        [self goToStepCategory];
    }else{
        self.typeSelected = @"";
        [self initializeTypesCategories];
    }
}

-(void)goToStepCategory
{
    [self.wizardDictionary setObject:self.typeSelected forKey:WIZARD_TYPE_KEY];
    NSArray *categories = [self getCategories];
    NSLog(@"categories: %@",categories);
    if(categories.count>1){
        self.selectedCategory = nil;
        self.levelCategory = 1;
        [self performSegueWithIdentifier:@"toSelectCategoryNoAnimation" sender:self];
    }else if(categories.count>0){
        self.selectedCategory = [categories objectAtIndex:0];
        self.levelCategory = [[self.selectedCategory.oid componentsSeparatedByString:@"/"] count] - 1;
        [self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_CATEGORY_KEY];
        [self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_ICON_CATEGORY_KEY];
        if([self countSubCategories]<=1){
            [self performSegueWithIdentifier:@"toStepPhotoNoAnimation" sender:self];
        }else{
            [self performSegueWithIdentifier:@"toSelectCategoryNoAnimation" sender:self];
        }
    }
}


-(void)initializeTypesCategories {
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    NSMutableArray *arrayAllType = [[NSMutableArray alloc] init];
    
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            NSLog(@"cat +++++++++++ >>: %@", cat.type);
            if(![cat.type isEqualToString:otypeReport])[arrayAllType addObject:cat.type];
        }
    }
    [arrayType addObjectsFromArray:[[NSSet setWithArray:arrayAllType] allObjects]];
    NSLog(@"arrayType: %@", arrayType);
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    return arrayType.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *shopCellId = @"otypeCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:shopCellId];
    NSInteger catIndex = indexPath.row;
    //SHPCategory *cat = [self.categories objectAtIndex:catIndex];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
    //textLabel.text = [cat localName];
    NSString *labelType = [[NSString alloc] initWithFormat:@"type-%@", [arrayType objectAtIndex:catIndex]];
    textLabel.text = NSLocalizedString(labelType, nil);
    
    //selected color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = selectedCellBGColor;
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:20];
   
    NSString *imageName = [[NSString alloc] initWithFormat:@"icon_type_%@.png", [arrayType objectAtIndex:catIndex]];
    NSLog(@"\n imageName:: %@", imageName);
    UIImage *image = [UIImage imageNamed:imageName];
    iconView.image = image;
    [SHPImageUtil customIcon:iconView];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger catIndex = indexPath.row;
   
    self.typeSelected = [arrayType objectAtIndex:catIndex];
    [self.wizardDictionary setObject:self.typeSelected forKey:WIZARD_TYPE_KEY];
    NSLog(@"arrayType.count:  %@, %d - %@",arrayType, (int)catIndex, self.typeSelected);
    NSArray *categories = [self getCategories];
    if(categories.count>1){
        self.selectedCategory = nil;
        self.levelCategory = 1;
        [self performSegueWithIdentifier:@"toSelectCategory" sender:self];
    }else if(categories.count>0){
        self.selectedCategory = [categories objectAtIndex:0];
        self.levelCategory = [[self.selectedCategory.oid componentsSeparatedByString:@"/"] count] - 1;
        [self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_CATEGORY_KEY];
        [self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_ICON_CATEGORY_KEY];
        if([self countSubCategories]<=1){
            [self performSegueWithIdentifier:@"toStepPhoto" sender:self];
        }else{
            [self performSegueWithIdentifier:@"toSelectCategory" sender:self];
        }
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
    NSLog(@"....... Step cat WIZARD_DICTIONARY_KEY %@", self.wizardDictionary);
    if ([[segue identifier] isEqualToString:@"toSelectCategory"]) {
        SHPWizardStep2Categories *vc = (SHPWizardStep2Categories *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.levelCategory = self.levelCategory;
        vc.selectedCategory = self.selectedCategory;
    }
    else if ([[segue identifier] isEqualToString:@"toSelectCategoryNoAnimation"]) {
        SHPWizardStep2Categories *vc = (SHPWizardStep2Categories *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.levelCategory = self.levelCategory;
        vc.selectedCategory = self.selectedCategory;
        vc.backActionClose = YES;
         //diasbilito indietro
    }
    else  if ([[segue identifier] isEqualToString:@"toStepPhoto"]) {
        SHPWizardStep3Photo *vc = (SHPWizardStep3Photo *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else  if ([[segue identifier] isEqualToString:@"toStepPhotoNoAnimation"]) {
        SHPWizardStep3Photo *vc = (SHPWizardStep3Photo *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.backActionClose = YES;
        //diasbilito indietro
    }
}


-(NSMutableArray *)getCategories {
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    //NSLog(@"cat1: %@ - %d", cachedCategories,(int)cachedCategories.count);
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            
            if([cat.allowUserContentCreation boolValue]==YES && [cat.type isEqualToString:self.typeSelected]){
                NSLog(@"cat2: %@ : %@ - %@",cat.label, cat.allowUserContentCreation, self.typeSelected);
                NSUInteger numberOfOccurrences = [[cat.parent componentsSeparatedByString:@"/"] count] - 1;
                if (numberOfOccurrences==1) {
                    [categories addObject:cat];
                }
            }
        }
        //NSLog(@"categories: %@", categories);
    }
    return categories;
}

-(CGFloat)countSubCategories{
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    CGFloat counterSubCategories = 0;
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            NSLog(@"XXXXXX: %@ - %@",cat.parent, self.selectedCategory.oid);
            if([cat.allowUserContentCreation boolValue]==YES && [cat.parent isEqualToString:self.selectedCategory.oid]){
                counterSubCategories++;
            }
        }
    }
    NSLog(@"countSubCategories: %d", (int)counterSubCategories);
    return counterSubCategories;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)actionCancel:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}
@end
