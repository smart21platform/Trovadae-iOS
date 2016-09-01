//
//  SHPWebViewNotification.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 22/05/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;

@interface SHPWebViewNotification : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) NSString *urlNotification;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityUrlPage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButtonItem;
- (IBAction)refreshUrlPage:(id)sender;
@end
