//
//  SHPSearchCategoriesNearPoiTVC.m
//  Coricciati MG
//
//  Created by Dario De Pascalis on 06/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPSearchCategoriesNearPoiTVC.h"
#import "SHPCategory.h"
#import "SHPCaching.h"
#import "SHPImageRequest.h"
#import "SHPProductsViewController2.h"
#import "SHPCategorySearchProductsLoader.h"
#import "SHPProductDC.h"
#import "SHPComponents.h"
#import "SHPConstants.h"

@interface SHPSearchCategoriesNearPoiTVC ()
@end

@implementation SHPSearchCategoriesNearPoiTVC

//static NSString *LAST_LOADED_CATEGORIES = @"lastLoadedCategories";

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"self.nearPoi : %@ - %f:%f", self.nearPoi.city, self.nearPoi.lat, self.nearPoi.lon);
    [SHPComponents titleLogoForViewController:self];
    self.navigationController.title = nil;
    
    self.tableView.estimatedRowHeight = 82;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

-(void)initialize{
    self.labelHeader.text = [[NSString alloc] initWithFormat:@"%@'%@' %@ %@",
                             NSLocalizedString(@"SearchAround", nil), self.nearPoi.name, NSLocalizedString(@"toKey", nil), self.nearPoi.city];
    //[self.labelHeader sizeToFit];
    selectedCategory = [[SHPCategory alloc] init];
    nearLocation = [[CLLocation alloc]initWithLatitude:self.nearPoi.lat longitude:self.nearPoi.lon];
    [self initializeCategories];
}


//----------------------------------------------------------//
//START FUNZIONI VIEW
//----------------------------------------------------------//
-(void)initializeCategories {
    categories = [[NSMutableArray alloc] init];
    NSString *oidParent;
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    NSLog(@"cachedCategories: %@", cachedCategories);
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            BOOL visibility = [cat getVisibility:CATEGORY_VISIBILITY_SEARCH];
            NSLog(@"visibility %@ - %d - %d", cat.name, (int)cat.visibility, visibility);
            if (![cat.oid isEqualToString:@"/"] && visibility == YES) { // if present do-not-add "all" category
            //if (![cat.oid isEqualToString:@"/"]) {
                NSLog(@"adding %@", cat.oid);
                if(![self controlCategory:cat.oid] ){
                    oidParent=cat.oid;
                    [categories addObject:cat];
                }
            }
        }
    }
    [self.tableView reloadData];
}

-(BOOL)controlCategory:(NSString *)oid {
    NSString *oidSearch = [NSString stringWithFormat:@"%@/",oid];
    if (categories && categories.count > 0) {
        for (SHPCategory *cat in categories) {
            if ([oidSearch hasPrefix:cat.oid]) {
                NSLog(@"ESISTE %@", cat.oid);
                return YES;
            }
        }
    }
    return NO;
}
//----------------------------------------------------------//
//END FUNZIONI VIEW
//----------------------------------------------------------//


//----------------------------------------------------------//
//START TABLEVIEW
//----------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(categories.count>0){
        return categories.count;
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;// UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *shopCellId = @"CategoryCell";
    cell = [tableView dequeueReusableCellWithIdentifier:shopCellId];
    NSInteger catIndex = indexPath.row;
    SHPCategory *cat = [categories objectAtIndex:catIndex];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
    textLabel.text = [cat localName];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:20];
        //[self customIcon:iconView];
    NSString *categoryIconURL = [cat iconURL];
    //REGOLE UPLOAD IMAGES CATEGORIES:
    // 1- carico image dalla cache se presente in cache
    // SALTO 2- carico image dal disco se salvata in memoria e aggiungo alla cache
    // 3- carico image, salvo su disco e aggiungo alla cache
    // 4- carico image di default
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
        //UIImage *staticIcon = [cat getStaticIconFromDisk];
    if (cacheIcon) {
        iconView.image = cacheIcon;
    }
    else {
        if (archiveIcon) {
            //NSLog(@"archiveIcon");
            iconView.image = archiveIcon;
        }
        NSLog(@"imageRquest %@", categoryIconURL);
        SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
        [imageRquest downloadImage:categoryIconURL
                 completionHandler:
         ^(UIImage *image, NSString *imageURL, NSError *error) {
             if (image) {
                 NSLog(@"Image LOADED");
                 [SHPCaching saveImage:image inFile:imageURL];
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
                 NSLog(@"Image not loaded!");
                 // put an image that indicates "no image"?
                 UIImage *icon = [UIImage imageNamed:@"category_icon__default"];
                 iconView.image = icon;
             }
         }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger catIndex = indexPath.row;
    if (catIndex >= 0 && catIndex < categories.count) {
        selectedCategory = [categories objectAtIndex:catIndex];
    }
    [self performSegueWithIdentifier:@"toExplore" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toExplore"]) {
        SHPProductsViewController2 *vc = [segue destinationViewController];
        vc.selectedCategory = selectedCategory;
        vc.applicationContext = self.applicationContext;
        // products loader
        SHPCategorySearchProductsLoader *loader = [[SHPCategorySearchProductsLoader alloc] init];
        loader.categoryId = selectedCategory.oid;
        loader.authUser = self.applicationContext.loggedUser;
        loader.searchStartPage = 0;
        loader.searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
        loader.searchLocation = nearLocation;
        loader.productDC.delegate = vc;
        vc.loader = loader;
        NSLog(@"self.applicationContext.searchLocation: %@", nearLocation);
    }
}
//----------------------------------------------------------//
//END TABLEVIEW
//----------------------------------------------------------//

@end
