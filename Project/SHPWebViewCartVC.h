//
//  SHPWebViewCartVC.h
//  Eurofood
//
//  Created by Dario De Pascalis on 30/09/14.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;
@interface SHPWebViewCartVC : UIViewController<UIWebViewDelegate>{
    NSArray *arrayList;
    NSString *hostSite;
    NSString *tenant;
    NSString *domain;
    NSString *pathEcommerce;
    NSString *urlPageCart;
    NSDate *startDate;
    UIColor *tintColor;
    UIActivityIndicatorView *activityIndicator;
    UIBarButtonItem *refreshButtonItem;
    UIBarButtonItem *activityButtonItem;
    NSString *loggedUser;
    
    int refreshPage;
    float AUTO_RELOAD_INTERVAL;
    NSString *TAB_NOTIFICATIONS_CART;
}

@property (strong, nonatomic) NSString *selectedProductID;
@property (strong, nonatomic) NSString *selectedUsername;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, strong) NSString *titlePage;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *variable;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorLoading;

- (IBAction)actionClose:(id)sender;
-(void) openViewForProductID:(NSString *)productID;
- (void)initialize;
@end

