//
//  SHPChatCreateGroupVC.h
//  Smart21
//
//  Created by Andrea Sponziello on 25/03/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPModalCallerDelegate.h"

@class SHPApplicationContext;

@interface SHPChatCreateGroupVC : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *addPhotoLabelOverloaded;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;

// imagepicker
@property (strong, nonatomic) UIActionSheet *photoMenuSheet;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (nonatomic, strong) UIImage *scaledImage;
@property (strong, nonatomic) UIImage *bigImage;

- (IBAction)nextAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
