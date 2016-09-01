//
//  SHPTextBoxViewController.h
//  Dressique
//
//  Created by andrea sponziello on 31/01/13.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

typedef void (^SHPTextBoxCompletionHandler)(NSString *text, BOOL canceled);

@interface SHPTextBoxViewController : UIViewController

@property (nonatomic, copy) SHPTextBoxCompletionHandler completionHandler;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *text;

- (IBAction)doneAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (weak, nonatomic) IBOutlet UITextView *textView;

//- (IBAction)cancelAction:(id)sender;

@end
