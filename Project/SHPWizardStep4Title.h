//
//  SHPWizardStep4Title.h
//  Galatina
//
//  Created by dario de pascalis on 17/02/15.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPCategory;

@interface SHPWizardStep4Title : UITableViewController<UITextViewDelegate>{
    NSDictionary *typesDictionary;
    NSString *typeSelected;
    NSDictionary *typeDictionary;
    NSString *kPlaceholderTitle;
    NSString *kPlaceholderDescription;
}
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;

@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *exampleButton;
@property (weak, nonatomic) IBOutlet UILabel *titleOfTitle;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleOfDescription;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;
@property (weak, nonatomic) IBOutlet UILabel *minimumWordsMessageLabel;

- (IBAction)actionButtonCellNext:(id)sender;
- (IBAction)actionNext:(id)sender;
@end
