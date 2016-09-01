//
//  SHPNotificationsViewController.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 24/01/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@interface SHPNotificationsViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) NSString *selectedProductID;
@property (strong, nonatomic) NSString *selectedUsername;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, strong) NSString *titlePage;
@property (nonatomic, strong) NSString *url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

-(IBAction)reloadWebPage:(id)sender;
- (void)initialize;

@end
