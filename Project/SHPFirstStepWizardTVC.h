//
//  SHPFirstStepWizardTVC.h
//  San Vito dei Normanni
//
//  Created by Dario De Pascalis on 17/07/14.
//
//

#import <UIKit/UIKit.h>
#import "SHPProductDCDelegate.h"


@class SHPApplicationContext;
@class SHPUser;
@class SHPProductsLoaderStrategy;
@class SHPCreatedProductsLoader;
@class SHPAppDelegate;
@class SHPProduct;

@interface SHPFirstStepWizardTVC : UITableViewController <SHPProductDCDelegate, UITableViewDelegate, UITableViewDataSource>{
    //NSString *selectedProductID;
    SHPProduct *productLoaded;
    int controllersCount;
    bool addProduct;
    NSString *deleteProduct;
    int counter;
    NSInteger searchStartPage;
    NSInteger searchPageSize;
    BOOL isLoadingData;
    BOOL noMoreData;
    NSMutableDictionary *imageDownloadsInProgress;
    NSTimer *countUploadsTimer;
    SHPAppDelegate *appDelegate;
    BOOL buttonReportVisible;
    NSString *otypeReport;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UILabel *labelButtonAdd;
@property (strong, nonatomic) SHPProductsLoaderStrategy *loader;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) SHPUser *user;
@property (strong, nonatomic) SHPCreatedProductsLoader *createdProductsLoader;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *idProductDeleting;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddReport;
@property (weak, nonatomic) IBOutlet UIView *viewSegnalazione;

- (IBAction)actionAddReport:(id)sender;

- (IBAction)actionStartWizard:(id)sender;

@end
