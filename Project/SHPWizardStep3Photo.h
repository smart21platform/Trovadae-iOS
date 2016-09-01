//
//  SHPWizardStep3Photo.h
//  Galatina
//
//  Created by dario de pascalis on 17/02/15.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPCategory;

@interface SHPWizardStep3Photo : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    BOOL singlePoi;
    NSString *shopOid;
    NSDictionary *nextStep;
    NSString *typeSelected;
    NSDictionary *typeDictionary;
    NSString *otypeAd;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (assign,nonatomic) Boolean backActionClose;

@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (nonatomic, strong) UIImage *scaledImage;
@property (strong, nonatomic) UIImage *bigImage;
@property (weak, nonatomic) UIView *caller;

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *ChooseFromGalleryButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;

- (IBAction)actionButtonCellNext:(id)sender;
- (IBAction)takePhoto;
- (IBAction)chooseExisting;
- (IBAction)actionNext:(id)sender;
- (IBAction)cancelAction:(id)sender;


@end
