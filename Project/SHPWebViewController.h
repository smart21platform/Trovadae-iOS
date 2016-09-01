//
//  SHPWebViewController.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 07/02/14.
//
//

#import <UIKit/UIKit.h>

@interface SHPWebViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, strong) NSString *urlPage;
- (IBAction)reloadPage:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
