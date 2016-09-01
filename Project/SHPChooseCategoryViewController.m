//
//  SHPChooseCategoryViewController.m
//  Shopper
//
//  Created by andrea sponziello on 09/08/12.
//
//

#import "SHPChooseCategoryViewController.h"
#import "SHPCategoryDC.h"
#import "SHPCategory.h"

#import "SHPServiceUtil.h"
#import "SHPApplicationContext.h"
#import "SHPImageRequest.h"
#import "SHPComponents.h"
#import "SHPCaching.h"

@interface SHPChooseCategoryViewController ()

@end

@implementation SHPChooseCategoryViewController

@synthesize categories;
@synthesize showCategoryAll;
@synthesize navigationBar;
@synthesize tableView;
//@synthesize categoryDC;
@synthesize modalCallerDelegate;
@synthesize applicationContext;

static UIColor *selectedCellBGColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    selectedCellBGColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    
//    self.categoryDC = [[SHPCategoryDC alloc] init];
//    self.categoryDC.delegate = self;
    
    // init table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.hidden = NO;
    
    // setup the pull-to-refresh view
//    [self.tableView addPullToRefreshWithActionHandler:^{
//        NSLog(@"Refresh after Pull-to-refresh");
//        [self initializeData];
//    }];
    
    CGRect navBarFrame = self.navigationBar.frame;
    NSLog(@"navBar y: %f", navBarFrame.origin.y);
//    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.navigationBar.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - self.navigationBar.frame.size.height);
    [self localizeLabels];
}

-(void)localizeLabels {
    self.cancelButton.title = NSLocalizedString(@"CancelLKey", nil);
//    self.navigationBar.topItem.title = NSLocalizedString(@"SelectCategoryTitleLKey", nil);
    [self customizeTitle:NSLocalizedString(@"SelectCategoryTitleLKey", nil)];
}

-(void)customizeTitle:(NSString *)title {
    self.navigationItem.title = title;
    self.navigationBar.topItem.title = title;
    UILabel *navTitleLabel = [SHPComponents appTitleLabel:title withSettings:self.applicationContext.settings];
    self.navigationBar.topItem.titleView = navTitleLabel;
}

-(void)viewWillAppear:(BOOL)animated {
    if (!self.categories) {
//        [self showActivityView];
        [self initializeData];
    }
    
//    else if (self.showCategoryAll) {
//        SHPCategory *categoryAll = [[SHPCategory alloc] init];
//        categoryAll.oid = @"/";
//        categoryAll.name = @"All";
//        [self.categories insertObject:categoryAll atIndex:0];
//    }
}

//- (void)viewDidUnload
//{
//    [self setCancelButton:nil];
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    self.categories = nil;
//    self.tableView = nil;
//    self.categoryDC = nil;
//    self.modalCallerDelegate = nil;
//    [self setNavigationBar:nil];
//    [self setSelectedCategory:nil];
//    [self setActivityController:nil];
//    [self setErrorController:nil];
//}

-(void)initializeData {
    self.categories = nil;
    self.selectedCategory = nil;
//    [self showActivityView];
//    [self.categoryDC getAll];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source




- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    NSLog(@"ROWS IN SECTION!!!");
    NSInteger num;
    num = self.categories ? [self.categories count] : 0;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *shopCellId = @"CategoryCell";
    cell = [_tableView dequeueReusableCellWithIdentifier:shopCellId];
    NSInteger catIndex = indexPath.row;
    SHPCategory *cat = [self.categories objectAtIndex:catIndex];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
    textLabel.text = [cat.name capitalizedString];
    
    // update selected category checkbox
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:21];
    if ([cat.oid isEqualToString:self.selectedCategory.oid]) {
        imageView.image = [UIImage imageNamed: @"check2.png"];
    }
    else {
        imageView.image = nil;
    }
    
    // selected color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = selectedCellBGColor;
    cell.selectedBackgroundView = myBackView;
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:20];
    // category icon
    NSString *categoryIconURL = [[NSString alloc] initWithFormat:@"%@/imagerepo/service/images/search?url=/default/category%@/icon.png", [SHPServiceUtil serviceHost], cat.oid];
    //NSString *categoryIconURL = [[NSString alloc] initWithFormat:@"%@/imagerepo/service/images/search?url=/default/category%@/icon.png", [SHPServiceUtil serviceHost], cat.oid];
     NSLog(@"***...... categoryIconURL %@", categoryIconURL);
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
    if (cacheIcon) {
        iconView.image = cacheIcon;
    }
    else if (archiveIcon) {
        NSLog(@"archiveIcon");
        iconView.image = archiveIcon;
    }
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
                 // NSLog(@"Image not loaded!");
                 // put an image that indicates "no image"
                 iconView.image = nil;
             }
         }];
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected s:%ld i:%ld", (long)indexPath.section, (long)indexPath.row);
    
    // resets the check on previous category
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        SHPCategory *cat = [self.categories objectAtIndex:index.row];
        if ([cat.oid isEqualToString:self.selectedCategory.oid]) {
            UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:21];
            NSLog(@"DESELECTING OLD CHECK %@", imageView);
            imageView.image = nil;
        }
    }
    
    // setting new check
    UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:21];
    imageView.image = [UIImage imageNamed: @"check2.png"];
    NSLog(@"SELECTING NEW CHECK %@", imageView);
    
    self.selectedCategory = [self.categories objectAtIndex:indexPath.row];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:self.selectedCategory forKey:@"category"];
    [options setObject:self.categories forKey:@"categories"];
    
//    if (self.showCategoryAll) {
//        [self.categories removeObjectAtIndex:0]; // removes categoryAll
//    }
    
    [self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo: options];
}


// CONNECTION DELEGATE


//-(void)categoriesLoaded:(NSMutableArray *)_categories {
////    NSLog(@"CATEGORIES LOADED!!!!!");
//    [self.tableView.pullToRefreshView stopAnimating];
//    [self hideActivityView];
//    self.categories = _categories;
//    if (self.showCategoryAll) {
//        NSLog(@"...........Show Category ALL...........");
//        SHPCategory *categoryAll = [[SHPCategory alloc] init];
//        categoryAll.oid = @"/";
//        categoryAll.name = NSLocalizedString(@"CategoryAllLKey", nil);
//        [self.categories insertObject:categoryAll atIndex:0];
//    } else {
//        NSLog(@"NOT Show Category ALL...........");
//    }
//    [self.tableView reloadData];
//}

//-(void)networkError {
//    // dismiss "Loading Activity" view
//    //    [activityController.view removeFromSuperview];
//    [self hideActivityView];
//    // show "Network error" view
//    [self showErrorView];
//}

- (IBAction)dismissAction:(id)sender {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    if(self.categories) {
//        if (self.showCategoryAll) {
//            [self.categories removeObjectAtIndex:0]; // removes categoryAll
//        }
        [options setObject:self.categories forKey:@"categories"];
    }
    [self.modalCallerDelegate setupViewController:self didCancelSetupWithInfo: options];
}

//-(void)showActivityView {
////    NSLog(@"frame y: %f", self.tableView.bounds.origin.y);
//    if (self.activityController == nil) {
//        self.activityController = [[SHPActivityViewController alloc] initWithFrame:self.tableView.frame];
//    }
//    [self.view addSubview:self.activityController.view];
//    [self.activityController startAnimating];
//}

//-(void)hideActivityView {
//    [self.activityController.view removeFromSuperview];
//    [self.activityController stopAnimating];
//}

//-(void)showErrorView {
//    if (!self.errorController) {
//        self.errorController = [[SHPNetworkErrorViewController alloc] initWithFrame:self.tableView.frame];
//        //        errorController.target = self;
//        [self.errorController setTargetAndSelector:self buttonSelector:@selector(retryDataButtonPressed)];
//        NSString *errorMessage = NSLocalizedString(@"ConnectionErrorLKey", nil);
//        self.errorController.message = errorMessage;
//    }
////    [self.view insertSubview:self.errorController.view aboveSubview:self.view];
//    [self.view addSubview:self.errorController.view];
//}

//-(void)hideErrorView {
//    [self.errorController.view removeFromSuperview];
//}

//-(void)retryDataButtonPressed {
//    NSLog(@"TRYING AGAIN...");
//    [self hideErrorView];
//    [self hideActivityView];
//    [self initializeData];
//}

@end
