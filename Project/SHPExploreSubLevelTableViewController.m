//
//  SHPExploreSubLevelTableViewController.m
//  AnimaeCuore
//
//  Created by Dario De Pascalis on 12/06/14.
//
//

#import "SHPExploreSubLevelTableViewController.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPComponents.h"
#import "SHPCategory.h"
#import "SHPImageRequest.h"
#import "SHPProductsViewController2.h"
#import "SHPCategorySearchProductsLoader.h"
#import "SHPProductDC.h"
#import "SHPImageUtil.h"
#import "SHPCaching.h"

@interface SHPExploreSubLevelTableViewController ()

@end

@implementation SHPExploreSubLevelTableViewController

static UIColor *selectedCellBGColor;
static NSString *TYPE_APP_RESTAURANT = @"restaurant";
static NSString *LAST_LOADED_CATEGORIES = @"lastLoadedCategories";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"------------ %@ - %@", self.categories, self.selectedCategory);
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    
    selectedCellBGColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-2.png"]];
//    [self.tableView setBackgroundView:imageView];
//    [self.tableView.backgroundView.layer setZPosition:0];
    [self customizeTitle:nil];
    [self initInfoButton];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"SubCategoriesPage: %@", self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}
//-(void)customizeTitle {
//    UIImage *title_image;
//    NSString *categoryIconURL = [self.selectedCategory iconURL];
//    NSLog(@"....... %@", categoryIconURL);
//    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
//    //UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
//    UIImage *staticIcon = [self.selectedCategory getStaticIconFromDisk];
//    if (cacheIcon) {
//        title_image = cacheIcon;
//    }
//    else if (staticIcon) {
//        title_image = staticIcon;
//    }
//    UIImage *resized = [SHPImageUtil scaleImage:title_image toSize:CGSizeMake(30, 30)];
//    //UIImageView *titleLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:resized];
//    //    titleLogo.image = title_image;
//    //titleLogo.contentMode = UIViewContentModeScaleAspectFill;
//    self.navigationItem.titleView = titleLogo;
//    self.navigationItem.title = nil;
//}

-(void)customizeTitle:(NSString *)title {
    if(title == nil){
        NSLog(@"title1 %@", title);
        UIImage *logo = [UIImage imageNamed:@"title-logo"];
        UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
        self.navigationItem.titleView = titleLogo;
        self.navigationItem.title=nil;
    }else{
        NSLog(@"title2 %@", title);
        [SHPComponents titleLogoForViewController:self];
        self.navigationItem.title = title;
    }
}

-(void)initInfoButton {
    NSLog(@"INFO BUTTON %@", self.navigationItem.rightBarButtonItem);
    if (!self.navigationItem.rightBarButtonItem) {
        return;
    }
    UIBarButtonItem *barButton = [SHPComponents positionInfoButton:self];
    [self.navigationItem setRightBarButtonItem:barButton];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num;
    //NSLog(@"numberOfRowsInSection %d",self.categories.count);
    num = self.categories ? self.categories.count : 0;
    return num;// + 1; // + 1 is the searchBar
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"rendering index   %d self.categories %@", indexPath.row, self.categories[indexPath.row]);
    UITableViewCell *cell = nil;
    static NSString *shopCellId = @"CategoryCell";
    
        cell = [tableView dequeueReusableCellWithIdentifier:shopCellId];
        //        NSInteger catIndex = indexPath.row - 1;
        NSInteger catIndex = indexPath.row;
        SHPCategory *cat = [self.categories objectAtIndex:catIndex];
        UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
        //textLabel.text = [cat.label capitalizedString];
        textLabel.text = cat.label;
    
        NSString *categoryIconURL = [cat iconURL];
    
        NSLog(@"....... categoryIconURL %@", categoryIconURL);
        UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
        UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
    
        //UIImage *staticIcon = [cat getStaticIconFromDisk];
        if(indexPath.row==0){
            //categoryIconURL = [cat iconAll];
            categoryIconURL = [self.selectedCategory iconURL];
            UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
            textLabel.text = NSLocalizedString(@"SearchProductsAll", nil);
            cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
            archiveIcon = [SHPCaching restoreImage:categoryIconURL];
            NSLog(@"************** CELLA TUTTO **************: %@", categoryIconURL);
        }
    
        // selected color
        UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
        myBackView.backgroundColor = selectedCellBGColor;
        cell.selectedBackgroundView = myBackView;
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:20];
        //[self customIcon:iconView];
    
        if (cacheIcon) {
            iconView.image = cacheIcon;
        }
        else if (archiveIcon) {
            NSLog(@"archiveIcon");
            iconView.image = archiveIcon;
        }
//        else if (staticIcon) {
//            iconView.image = staticIcon;
//        }
        else {
            //iconView.image = nil;
            SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
            [imageRquest downloadImage:categoryIconURL
                     completionHandler:
             ^(UIImage *image, NSString *imageURL, NSError *error) {
                 if (image) {
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
                     UIImage *icon = [UIImage imageNamed:@"category_icon__default"];
                     iconView.image = icon;
                     //[self.applicationContext.categoryIconsCache addImage:icon withKey:imageURL];
                 }
             }];
        }
    return cell;
}


-(void)customIcon:(UIImageView *)iconImage{
    iconImage.layer.cornerRadius = iconImage.frame.size.height/2;
    iconImage.layer.masksToBounds = YES;
    iconImage.layer.borderWidth = 0.1;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     NSLog(@"°°°°°°°°° Explore!!!!%@",self.selectedCategory);
    NSInteger catIndex = indexPath.row;// - 1;
    self.selectedCategory = [self.categories objectAtIndex:catIndex];
     NSLog(@"°°°°°°°°° Explore!!!!%@",self.selectedCategory);
    if (catIndex >= 0 && catIndex < self.categories.count) {
        [self performSegueWithIdentifier:@"Explore" sender:self];
    } else {
        NSLog(@"(SHPExploreHomeViewController) Error on cell index 0!! Read comments in this code snippet.");
    }
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    NSLog(@"Segue.......");
    if ([[segue identifier] isEqualToString:@"Explore"]) {
        NSLog(@"------------------ ??????? °°°°°°°°° Explore!!!!%@",self.selectedCategory);
        SHPProductsViewController2 *productsViewController = [segue destinationViewController];
        productsViewController.selectedCategory = self.selectedCategory;
        productsViewController.applicationContext = self.applicationContext;
        // products loader
        SHPCategorySearchProductsLoader *loader = [[SHPCategorySearchProductsLoader alloc] init];
        
        loader.categoryId = [NSString stringWithFormat:@"%@", self.selectedCategory.oid];
        loader.authUser = self.applicationContext.loggedUser;
        loader.searchStartPage = 0;
        loader.searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
        if (self.applicationContext.searchLocation) {
            loader.searchLocation = self.applicationContext.searchLocation;
        } else {
            loader.searchLocation = self.applicationContext.lastLocation;
        }
        loader.productDC.delegate = productsViewController;
        productsViewController.loader = loader;
    }

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
