//
//  SHPPoiCollectionVC.m
//  Italiacamp
//
//  Created by dario de pascalis on 05/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import "SHPPoiCollectionVC.h"
#import "SHPShop.h"
#import "SHPProduct.h"
#import "SHPApplicationContext.h"
#import "SHPPoiDetailTVC.h"
#import "SHPCaching.h"
#import "SHPImageRequest.h"
#import "SHPImageUtil.h"
#import "SHPProductDetail.h"
#import "SHPAppDelegate.h"

@interface SHPPoiCollectionVC ()
@end

@implementation SHPPoiCollectionVC

static NSString * const reuseIdentifier = @"CellProduct";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    
    self.loader = [[SHPProductDC alloc]init];
    self.loader.delegate = self;
    
    searchStartPage = 0;
    searchPageSize = self.applicationContext.settings.mainListSearchPageSize;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    NSLog(@"SHPPoiCollectionVC viewDidLoad!!!!!!");
    [self initialize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    NSLog(@"SHPPoiCollectionVC initialize!!!!!!");
    [self resetData];
    [self loadProducts];
}

-(void)resetData {
    NSLog(@"RESETTING DATA");
    listProducts = nil;
    searchStartPage = 0;
    isLoadingData = YES;
    noMoreData = NO;
}

//---------------------------------------------------------------//
//-----------START LOAD PRODUCT
//---------------------------------------------------------------//
-(void)loadProducts {
    isLoadingData = YES;
    NSLog(@"loadProduct!!!!!! %@ - %@", self.loader.delegate, self.shop.oid);
    [self.loader searchByShop:self.shop.oid page:searchStartPage pageSize:searchPageSize withUser:self.applicationContext.loggedUser];
}

//DELEGATE loaded
- (void)loaded:(NSArray *)products {
    NSLog(@"LOADED...%@",products);
    //[self.refreshControl endRefreshing];
    isLoadingData = NO;
    if(products.count>0) {
        //al padre faccio ricaricare la vista passando un valore x visualizzare la cella altri oggetti
        if(!listProducts) {
            listProducts = [[NSMutableArray alloc] init];
        }
        [listProducts addObjectsFromArray:products];
        SHPPoiDetailTVC *vc = (SHPPoiDetailTVC *) self.parentViewController;
        vc.hideOtherProducts = NO;
        [vc.tableView reloadData];
        
        if(products.count < searchPageSize) {
            noMoreData = YES;
        }
        [self.collectionView reloadData];
    }
}

-(void)networkError {
    isLoadingData = NO;
    //[self.refreshControl endRefreshing];
    [self.collectionView reloadData];
}
//---------------------------------------------------------------//
//------------ END LOAD PRODUCT
//---------------------------------------------------------------//
                      

                      
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete method implementation -- Return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection: %d",(int)listProducts.count);
    return listProducts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@" collectionView indexPath: %@ - %d", indexPath, (int)listProducts.count);
    UICollectionViewCell *cell = nil;
    static NSString *cellId;
    if(listProducts && listProducts.count > 0 && (indexPath.row <= listProducts.count - 1) ) {
        cellId = @"idCellProduct";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        
        SHPProduct *productLoaded = [listProducts objectAtIndex:indexPath.row];
        NSString *stringTitleProduct;// = productLoaded.longDescription;
        if(productLoaded.title && ![productLoaded.title isEqualToString:@" "]){
            stringTitleProduct = productLoaded.title;
        }else{
            stringTitleProduct = productLoaded.longDescription;
        }
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
        //UIImageView *iconView = (UIImageView *)[cell viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
        UILabel *titleProduct = (UILabel *)[cell viewWithTag:11];
         NSLog(@"CELL: %@ - IMAGE: %@", cell, iconView);
        titleProduct.text = stringTitleProduct;
        //titleProduct.numberOfLines = 0;
        //[titleProduct sizeToFit];
        NSLog(@"productLoaded: %@", productLoaded.imageURL);
        int w = 160;
        int h = 160;
        NSString *url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", productLoaded.imageURL, (int)w, (int)h];
        UIImage *cacheImage = [self.applicationContext.categoryIconsCache getImage:url];
        NSLog(@"archiveIcon %@", iconView);
        if (cacheImage) {
            NSLog(@"cacheImage %@", iconView.image);
            iconView.image = cacheImage;
        }
        else {
            NSLog(@"imageRquest %@", iconView.image);
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
        [SHPImageUtil arroundImage:8 borderWidth:1  layer:iconView.layer];
        //cell.backgroundColor = [UIColor whiteColor];
    }
//    else if(listProducts && listProducts.count > 0 && (indexPath.row == listProducts.count)) {
//        cellId = @"idLastCell";
//        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        UILabel *noItemsLabel = (UILabel *)[cell viewWithTag:1];
//        noItemsLabel.text = NSLocalizedString(@"NoItemsLKey", nil);
//    }
//    else if(!listProducts){
//        cellId = @"idLoadingCell";
//        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        UILabel *labelLoading = (UILabel *)[cell viewWithTag:10];
//        labelLoading.text = NSLocalizedString(@"LoadingLKey", nil);
//        UIActivityIndicatorView *actionIndicatorLoading = (UIActivityIndicatorView *)[cell viewWithTag:11];
//        [actionIndicatorLoading startAnimating];
//    }
//    else {
//        cellId = @"idNoItemsCell";
//        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        UILabel *labelNoItems = (UILabel *)[cell viewWithTag:10];
//        labelNoItems.text = NSLocalizedString(@"NoItemsLKey", nil);
//    }
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"touched cell %@ at indexPath %@", cell, indexPath);
   // [self.collectionView deselectRowAtIndexPath:indexPath animated:YES];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    NSString * segueName = segue.identifier;
//    if ([[segue identifier] isEqualToString:@"idEmbedPoiCollectionVC"]) {
//        SHPPoiCollectionVC *embed = segue.destinationViewController;
//        embed.shop = self.shop;
//        embed.applicationContext = self.applicationContext;
//    }
}

- (void)dealloc {
    NSLog(@"****************** DEALLOC");
    [self.loader setDelegate:nil];
}

@end
