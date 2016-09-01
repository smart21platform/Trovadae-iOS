//
//  SHPProfileListProducts.m
//  Italiacamp
//
//  Created by dario de pascalis on 22/04/15.
//
//

#import "SHPProfileListProducts.h"
#import "SHPLikedProductsLoader.h"
#import "SHPCreatedProductsLoader.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "SHPProduct.h"
#import "SHPCaching.h"
#import "SHPImageRequest.h"
#import "SHPImageUtil.h"
#import "SHPProductsTableList.h"
#import "SHPProductDetail.h"


@interface SHPProfileListProducts ()
@end

@implementation SHPProfileListProducts

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.titleView;
    self.loader = [[SHPProductDC alloc]init];
    self.loader.delegate = self;
    searchStartPage = 0;
    searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    if(self.listAllProducts.count>0){
        listProducts = self.listAllProducts;
        //[self.tableView reloadData];
    }else{
        [self initialize];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillDisappear");
}

-(void)initialize
{
    [self resetData];
    if([self.listMode isEqualToString:@"CREATED"]){
        [self setupCreatedList];
    }
    else{
        [self setupLikedList];
    }
}

-(void)resetData {
    NSLog(@"RESETTING DATA");
    listProducts = nil;
    searchStartPage = 0;
    isLoadingData = YES;
    noMoreData = NO;
}

-(void)setupCreatedList {
    [self.loader productsCreatedBy:self.user page:searchStartPage pageSize:searchPageSize withUser:self.applicationContext.loggedUser];
}

-(void)setupLikedList {
   [self.loader productsLikedTo:self.user page:searchStartPage pageSize:searchPageSize withUser:self.applicationContext.loggedUser];
}


//----------------------------------------------------------------//
//START DELEGATE self.loader
//----------------------------------------------------------------//
- (void)loaded:(NSArray *)products {
    NSLog(@"LOADED...%@",products);
    [self.refreshControl endRefreshing];
    isLoadingData = NO;
    if(products.count>0) {
        if(!listProducts) {
            listProducts = [[NSMutableArray alloc] init];
        }
        [listProducts addObjectsFromArray:products];
        if(products.count < searchPageSize) {
            noMoreData = YES;
        }
        [self.tableView reloadData];
    }
    else if(products.count == 0 && listProducts.count == 0) {
        if(!listProducts) {
            listProducts = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];
    }
    else if(products.count == 0) {
        noMoreData = YES;
    }
    [self.tableView reloadData];
}

-(void)networkError {
    isLoadingData = NO;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

//----------------------------------------------------------------//
//END DELEGATE self.loader
//----------------------------------------------------------------//




-(void)moreButtonPressed:(id)sender
{
    NSLog(@"More Button pressed");
    searchStartPage = searchStartPage + 1;
    if([self.listMode isEqualToString:@"CREATED"]){
        [self setupCreatedList];
    }
    else{
        [self setupLikedList];
    }
}

//----------------------------------------------------------------//
//START BUILD TABLEVIEW
//----------------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(listProducts && listProducts.count > 0) {
        return [listProducts count] + 1;
    } else if (listProducts && listProducts.count == 0) {
        return 1; // the NoProductsCell
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(listProducts){
        return 50;
    }
    return self.view.frame.size.height-50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *cellId;
    
    if(listProducts && listProducts.count > 0 && (indexPath.row <= listProducts.count - 1) ) {
        cellId = @"idCellPost";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        SHPProduct *productLoaded = [listProducts objectAtIndex:indexPath.row];
        NSString *stringTitleProduct = productLoaded.longDescription;
        if(productLoaded.title && ![productLoaded.title isEqualToString:@" "]){
            stringTitleProduct = productLoaded.title;
        }else{
            stringTitleProduct = productLoaded.longDescription;
        }
        
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:11];
        UILabel *titleProduct = (UILabel *)[cell viewWithTag:12];
        titleProduct.text = stringTitleProduct;
        
        NSLog(@"productLoaded: %@", productLoaded.imageURL);
        int w = 80;
        int h = 80;
        NSString *url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", productLoaded.imageURL, (int)w, (int)h];
        UIImage *cacheImage = [self.applicationContext.categoryIconsCache getImage:url];
        UIImage *archiveIcon = [SHPCaching restoreImage:url];
        
        if (cacheImage) {
            NSLog(@"cacheImage");
            iconView.image = cacheImage;
        }
        else if (archiveIcon) {
            NSLog(@"archiveIcon");
            iconView.image = archiveIcon;
        }
        else {
            NSLog(@"imageRquest");
            iconView.image = nil;
            SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
            [imageRquest downloadImage:url
                     completionHandler:
             ^(UIImage *image, NSString *imageURL, NSError *error) {
                 if (image) {
                     NSLog(@"SAVE IMAGE %@", imageURL);
                     [SHPCaching saveImage:image inFile:imageURL];
                     [self.applicationContext.categoryIconsCache addImage:image withKey:imageURL];
                     iconView.image = image;
                 }
             }];
        }
        [SHPImageUtil customIcon:iconView];
    }
    else if(listProducts && listProducts.count > 0 && (indexPath.row == listProducts.count)) {
        cellId = @"idLastCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        UILabel *noItemsLabel = (UILabel *)[cell viewWithTag:1];
        noItemsLabel.text = NSLocalizedString(@"NoItemsLKey", nil);
    }
    else if(!listProducts){
        cellId = @"idLoadingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        UILabel *labelLoading = (UILabel *)[cell viewWithTag:10];
        labelLoading.text = NSLocalizedString(@"LoadingLKey", nil);
        UIActivityIndicatorView *actionIndicatorLoading = (UIActivityIndicatorView *)[cell viewWithTag:11];
        [actionIndicatorLoading startAnimating];
    }
    else {
        cellId = @"idNoItemsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        UILabel *labelNoItems = (UILabel *)[cell viewWithTag:10];
        labelNoItems.text = NSLocalizedString(@"NoItemsLKey", nil);
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"DID SELECT ROW AT INDEX PATH!!!!!");
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(listProducts.count > 0 && (indexPath.row < listProducts.count)) {
        SHPProduct *product = [[SHPProduct alloc] init];
        product = listProducts[indexPath.row];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SHPProductDetail *VC  = [[SHPProductDetail alloc] init];
        VC  = [sb instantiateViewControllerWithIdentifier:@"ProductDetailStoryboardID"];
        //VC.navigationItem.hidesBackButton = YES;
        VC.applicationContext = self.applicationContext;
        VC.product = product;
        [self.navigationController pushViewController:VC animated:NO];     
    }
}
//----------------------------------------------------------------//
//END BUILD TABLEVIEW
//----------------------------------------------------------------//


-(void)dealloc {
    NSLog(@"DEALLOCATING");
    [self.loader setDelegate:nil];
}

@end
