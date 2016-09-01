//
//  SHPProductsTableList.m
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import "SHPProductsTableList.h"
#import "SHPImageCache.h"
#import "SHPProductDC.h"
#import "SHPGridCell.h"
#import "SHPConstants.h"
#import "SHPComponents.h"
#import "UIView+Property.h"
#import "SHPProduct.h"
#import "SHPImageUtil.h"
//#import "SHPUserProfileViewController.h"

@implementation SHPProductsTableList

@synthesize applicationContext;
//@synthesize user;
@synthesize bgColor;
@synthesize masterView;
@synthesize loader;

@synthesize tableView;
@synthesize tableViewDelegate;

@synthesize selectedIndex;
@synthesize imageCache;
@synthesize columnsNumber;
@synthesize totalRows;
//@synthesize productDC;
@synthesize products;
@synthesize searchStartPage;
@synthesize searchPageSize;
@synthesize imageDownloadsInProgress;
@synthesize isLoadingData;
@synthesize currentlyShown;
@synthesize isNetworkError;
@synthesize noMoreData;

static NSInteger SHPCONST_SHOPDETAIL_CELL_TOP_PAD = 5;
static NSInteger SHPCONST_SHOPDETAIL_CELL_BOTTOM_PAD = 2;
static NSInteger SHPCONST_SHOPDETAIL_CELL_HEIGHT = 155;

- (void)initialize {
    NSLog(@"INITIALIZING TABLE LIST! Prod table list");
    self.products = nil;
    self.totalRows = 0;
    
    self.columnsNumber = 2;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    self.searchStartPage = 0;
    self.noMoreData = FALSE;
    self.isNetworkError = NO;
    
    self.loader.searchStartPage = self.searchStartPage;
    self.loader.productDC.delegate = self;
}

-(void)removeProduct:(NSString *)oid {
    for (int i = 0; i < self.products.count; i++) {
        SHPProduct *p = (SHPProduct *)[self.products objectAtIndex:i];
        if ([p.oid isEqualToString:oid]) {
            [self.products removeObject:p];
        }
    }
}

-(void)searchProducts {
    self.isLoadingData = YES;
    if (self.applicationContext.searchLocation) {
        self.loader.searchLocation = self.applicationContext.searchLocation;
    } else {
        self.loader.searchLocation = self.applicationContext.lastLocation;
    }
    self.loader.authUser = self.applicationContext.loggedUser;
    [self.loader loadProducts];
}

- (NSInteger)numberOfRows {
    if(self.products && self.products.count > 0) {
        // ceil(A/B) = (A+B-1)/B ex: int rows = (6+2-1)/2 = ceil(6/2)
        NSInteger num = self.totalRows;
        num = num + 1; // add "more button" cell
        return num;
    }
    else {
        return 1; // loading cell || no products cell
    }
    //    else if (self.isLoadingData && !self.products) {
    //        return 1; // initial loading
    //    } else {
    //        return 1;
    //    }
}

- (CGFloat)heightForRow:(NSInteger)row {
    NSInteger rowHeight;
    if (row <= self.totalRows - 1) { // it's a row of the grid
        rowHeight = SHPCONST_SHOPDETAIL_CELL_TOP_PAD + SHPCONST_SHOPDETAIL_CELL_BOTTOM_PAD + SHPCONST_SHOPDETAIL_CELL_HEIGHT; //vInsets + viewHeight
    } else { // it's a row outside the grid
        rowHeight = 44; //last cell (loading next page)
    }
    return rowHeight;
}

- (UITableViewCell *)cellForRow:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [self gridCellForIndexPath:indexPath];
    return cell;
}

-(UITableViewCell *)gridCellForIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"rendering cell. isNetworkError %d", self.isNetworkError);
    UITableViewCell *cell;
    if (self.products == 0 && self.isLoadingData) { // initial load cell
        NSLog(@"INITIAL CELL ACTIVITY LOADING");
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
        NSLog(@"TABLE VIEW %@, ACTIVITY CELL %@", self.tableView, cell);
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *) [cell viewWithTag:20];
        [activityView startAnimating];
        return cell;
    }
//    else if (self.isNetworkError) {
//        NSLog(@"INITIAL CELL ACTIVITY LOADING");
//        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NetworkErrorCell"];
//        // TODO Translate "Network Error" name
//        UILabel *label = (UILabel *) [cell viewWithTag:20];
//        label.text = NSLocalizedString(@"NetworkErrorLKey", nil);
//        return cell;
//    }
    else if (self.isNetworkError || self.products.count == 0) {
        NSLog(@"NO PRODUCTS CELL!!!! in table %@", self.tableView);
//        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
//        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *) [cell viewWithTag:20];
//        [activityView stopAnimating];
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoItemsCell2"];
        UILabel *label = (UILabel *)[cell viewWithTag:10];
        label.text = NSLocalizedString(@"NoItemsLKey", nil);
        return cell;
    }
    else if (self.products && self.products.count > 0 && indexPath.row <= self.totalRows - 1) {
//        NSLog(@"==> products.count %d", self.products.count);
//        NSLog(@"==> indexPath section/row %d/%d, totalRows %d", indexPath.section, indexPath.row, self.totalRows);
        cell = (SHPGridCell *)[self.tableView dequeueReusableCellWithIdentifier:SHPCONST_GRID_CELL_ID];
        if (!cell) {
            NSMutableArray *views = [[NSMutableArray alloc] init];
            UIView *view1 = [SHPComponents gridProductView:applicationContext.settings withTarget:self];
            view1.tag = 31;
            UIView *view2 = [SHPComponents gridProductView:applicationContext.settings withTarget:self];
            view2.tag = 32;
            [views addObject:view1];
            [views addObject:view2];
            UIEdgeInsets insets = UIEdgeInsetsMake(SHPCONST_SHOPDETAIL_CELL_TOP_PAD, 0, SHPCONST_SHOPDETAIL_CELL_BOTTOM_PAD, 0); // only top & bottom are used -> Use in heightForCell
            cell = [[SHPGridCell alloc] initWithViews:views insets:insets reuseIdentifier:SHPCONST_GRID_CELL_ID cellWidth:self.tableView.frame.size.width];
        }
        ////
        
        UIView *tableCellView1 = (UIView *)[cell viewWithTag:31];
        tableCellView1.backgroundColor = self.bgColor;
        UIImageView *imageView1 = (UIImageView *)[tableCellView1 viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
        
        UIView *tableCellView2 = (UIView *)[cell viewWithTag:32];
        tableCellView2.backgroundColor = self.bgColor;
        UIImageView *imageView2 = (UIImageView *)[tableCellView2 viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
        
        imageView1.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [imageView1 addGestureRecognizer:tap];
        
        imageView2.userInteractionEnabled = TRUE;
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [imageView2 addGestureRecognizer:tap];
        
        cell.contentView.backgroundColor = self.bgColor;
        SHPGridCell *gridCell = (SHPGridCell *)cell;
        NSArray *columnViews = gridCell.columnViews;
        int productStartIndexInRow = (int)(indexPath.row * self.columnsNumber);
        int columnIndex = 0;
        for (UIView *columnView in columnViews) {
            NSInteger productIndex = productStartIndexInRow + columnIndex;
            if (productIndex <= [self.products count] - 1) {
                columnView.hidden = NO;
                columnView.backgroundColor = self.bgColor;
                UIImageView *iv = (UIImageView *)[columnView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
                iv.backgroundColor = [UIColor clearColor];
                iv.property = [NSNumber numberWithInteger:productIndex];
                SHPProduct *product = [self.products objectAtIndex:productIndex];
                
                UILabel *descriptionLabel = (UILabel *) [columnView viewWithTag:2];
                descriptionLabel.text = product.longDescription;
                
                UILabel *distanceLabel = (UILabel *) [columnView viewWithTag:10];
                distanceLabel.text = product.distance;
                
                UILabel *priceLabel = (UILabel *) [columnView viewWithTag:12];
                priceLabel.text = product.price;
                
                UILabel *currencyLabel = (UILabel *) [columnView viewWithTag:14];
                if (![product.price isEqualToString:@""]) {
                    currencyLabel.hidden = NO;
                    currencyLabel.text = NSLocalizedString(@"euro", nil); // product.currency is not indexed in solr? TODO
                } else {
                    currencyLabel.hidden = YES;
                }
                
                // Only load cached images; defer new downloads until scrolling ends
                NSString *imageURL = [self productImageURL:product];
                if(![self.imageCache getImage:imageURL]) {
                    [self startIconDownload:product forIndexPath:indexPath forColumnIndex:columnIndex];
                    // if a download is deferred or in progress, return a placeholder image
                    iv.image = [UIImage imageNamed:@"grid-big-empty-image.png"];
                    //                    iv.image = nil;
                } else {
                    iv.image = [self.imageCache getImage:imageURL];
                }
            } else {
                columnView.hidden = YES;
            }
            columnIndex++;
        }
    } else if (indexPath.row == self.totalRows) { // last cell
//        NSLog(@"RENDERING LAST CELL!");
        // last cell is "load new data"
//        cell = [self.tableView dequeueReusableCellWithIdentifier:SHPCONST_MAIN_LIST_PRODUCT_LAST_CELL_ID];
//        if(cell == nil) {
        NSLog(@"CREATING LAST CELL");
        cell = [SHPComponents MainListMoreResultsCell:self.bgColor withTarget:self settings:self.applicationContext.settings];
//        } else {
//            NSLog(@"REUSING LAST CELL");
//        }
//        NSLog(@"LAST CELL: %@", cell);
//        NSLog(@"LAST CELL CLASS: %@", [cell class]);
        [self updateMoreButtonCell:cell];
//        UIButton *button = (UIButton *)[cell viewWithTag:10];
//        NSLog(@"LAST CELL BUTTON IS %@", button);
        //        } else {
        //            [self updateMoreButtonCell:cell];
        //        }
    }
    return cell;
}

// DC delegate

- (void)loaded:(NSArray *)_products {
    self.isLoadingData = NO;
    UITableViewCell *moreCell = [self moreButtonCell];
    [self updateMoreButtonCell:moreCell];
    if (!self.products) {
        self.products = [[NSMutableArray alloc] init];
    }
    [self.products addObjectsFromArray:_products];
    self.totalRows = (self.products.count + self.columnsNumber - 1) / self.columnsNumber;
    if (_products.count == 0 || _products.count < self.loader.searchPageSize) {
        self.noMoreData = TRUE;
    }
    [self reloadTable];
}


-(void)networkError {
    NSLog(@"NETWORK ERROR.....!");
    self.isLoadingData = NO;
    self.isNetworkError = YES;
    if ([self.tableViewDelegate respondsToSelector:@selector(networkError)]) {
        [self.tableViewDelegate performSelector:@selector(networkError)];
    } else {
        NSLog(@"NO networkError Selector is impemented for the tableViewDelegate!");
    }
    [self reloadTable];
}

-(void)reloadTable {
    if ([self.tableViewDelegate respondsToSelector:@selector(reloadTable)]) {
		[self.tableViewDelegate performSelector:@selector(reloadTable) withObject:self];
	} else {
        NSLog(@"no reload table selector");
    }
}

// END DC DELEGATE

// IMAGE HANDLING

-(void)terminatePendingImageConnections {
    NSLog(@"''''''''''''''''''''''   Terminate all pending IMAGE connections...");
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    NSLog(@"total downloads: %d", (int)allDownloads.count);
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
    }
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (void)startIconDownload:(SHPProduct *)product forIndexPath:(NSIndexPath *)indexPath forColumnIndex:(NSInteger)columnIndex
{
    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:product.imageURL];
    //    NSLog(@"IconDownloader..%@", iconDownloader);
    if (iconDownloader == nil)
    {
        iconDownloader = [[SHPImageDownloader alloc] init];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:[NSNumber numberWithInteger:columnIndex] forKey:@"columnIndex"];
        [options setObject:indexPath forKey:@"indexPath"];
        iconDownloader.options = options;
        
        NSString *imageURL = [self productImageURL:product];
        
        iconDownloader.imageURL = imageURL;
//        iconDownloader.imageWidth = SHPCONST_SHOP_DETAIL_gridImageWidth;
//        iconDownloader.imageHeight = 500;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageURL];
//        NSLog(@"DOWNLOADS IN PROGRESS: %d", self.imageDownloadsInProgress.count);
        [iconDownloader startDownload];
    }
    //    NSLog(@"End StartIconDownloader...");
}

-(NSString *)productImageURL:(SHPProduct *)product {
    NSInteger _w = SHPCONST_SHOP_DETAIL_gridImageWidth;
    NSInteger _h = 500;
//    if ([UIScreen mainScreen].scale == 2.0) {
//        _w = _w * 2;
//        _h = _h * 2;
//    }
    NSString *_url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", product.imageURL, _w, _h];
    return _url;
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader
{
    //    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageURL];
    BOOL blending = NO; // from settings
    // blending momentaneously disabled because image aspect doesn't work
    if (blending) {
        UIImage *thumbTrasparencyImage = [SHPImageUtil previewThumbOnImage:[UIImage imageNamed:@"grid-big-empty-image.png"] image:image];
        image = nil;
        image = thumbTrasparencyImage;
    }
    [self.imageCache addImage:image withKey:imageURL];
    NSDictionary *options = downloader.options;
    NSIndexPath *indexPath = [options objectForKey:@"indexPath"];
    NSInteger columnIndex = [((NSNumber *)[options valueForKey:@"columnIndex"]) integerValue];
    // if the cell for the image is visible updates the cell
    // but only if this subtable is visible
    if (self.currentlyShown) {
        NSArray *indexes = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *index in indexes) {
            if (index.row == indexPath.row && index.section == indexPath.section) {
                SHPGridCell *cell = (SHPGridCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
                // the asynch image upload can interact with a new list that has
                // in the expected position the "loading" cell or another cell
                // different by a column-grid-cell
                if ([cell respondsToSelector:@selector(viewAtColumn:)]) {
                    UIView *columnView = [cell viewAtColumn:columnIndex];
                    UIImageView *iv = (UIImageView *)[columnView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
                    iv.image = image;
                }
            }
        }
    }
    [self.imageDownloadsInProgress removeObjectForKey:imageURL];
}

-(void)moreButtonPressed:(id)sender
{
    NSLog(@"More Button pressed");
    self.searchStartPage = self.searchStartPage + 1;
    self.loader.searchStartPage = self.searchStartPage;
    [self searchProducts];
    UITableViewCell *moreCell = [self moreButtonCell];
    if (moreCell) {
        [self updateMoreButtonCell:moreCell];
    }
}

// if visible, returns the cell of the moreButton (the last cell)
-(UITableViewCell *)moreButtonCell {
    if (!self.products) {
        return nil;
    }
    // we can also test this: if last cell.identifier == LastCellIdent...
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == self.totalRows) {
            UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
            return cell;
        }
    }
    return nil;
}

-(void)updateMoreButtonCell:(UITableViewCell *)cell {
    NSLog(@"???? updateMoreButtonCell networkerror %d", self.isNetworkError);
    if (!cell) {
        return;
    }
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:20];
    if (self.isLoadingData && !self.isNetworkError) {
        button.hidden = YES;
        spinner.hidden = NO;
        [spinner startAnimating];
    }
//    else if (self.isNetworkError) {
//        button.hidden = NO;
//        spinner.hidden = YES;
//        [spinner stopAnimating];
//        if (self.noMoreData) {
//            [button setTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//            button.enabled = NO;
//        }
////        else {
////            [button setTitle:NSLocalizedString(@"MoreResultsLKey", nil) forState:UIControlStateNormal];
////            [button setTitleColor:self.applicationContext.settings.moreResultsButtonColor forState:UIControlStateNormal];
////            button.enabled = YES;
////        }
//    }
    else if (!self.isNetworkError) {
        button.hidden = NO;
        spinner.hidden = YES;
        [spinner stopAnimating];
        if (self.noMoreData) {
            [button setTitle:NSLocalizedString(@"NoMoreResultsLKey", nil) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            button.enabled = NO;
        } else {
            [button setTitle:NSLocalizedString(@"MoreResultsLKey", nil) forState:UIControlStateNormal];
            [button setTitleColor:self.applicationContext.settings.moreResultsButtonColor forState:UIControlStateNormal];
            button.enabled = YES;
        }
    } else if (self.isNetworkError) {
        button.hidden = YES;
        spinner.hidden = YES;
    }
//    NSLog(@"</updateMoreButtonCell");
}

- (void)tapImage:(UITapGestureRecognizer *)gesture {
    UIImageView* imageView = (UIImageView*)gesture.view;
    self.selectedIndex = [(NSNumber*)imageView.property integerValue];
    SHPProduct *selectedProduct = [self.products objectAtIndex:self.selectedIndex];
    self.tapHandler(selectedProduct, self.selectedIndex);
}


// END TABLEVIEW

-(void)disposeResources {
    NSLog(@"...........>>>>>> DISPOSING LIST PRODUCTS <<<<<<..........");
    self.loader.productDC.delegate = nil;
    [self.loader cancelOperation];
    [self terminatePendingImageConnections];
}

-(void)dealloc {
    NSLog(@"...........DEALLOCATING PRODUCTS LIST.......");
}

@end
