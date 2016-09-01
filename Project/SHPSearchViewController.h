//
//  SHPSearchViewController.h
//  Dressique
//
//  Created by andrea sponziello on 04/01/13.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;
@class SHPProduct;
@class SHPShop;
@class SHPUser;
@class SHPProductsTableList;
@class SHPShopsTableList;
@class SHPUsersTableList;

@interface SHPSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPProduct *productSelected;
@property (strong, nonatomic) SHPShop *shopSelected;
@property (strong, nonatomic) SHPUser *userSelected;

//@property (strong, nonatomic) UIView *searchBarView;
@property (strong, nonatomic) UISearchBar *searchBar;
//@property (strong, nonatomic) UIView *buttonsView;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//@property (assign, nonatomic) BOOL buttonsViewHidden;
@property (strong, nonatomic) NSString *searchBarPlaceholder;

@property (strong, nonatomic) NSString *textToSearch;
@property (strong, nonatomic) NSTimer *searchTimer;
@property (strong, nonatomic) NSString *lastProductsTextSearch;
@property (strong, nonatomic) NSString *lastShopsTextSearch;
@property (strong, nonatomic) NSString *lastUsersTextSearch;

@property (strong, nonatomic) SHPProduct *aProductWasDeleted;

// tableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedButtons;
- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)searchButtonAction:(id)sender;

//@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) SHPProductsTableList *listProducts;
@property (strong, nonatomic) SHPShopsTableList *listShops;
@property (strong, nonatomic) SHPUsersTableList *listUsers;
@property (assign, nonatomic) NSInteger listMode;

@property (strong, nonatomic) UITapGestureRecognizer *tapDismissController;

-(void)reloadTable;
-(void)networkError;

@end
