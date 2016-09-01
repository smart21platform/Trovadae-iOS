//
//  SHPShopsTableList.m
//  Dressique
//
//  Created by andrea sponziello on 15/01/13.
//
//

#import "SHPShopsTableList.h"
#import "SHPImageCache.h"
#import "SHPShopDC.h"
#import "SHPGridCell.h"
#import "SHPConstants.h"
#import "SHPComponents.h"
#import "UIView+Property.h"
#import "SHPShop.h"
#import "SHPImageUtil.h"
//#import "SHPUserProfileViewController.h"

@implementation SHPShopsTableList


- (void)initialize {
    NSLog(@"INITIALIZING TABLE LIST! prod shop");
    self.shops = nil;
    self.columnsNumber = 2;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.searchStartPage = 0;
    self.noMoreData = FALSE;
    self.isNetworkError = NO;
    self.loader.searchStartPage = self.searchStartPage;
    self.loader.shopDC.shopsLoadedDelegate = self;
}

-(void)searchShops {
    self.isLoadingData = YES;
    [self.loader loadShops];
    //    [self.productDC productsLikedTo:self.user page:self.searchStartPage pageSize:self.searchPageSize];
}

- (NSInteger)numberOfRows {
    if(self.shops && self.shops.count > 0) {
        NSInteger num = self.shops.count;
        num = num + 1; // add "more button" cell
        return num;
    }
    else {
        return 1; // loading cell || no products cell
    }
}

- (CGFloat)heightForRow:(NSInteger)row {
    return 44;
}

- (UITableViewCell *)cellForRow:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [self gridCellForIndexPath:indexPath];
    return cell;
}

-(UITableViewCell *)gridCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (self.shops.count == 0 && self.isLoadingData) { // initial load cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *) [cell viewWithTag:20];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    else if (self.shops.count == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoItemsCell2"];
        UILabel *label = (UILabel *)[cell viewWithTag:10];
        label.text = NSLocalizedString(@"NoShopFoundLKey", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    else if (self.shops && self.shops.count > 0 && indexPath.row <= self.shops.count - 1) {
        int shopIndex = (int)indexPath.row;
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopCell"];
//        cell.contentView.backgroundColor = [UIColor whiteColor];
        SHPShop *shop = [self.shops objectAtIndex:shopIndex];
        
        UILabel *nameLabel = (UILabel *) [cell viewWithTag:2];
        nameLabel.text = shop.name;
        
        UILabel *addressLabel = (UILabel *) [cell viewWithTag:3];
        addressLabel.text = shop.formattedAddress;
        
        
//        NSString *imageURL = [self productImageURL:product];
//        if(![self.imageCache getImage:imageURL]) {
//            [self startIconDownload:product forIndexPath:indexPath forColumnIndex:columnIndex];
//            // if a download is deferred or in progress, return a placeholder image
//            iv.image = [UIImage imageNamed:@"grid-big-empty-image.png"];
//            //                    iv.image = nil;
//        } else {
//            iv.image = [self.imageCache getImage:imageURL];
//        }
        
    } else if (indexPath.row == self.shops.count) { // last cell
        cell = [SHPComponents MainListMoreResultsCell:self.applicationContext.settings.mainListBgColor withTarget:self settings:self.applicationContext.settings];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.userInteractionEnabled = YES;
        [self updateMoreButtonCell:cell];
    }
    return cell;
}

-(SHPShop *)shopAtIndexPath:(NSIndexPath *)indexPath {
    return [self.shops objectAtIndex:indexPath.row];
}

// DC delegate

- (void)shopsLoaded:(NSArray *)shops {
    self.isLoadingData = NO;
    UITableViewCell *moreCell = [self moreButtonCell];
    [self updateMoreButtonCell:moreCell];
    if (!self.shops) {
        self.shops = [[NSMutableArray alloc] init];
    }
    [self.shops addObjectsFromArray:shops];
    if (shops.count == 0 || shops.count < self.loader.searchPageSize) {
        self.noMoreData = TRUE;
    }
    [self reloadTable];
}


-(void)networkError {
    NSLog(@"NETWORK ERROR!");
    self.isLoadingData = NO;
    self.isNetworkError = YES;
    if ([self.tableViewDelegate respondsToSelector:@selector(networkError)]) {
        [self.tableViewDelegate performSelector:@selector(networkError)];
    } else {
        NSLog(@"NO networkError Selector is impemented for the tableViewDelegate!");
    }
}

-(void)reloadTable {
    if ([self.tableViewDelegate respondsToSelector:@selector(reloadTable)]) {
        NSLog(@"RELOADING TABLE...");
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
    //NSLog(@"total downloads: %d", allDownloads.count);
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
    }
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (void)startIconDownload:(SHPShop *)shop forIndexPath:(NSIndexPath *)indexPath forColumnIndex:(NSInteger)columnIndex
{
    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:shop.imageURL];
    //    NSLog(@"IconDownloader..%@", iconDownloader);
    if (iconDownloader == nil)
    {
        iconDownloader = [[SHPImageDownloader alloc] init];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:[NSNumber numberWithInteger:columnIndex] forKey:@"columnIndex"];
        [options setObject:indexPath forKey:@"indexPath"];
        iconDownloader.options = options;
        
        NSString *imageURL = [self shopImageURL:shop];
        
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

-(NSString *)shopImageURL:(SHPShop *)shop {
    NSInteger _w = SHPCONST_SHOP_DETAIL_gridImageWidth;
    NSInteger _h = 500;
    //    if ([UIScreen mainScreen].scale == 2.0) {
    //        _w = _w * 2;
    //        _h = _h * 2;
    //    }
    NSString *_url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", shop.imageURL, (int)_w, (int)_h];
    return _url;
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader
{
//    BOOL blending = NO; // from settings
//    // blending momentaneously disabled because image aspect doesn't work
//    if (blending) {
//        UIImage *thumbTrasparencyImage = [SHPImageUtil previewThumbOnImage:[UIImage imageNamed:@"grid-big-empty-image.png"] image:image];
//        image = nil;
//        image = thumbTrasparencyImage;
//    }
//    [self.imageCache addImage:image withKey:imageURL];
//    NSDictionary *options = downloader.options;
//    NSIndexPath *indexPath = [options objectForKey:@"indexPath"];
//    NSInteger columnIndex = [((NSNumber *)[options valueForKey:@"columnIndex"]) integerValue];
//    // if the cell for the image is visible updates the cell
//    // but only if this subtable is visible
//    if (self.currentlyShown) {
//        NSArray *indexes = [self.tableView indexPathsForVisibleRows];
//        for (NSIndexPath *index in indexes) {
//            if (index.row == indexPath.row && index.section == indexPath.section) {
//                SHPGridCell *cell = (SHPGridCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
//                // the asynch image upload can interact with a new list that has
//                // in the expected position the "loading" cell or another cell
//                // different by a column-grid-cell
//                if ([cell respondsToSelector:@selector(viewAtColumn:)]) {
//                    UIView *columnView = [cell viewAtColumn:columnIndex];
//                    UIImageView *iv = (UIImageView *)[columnView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
//                    iv.image = image;
//                }
//            }
//        }
//    }
//    [self.imageDownloadsInProgress removeObjectForKey:imageURL];
}

-(void)moreButtonPressed:(id)sender
{
    NSLog(@"More Button pressed");
    self.searchStartPage = self.searchStartPage + 1;
    self.loader.searchStartPage = self.searchStartPage;
    [self searchShops];
    UITableViewCell *moreCell = [self moreButtonCell];
    if (moreCell) {
        [self updateMoreButtonCell:moreCell];
    }
}

// if visible, returns the cell of the moreButton (the last cell)
-(UITableViewCell *)moreButtonCell {
    if (!self.shops) {
        return nil;
    }
    // we can also test this: if last cell.identifier == LastCellIdent...
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == self.shops.count) {
            UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
            return cell;
        }
    }
    return nil;
}

-(void)updateMoreButtonCell:(UITableViewCell *)cell {
    NSLog(@"!!!! updateMoreButtonCell networkerror %d", self.isNetworkError);
    if (!cell) {
        return;
    }
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:20];
    if (self.isLoadingData && !self.isNetworkError) {
        button.hidden = YES;
        spinner.hidden = NO;
        [spinner startAnimating];
        cell.userInteractionEnabled = NO;
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
        NSLog(@"NO NETWORK ERROR!");
        button.hidden = NO;
        spinner.hidden = YES;
        [spinner stopAnimating];
        if (self.noMoreData) {
            NSLog(@"NO MORE DATA!");
            [button setTitle:NSLocalizedString(@"NoMoreResultsLKey", nil) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            button.enabled = NO;
            cell.userInteractionEnabled = NO;
        } else {
            NSLog(@"MORE DATA!");
            [button setTitle:NSLocalizedString(@"MoreResultsLKey", nil) forState:UIControlStateNormal];
            [button setTitleColor:self.applicationContext.settings.moreResultsButtonColor forState:UIControlStateNormal];
            button.enabled = YES;
            cell.userInteractionEnabled = YES;
        }
    } else if (self.isNetworkError) {
        button.hidden = YES;
        spinner.hidden = YES;
    }
    //    NSLog(@"</updateMoreButtonCell");
}

//- (void)tapImage:(UITapGestureRecognizer *)gesture {
//    UIImageView* imageView = (UIImageView*)gesture.view;
//    self.selectedIndex = [(NSNumber*)imageView.property integerValue];
//    SHPShop *selectedShop = [self.shops objectAtIndex:self.selectedIndex];
//    self.tapHandler(selectedShop, self.selectedIndex);
//}


// END TABLEVIEW

-(void)disposeResources {
    NSLog(@"...........>>>>>> DISPOSING LIST SHOPS <<<<<<..........");
    self.loader.shopDC.shopsLoadedDelegate = nil;
    [self.loader cancelOperation];
    [self terminatePendingImageConnections];
}

-(void)dealloc {
    NSLog(@"...........DEALLOCATING SHOPS LIST.......");
}

@end
