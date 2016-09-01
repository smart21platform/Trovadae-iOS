//
//  SHPProductDetail.h
//  BPP.it
//
//  Created by dario de pascalis on 27/02/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPProductDC.h"
#import "SHPImageDownloader.h"
#import "SHPLikeDCDelegate.h"
#import "SHPShopDC.h"
#import "SHPProductDC.h"
#import "SHPProductDeleteDC.h"
#import "SHPLikeDC.h"
#import "UPStackMenu.h"
#import "SHPVerifyUploadPermissionsDC.h"
#import "SHPProductDeleteDC.h"


@class SHPApplicationContext;
@class SHPProduct;
@class SHPImageCache;
@class SHPImageDownloader;
@class MBProgressHUD;
@class SHPProductsCollectionVC;

@interface SHPProductDetail : UITableViewController <SHPVerifyUploadPermissionsDCDelegate, SHPLikeDCDelegate, SHPProductDCDelegate, SHPShopsLoadedDCDelegate, SHPProductDeleteDCDelegate, UIActionSheetDelegate, UPStackMenuDelegate>{
    UIView *viewBackground;
    UIView *contentView;
    UPStackMenu *stack;
    BOOL multiStore;
    BOOL publicUpload;
    BOOL loadedProduct;
    BOOL loadedShop;
    BOOL loadingShop;
    BOOL loadingProductImage;
    BOOL loadingImageUser;
    BOOL loadingImageMap;
    BOOL loadingProduct;
    NSMutableArray *arrayUrlsDescription;
    NSString *nameLink;
    NSString *urlLink;
    NSString *urlImgPoiMap;
    NSString *remainingTime;
    NSString *detailImageURL;
    SHPProductDeleteDC *productDeleteDC;
    SHPLikeDC *likeDC;
    SHPProductsCollectionVC *contentProductsVC;
    UIButton *buttonLike;
    BOOL hideAuthor;
    BOOL hideShop;
    BOOL hideMap;
    BOOL hideCity;
    BOOL hideAddress;
    BOOL hideReport;
    NSArray *arrayButtonsAddProduct;
    NSString *emailProduct;
    SHPVerifyUploadPermissionsDC *verify;
    NSString *descriptionClean;
    CLGeocoder *geocoder;
    NSString *cityProduct;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableDictionary *likesInProgress;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) SHPProductDC *productDC;
@property (strong, nonatomic) SHPProduct *product;
@property (strong, nonatomic) SHPShopDC *shopDC;
@property (strong, nonatomic) SHPShop *shop;
//@property (strong, nonatomic) SHPUser *userProfile;
@property (strong, nonatomic) UIImageView *productImage;
@property (strong, nonatomic) UIImage *imageMap;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) UIActionSheet *menuSheet;
@property (assign, nonatomic) BOOL hideOtherProducts;
@property (strong, nonatomic) NSString *numberPlaces;
@property (strong, nonatomic) NSString *orariApertura;
@property (strong, nonatomic) NSString *plan;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

-(void)deleteProduct;

- (IBAction)actionCallChat:(id)sender;
- (IBAction)actionCallTelephon:(id)sender;
- (IBAction)actionLikePressed:(id)sender;
- (IBAction)showActionSheet:(id)sender;
- (IBAction)share:(id)sender;

- (IBAction)unwindToProductDetail:(UIStoryboardSegue*)sender;
@end
