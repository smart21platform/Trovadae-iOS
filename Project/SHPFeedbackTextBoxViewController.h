//
//  SHPFeedbackTextBoxViewController.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 28/03/14.
//
//

#import <UIKit/UIKit.h>
#import "SHPReportDC.h"

@class SHPApplicationContext;
@class MBProgressHUD;
@class SHPUserMenuTVC;

typedef void (^SHPTextBoxCompletionHandler)(NSString *text, BOOL canceled);

@interface SHPFeedbackTextBoxViewController : UIViewController <SHPReportDCDelegate, UITextViewDelegate>

@property (nonatomic, copy) SHPTextBoxCompletionHandler completionHandler;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;

@property (strong, nonatomic) SHPReportDC *dc;
@property (strong, nonatomic) MBProgressHUD *hud;

- (IBAction)doneAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

-(IBAction)cancelAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) SHPUserMenuTVC *userMenuTVC;

@end
