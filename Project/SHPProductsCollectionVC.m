//
//  SHPProductsCollectionVC.m
//  Coricciati MG
//
//  Created by Dario De Pascalis on 08/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPProductsCollectionVC.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "SHPProduct.h"
#import "SHPImageUtil.h"
#import "SHPImageRequest.h"
#import "SHPCaching.h"
#import "SHPProductDetail.h"
#import "SHPIconDownloader.h"
#import "SHPConstants.h"
#import "SHPAppDelegate.h"

@interface SHPProductsCollectionVC ()

@end

@implementation SHPProductsCollectionVC

static NSString * const reuseIdentifier = @"CellProduct";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    
    self.loader = [[SHPProductDC alloc]init];
    self.loader.delegate = self;
    
    searchStartPage = 0;
    searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    NSLog(@"SHPProductsCollectionVC viewDidLoad!!!!!! %@", self.author);
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    //if(self.startLoading){
        [self resetData];
        [self loadProducts];
    //}
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
    //ATTENZIONE X IL MOMENTO NON CONSIDERO LA PAGINAZIONE!!!!!!
    NSLog(@"loadProduct!!!!!!%d: %@ %@ - %@ - %d", (int)listProducts.count, self.author, self.idProduct, self.loader.delegate, (int)searchPageSize);
    if(listProducts.count==0){
        if(self.idProduct != (id)[NSNull null] && self.idProduct && self.author){
            [self.loader productsCreatedBy:self.author page:searchStartPage pageSize:searchPageSize withUser:self.applicationContext.loggedUser];
        }
        else {
            CLLocation *location;
            if(self.applicationContext.searchLocation) {
                location = self.applicationContext.searchLocation;
            } else {
                location = self.applicationContext.lastLocation;
            }
            [self.loader timelineForUser:self.author location:location page:searchStartPage pageSize:searchPageSize];
        }
    }
}

//DELEGATE loaded
- (void)loaded:(NSArray *)products {
    NSLog(@"LOADED...%@",products);
    isLoadingData = NO;
    //[self.refreshControl endRefreshing];
    if(products.count>0) {
        //al padre faccio ricaricare la vista passando un valore x visualizzare la cella altri oggetti
        
        if(!listProducts) {
            listProducts = [[NSMutableArray alloc] init];
        }
        [listProducts addObjectsFromArray:products];
        if(self.idProduct){
            SHPProduct *item = [[SHPProduct alloc] init];
            for (int i=0; i<(int)products.count; i++) {
                item = products[i];
                if([item.oid isEqualToString:self.idProduct]){
                    [listProducts removeObjectAtIndex:i];
                    break;
                }
            }
            if(listProducts.count>0){
                SHPProductDetail *vc = (SHPProductDetail *) self.parentViewController;
                vc.hideOtherProducts = NO;
                [vc.tableView reloadData];
            }
        }
        
        if(products.count < searchPageSize) {
            noMoreData = YES;
        }
        [self.collectionView reloadData];
    }
    else if(products.count == 0 && listProducts.count == 0) {
        if(!listProducts) {
            listProducts = [[NSMutableArray alloc] init];
        }
        [self.collectionView reloadData];
    }
    else if(products.count == 0) {
        noMoreData = YES;
    }
    [self.collectionView reloadData];
}

-(void)networkError {
    isLoadingData = NO;
    //[self.refreshControl endRefreshing];
    [self.collectionView reloadData];
}
//---------------------------------------------------------------//
//------------ END LOAD PRODUCT
//---------------------------------------------------------------//

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //#warning Incomplete method implementation -- Return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //#warning Incomplete method implementation -- Return the number of items in the section
    if (listProducts && listProducts.count > 0) {
        return listProducts.count;
    } else {
        return 10; // fake boxes
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath: %@ - %d", indexPath, (int)listProducts.count);
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
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
        UILabel *titleProduct = (UILabel *)[cell viewWithTag:11];
       
        titleProduct.text = stringTitleProduct;
        
        
        //----------------------------------------------------------------//
        //controllo se esiste un url image valido prima di caricare l'immagine
//        productLoaded.imageURL =  [productLoaded.imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        NSArray *explodeUrl = [productLoaded.imageURL componentsSeparatedByString:@"?url="];
//        if(explodeUrl.count<1 || [explodeUrl[1] isEqualToString:@""]){
//            productLoaded.imageURL = NULL;
//        }
        //----------------------------------------------------------------//
       
        NSLog(@"\nCELL2 - productLoaded: %@", productLoaded.imageURL);
        
        productLoaded.imageHeight = iconView.frame.size.width;
        productLoaded.imageWidth = iconView.frame.size.height;
        if(![self.applicationContext.smallImagesCache getImage:productLoaded.imageURL]) {
            //mainListImageCache
            BOOL scrollPaused = self.collectionView.dragging == NO && self.collectionView.decelerating == NO;
            if ( scrollPaused ) {
                [self startIconDownload:productLoaded forIndexPath:indexPath];
            }
            iconView.image = nil;
        } else {
            iconView.image = [self.applicationContext.smallImagesCache getImage:productLoaded.imageURL];
        }
        
        [SHPImageUtil arroundImage:8 borderWidth:1  layer:iconView.layer];
    } else {
        cellId = @"idCellProductFake";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 8;
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
    }
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"END DRAGGING");
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"END DECELERATING");
    [self loadImagesForOnscreenRows];
}

-(void)loadImagesForOnscreenRows {
    if (listProducts.count <= 0) {
        return;
    }
    NSArray *indexes = [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *index in indexes) {
        if (index.row <= listProducts.count - 1) { // != last cell
            UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index];
            UIView *contentView = cell.contentView; //[cell.contentView viewWithTag:backViewTag];
            UIImageView *imageView = (UIImageView *)[contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
            if (!imageView.image) {
                SHPProduct *product = [listProducts objectAtIndex:index.row];
                [self startIconDownload:product forIndexPath:index];
            }
        }
    }
}


- (void)startIconDownload:(SHPProduct *)product forIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"productLoaded: %@", productLoaded.imageURL);
//    int w = iconView.frame.size.width*2;//160;
//    int h = iconView.frame.size.height*2;//160;
//    NSString *url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", productLoaded.imageURL, (int)w, (int)h];
//    NSString *cacheUrl = [url stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
//    UIImage *cacheImage = [self.applicationContext.categoryIconsCache getImage:cacheUrl];
//    NSLog(@"archiveIcon %@ - %@", cacheImage, self.applicationContext);
//    if (cacheImage) {
//        NSLog(@"cacheImage %@", iconView.image);
//        iconView.image = cacheImage;
//    }
//    else {
//        NSLog(@"imageRquest %@", iconView.image);
//        iconView.image = nil;
//        SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
//        [imageRquest downloadImage:url
//                 completionHandler:
//         ^(UIImage *image, NSString *imageURL, NSError *error) {
//             if (image) {
//                 NSLog(@"SAVE IMAGE %@", imageURL);
//                 NSString *cacheUrl = [imageURL stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
//                 [SHPCaching saveImage:image inFile:cacheUrl];
//                 [self.applicationContext.categoryIconsCache addImage:image withKey:cacheUrl];
//                 iconView.image = image;
//             }
//         }];
//    }
    
    //NSLog(@"started startIconDownload for indexPath: %d [%@]", indexPath.row, product.longDescription);
    SHPIconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        //NSString *url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", productLoaded.imageURL, (int)w, (int)h];
        NSLog(@"Starting IconDownloader for product %@", product.imageURL);
        iconDownloader = [[SHPIconDownloader alloc] init];
        iconDownloader.imageURL = product.imageURL;
        iconDownloader.imageWidth = product.imageWidth;//(int)self.applicationContext.settings.mainListImageWidth;
        iconDownloader.imageHeight = product.imageHeight;//(int)self.applicationContext.settings.mainListImageHeight;
        iconDownloader.imageCache = self.applicationContext.smallImagesCache;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        
        iconDownloader.imageURL = [self checkUrlImage:iconDownloader.imageURL];
        NSLog(@"CELL1 - productLoaded: %@", iconDownloader.imageURL);
        if(iconDownloader.imageURL)[iconDownloader startDownload];
    }
}


// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    SHPIconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    NSArray *indexes = [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *index in indexes) {
        if (index.row == indexPath.row) {
            UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index];
            UIView *contentView = cell.contentView;
            
            UIImageView *imageView = (UIImageView *)[contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
            UIImage *image = [self.applicationContext.smallImagesCache getImage:iconDownloader.imageURL];
            
            // animate fade image set
            [UIView transitionWithView:imageView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{imageView.image = image;}
                            completion:NULL];
        }
    }
    [imageDownloadsInProgress removeObjectForKey:indexPath];
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"touched cell %@ at indexPath %@", collectionView, indexPath);
    if(listProducts.count > 0 && (indexPath.row < listProducts.count)) {
        productSelected = [[SHPProduct alloc] init];
        productSelected = (SHPProduct*)listProducts[indexPath.row];
       //[self performSegueWithIdentifier:@"unwindToProductDetail" sender:self];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SHPProductDetail *VC  = [[SHPProductDetail alloc] init];
        VC  = [sb instantiateViewControllerWithIdentifier:@"ProductDetailStoryboardID"];
        VC.applicationContext = self.applicationContext;
        VC.product = productSelected;
         NSLog(@"productSelected :: %@",productSelected.categoryType);
        [self.navigationController pushViewController:VC animated:YES];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        if ([[segue identifier] isEqualToString:@"unwindToProductDetail"]) {
            SHPProductDetail *vc = segue.destinationViewController;
            vc.applicationContext = self.applicationContext;
            vc.product = productSelected;
            NSLog(@"productSelected :: %@",productSelected.categoryType);
            //immagine troppo piccola
            //UIImage *image = [self.applicationContext.mainListImageCache getImage:productSelected.imageURL];
            //vc.productImage = [[UIImageView alloc] initWithImage:image];
        }
}


- (void)dealloc {
    NSLog(@"****************** DEALLOC");
    [self.loader setDelegate:nil];
}


-(NSString *)checkUrlImage:(NSString *)imageURL{
    //----------------------------------------------------------------//
    //controllo se esiste un url image valido prima di caricare l'immagine
    NSLog(@"checkUrlImage %@:",imageURL);
    imageURL =  [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *explodeUrl = [imageURL componentsSeparatedByString:@"?url="];
    if(explodeUrl.count<1 || [explodeUrl[1] isEqualToString:@""]){
        imageURL = nil;
    }
    return imageURL;
}
@end
