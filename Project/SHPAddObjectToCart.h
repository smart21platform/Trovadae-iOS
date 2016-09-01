//
//  SHPAddObjectToCart.h
//  Eurofood
//
//  Created by Dario De Pascalis on 10/09/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPProduct;

@interface SHPAddObjectToCart : UIViewController<UIWebViewDelegate>{
    UIColor *tintColor;
    UIActivityIndicatorView *activityIndicator;
    UIBarButtonItem *activityButtonItem;
    NSArray *arrayList;
    NSString *hostSite;
    NSString *tenant;
    NSString *pathEcommerce;
    NSString *urlPageAddToCart;
    NSString *domain;
    NSString *urlPage;
    NSString *responseAddProdToCart;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, strong) NSString *titlePage;
@property (nonatomic, strong) NSString *url;
@property (strong, nonatomic) SHPProduct *product;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)actionBack:(id)sender;

@end
