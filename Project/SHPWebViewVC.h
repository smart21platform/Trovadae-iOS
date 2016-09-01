//
//  SHPWebViewVC.h
//  Vacanze in Puglia
//
//  Created by Dario De Pascalis on 31/07/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;

@interface SHPWebViewVC : UIViewController<UIWebViewDelegate, UIActionSheetDelegate>{
    UIBarButtonItem *refreshButtonItem;
    UIActivityIndicatorView *activityIndicator;
    UIBarButtonItem *activityButtonItem;
    UIColor *tintColor;
    UIColor *colorBackground;
}


@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *selectedProductID;
@property (nonatomic, assign) NSString *url;
@property (nonatomic, assign) NSString *titlePage;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;


- (IBAction)forwardLink:(id)sender;
- (IBAction)reloadPage:(id)sender;
- (IBAction)nextPage:(id)sender;
- (IBAction)backPage:(id)sender;
- (IBAction)actionBack:(id)sender;
@end
