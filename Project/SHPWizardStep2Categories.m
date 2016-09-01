//
//  SHPWizardStep2Categories.m
//  Galatina
//
//  Created by dario de pascalis on 17/02/15.
//
//

#import "SHPWizardStep2Categories.h"
#import "SHPApplicationContext.h"
#import "SHPComponents.h"
#import "SHPConstants.h"
#import "SHPCategory.h"
#import "SHPImageUtil.h"
#import "SHPCaching.h"
#import "SHPImageRequest.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPCategory.h"
#import "SHPWizardStep3Photo.h"
#import "SHPWizardStepStartReport.h"


@implementation SHPWizardStep2Categories

- (void)viewDidLoad
{
    [super viewDidLoad];
    // SET COLOR CELL
    UIColor *tintColor = [UIColor clearColor];//[SHPImageUtil colorWithHexString:@"cccccc"];
    selectedCellBGColor = tintColor;
    // SET TITLE NAV BAR
    [SHPComponents customizeTitle:nil vc:self];
    // SET BACKGROUND+IMAGE COLOR TABLE
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    //[self.tableView setBackgroundView:imageView];
    configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    tenantName = [configDictionary objectForKey:@"tenantName"];

    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    viewDictionary = [viewDictionary objectForKey:@"Wizard"];
    otypeReport =[NSString stringWithString:[viewDictionary objectForKey:@"OTYPE_REPORT"]];
    
    [self customBackButton];
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 }

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepCategory type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)initialize{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    NSString *labelType = [[NSString alloc] initWithFormat:@"header-step2-categories-%@", typeSelected];
    NSString *textHeader = NSLocalizedString(labelType, nil);
    //self.topMessageLabel.text = textHeader;
    [SHPUserInterfaceUtil applyTitleString:(NSString *) textHeader toAttributedLabel:self.topMessageLabel];
    [self initializeCategories];
    if(self.categories.count==1){
        self.selectedCategory = [self.categories objectAtIndex:0];
        [self selectCategoryAndPerformSegue];
    }
}

-(void)initializeCategories {
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    self.categories = [[NSMutableArray alloc] init];
    NSString *selectedCatOid;
    if(!self.selectedCategory){
        selectedCatOid=@"/";
    }else{
        selectedCatOid=self.selectedCategory.oid;
    }
    if(!self.levelCategory)self.levelCategory=1;
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            if([cat.allowUserContentCreation boolValue]==YES && [cat.type isEqualToString:typeSelected]){
                NSUInteger numberOfOccurrences = [[cat.parent componentsSeparatedByString:@"/"] count] - 1;
                BOOL visibility = [cat getVisibility:CATEGORY_VISIBILITY_WIZARD];
                NSLog(@"cat: %@ - %d - %d:%d", cat.label, (int)numberOfOccurrences, (int)cat.visibility, visibility);
                
                if (numberOfOccurrences==self.levelCategory && [cat.parent hasPrefix:selectedCatOid] && visibility == YES) {
                    NSLog(@"cat.type %@ - [cat.allowUserContentCreation boolValue]: %d", cat.type, [cat.allowUserContentCreation boolValue]);
                    [self.categories addObject:cat];
                }
            }
        }
    }
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


#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *shopCellId = @"CategoryCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:shopCellId];
    NSInteger catIndex = indexPath.row;
    SHPCategory *cat = [self.categories objectAtIndex:catIndex];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
    textLabel.text = [cat localName];
    
    //selected color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = selectedCellBGColor;
    //cell.selectedBackgroundView = myBackView; [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:20];
    [SHPImageUtil customIcon:iconView];
    NSString *categoryIconURL = [cat iconURL];
    NSLog(@"....... %@", categoryIconURL);
    
    //REGOLE UPLOAD IMAGES CATEGORIES:
    // 1- carico image dalla cache se presente in cache
    // SALTO 2- carico image dal disco se salvata in memoria e aggiungo alla cache
    // 3- mostro immagine cache se è presente e poi carico image, salvo su disco e aggiungo alla cache
    // 4- carico image di default
    
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
    //UIImage *staticIcon = [cat getStaticIconFromDisk];
    
    if (cacheIcon) {
        iconView.image = cacheIcon;
    }
    //else if (staticIcon) {
    //NSLog(@"staticIcon");
    //iconView.image = staticIcon;
    //}
    else {
        if (archiveIcon) {
            NSLog(@"archiveIcon");
            iconView.image = archiveIcon;
        }
        //iconView.image = nil;
        SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
        [imageRquest downloadImage:categoryIconURL
                 completionHandler:
         ^(UIImage *image, NSString *imageURL, NSError *error) {
             if (image) {
                 //save on disk
                 [SHPCaching saveImage:image inFile:imageURL];
                 //save in cache
                 [self.applicationContext.categoryIconsCache addImage:image withKey:imageURL];
                 NSArray *indexes = [self.tableView indexPathsForVisibleRows];
                 for (NSIndexPath *index in indexes) {
                     if (index.row == indexPath.row) {
                         UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
                         UIImageView *iconV= (UIImageView *)[cell viewWithTag:20];
                         iconV.image = image;
                     }
                 }
             } else {
                 UIImage *icon = [UIImage imageNamed:@"category_icon__default"];
                 iconView.image = icon;
                 [self.applicationContext.categoryIconsCache addImage:icon withKey:imageURL];
             }
         }];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger catIndex = indexPath.row;
    self.selectedCategory = [self.categories objectAtIndex:catIndex];
    [self selectCategoryAndPerformSegue];
}

-(void)selectCategoryAndPerformSegue{
    self.levelCategory = [[self.selectedCategory.oid componentsSeparatedByString:@"/"] count] - 1;
    if([self countSubCategories]<=1){
        [self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_CATEGORY_KEY];
        if([typeSelected isEqualToString:otypeReport]){
            [self performSegueWithIdentifier:@"toStepReport" sender:self];
        }else{
            [self performSegueWithIdentifier:@"toStepPhoto" sender:self];
        }
        //[self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_ICON_CATEGORY_KEY];
    } else {
        [self performSegueWithIdentifier:@"toSelectCategory" sender:self];
        NSLog(@"(SHPExploreHomeViewController) Error on cell index 0!! Read comments in this code snippet.");
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
    NSLog(@"....... Step cat WIZARD_DICTIONARY_KEY %@", self.wizardDictionary);
    if ([[segue identifier] isEqualToString:@"toStepPhoto"]) {
        SHPWizardStep3Photo *vc = (SHPWizardStep3Photo *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toSelectCategory"]) {
        SHPWizardStep2Categories *vc = (SHPWizardStep2Categories *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.levelCategory = self.levelCategory;
        vc.selectedCategory = self.selectedCategory;
    }
    else if ([[segue identifier] isEqualToString:@"toStepReport"]) {
        SHPWizardStepStartReport *vc = (SHPWizardStepStartReport *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.typeSelected = otypeReport;
        vc.selectedCategory = self.selectedCategory;
    }
}


- (void)goToClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)goToBack {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

