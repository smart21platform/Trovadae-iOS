//
//  SHPUserMenuTVC.h
//  San Vito dei Normanni
//
//  Created by Dario De Pascalis on 15/07/14.
//
//

#import <UIKit/UIKit.h>
#import "SHPUserDC.h"
#import "SHPVerifyUploadPermissionsDC.h"

@class SHPApplicationContext;
@class SHPAppDelegate;

@interface SHPUserMenuTVC : UITableViewController<SHPUserDCDelegate, SHPVerifyUploadPermissionsDCDelegate>{
    SHPAppDelegate *appDelegate;
    NSString *copyright;
    NSString *urlMoreInfo;
    NSString *nameApp;
    NSString *versionApp;
    NSString *appID;
    
    NSDictionary *viewDictionary;
    NSDictionary *userMenuDictionary;
    NSMutableArray * allSections;
    SHPUser *userProfile;
    int numberSection;
    NSString *urlPage;
    
    BOOL webViewHiddenToolBar;
    BOOL addObjetFromMenu;
    NSString *webViewTitlePage;
}


@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPUserDC *userDC;
@property (strong, nonatomic) NSString *fullNameLabel;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) UIImage *profileImage;


-(void)justReported;
-(void)startRefresh;
- (IBAction)returnPrimo:(UIStoryboardSegue *)segue;

@end
