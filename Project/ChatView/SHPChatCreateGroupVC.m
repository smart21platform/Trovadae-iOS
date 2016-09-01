//
//  SHPChatCreateGroupVC.m
//  Smart21
//
//  Created by Andrea Sponziello on 25/03/15.
//
//

#import "SHPChatCreateGroupVC.h"
#import "SHPModalCallerDelegate.h"
#import "SHPChatSelectGroupMembers.h"
#import "SHPApplicationContext.h"
#import "SHPImageUtil.h"

@implementation SHPChatCreateGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Nuovo Gruppo";
    
    [self.groupNameTextField becomeFirstResponder];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self addControlChangeTextField:self.groupNameTextField];
    
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    UITapGestureRecognizer *tapLabelView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self.groupImageView addGestureRecognizer:tapImageView];
    [self.addPhotoLabelOverloaded addGestureRecognizer:tapLabelView];
    self.addPhotoLabelOverloaded.userInteractionEnabled = YES;
    self.groupImageView.userInteractionEnabled = YES;
    [self photoMenu];
}

-(void)photoMenu {
    // init the photo action menu
    NSString *takePhotoButtonTitle = @"Scatta foto";
    NSString *chooseExistingButtonTitle = @"Scegli dalla galleria";
    
    self.photoMenuSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:takePhotoButtonTitle, chooseExistingButtonTitle, nil];
    self.photoMenuSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}

- (void)tapImage:(UITapGestureRecognizer *)gesture {
//    UIImageView* imageView = (UIImageView*)gesture.view;
    NSLog(@"tapped");
    [self.view endEditing:YES];
    [self.photoMenuSheet showInView:self.parentViewController.tabBarController.view];
}

- (IBAction)nextAction:(id)sender {
    [self performSegueWithIdentifier:@"AddMembers" sender:self];
}

- (IBAction)cancelAction:(id)sender {
    NSLog(@"dismiss %@", self.modalCallerDelegate);
    [self.view endEditing:YES];
    [self.modalCallerDelegate setupViewController:self didCancelSetupWithInfo:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddMembers"]) {
        NSLog(@"AddMembers");
        SHPChatSelectGroupMembers *vc = (SHPChatSelectGroupMembers *)[segue destinationViewController];
        NSLog(@"APPLICATION CONTEXT... %@", self.applicationContext);
        [self.applicationContext setVariable:@"groupName" withValue:self.groupNameTextField.text];
        vc.applicationContext = self.applicationContext;
        vc.modalCallerDelegate = self.modalCallerDelegate;
    }
}

-(void)addControlChangeTextField:(UITextField *)textField
{
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}
//


-(void)textFieldDidChange:(UITextField *)textField {
    NSString *text = textField.text;
    if ([text length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

// **************************************************
// **************** TAKE PHOTO SECTION **************
// **************************************************

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            [self takePhoto];
            break;
        }
        case 1:
        {
            [self chooseExisting];
            break;
        }
    }
}

- (void)takePhoto {
    NSLog(@"taking photo with user %@...", self.applicationContext.loggedUser);
    if (self.imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:^{NSLog(@"FINITO!");}];
}

- (void)chooseExisting {
    NSLog(@"choose existing...");
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    NSLog(@"cinitializeCamera...");
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // enable to crop
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    NSLog(@"initializePhotoLibrary...");
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;// SavedPhotosAlbum;// SavedPhotosAlbum;
    self.photoLibraryController.allowsEditing = YES;
    //self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self afterPickerCompletion:picker withInfo:info];
}

-(void)afterPickerCompletion:(UIImagePickerController *)picker withInfo:(NSDictionary *)info {
    self.bigImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"BIG IMAGE: %@", self.bigImage);
    // enable to crop
    // self.scaledImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"edited image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    if (!self.bigImage) {
        self.bigImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSLog(@"original image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    }
    // end
    
    self.scaledImage = [SHPImageUtil scaleImage:self.bigImage toSize:CGSizeMake(self.applicationContext.settings.uploadImageSize, self.applicationContext.settings.uploadImageSize)];
    NSLog(@"SCALED IMAGE w:%f h:%f", self.scaledImage.size.width, self.scaledImage.size.height);
    
    if (picker == self.imagePickerController) {
        UIImageWriteToSavedPhotosAlbum(self.bigImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    NSLog(@"image: %@", self.scaledImage);
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.scaledImage];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
    self.groupImageView.image = self.scaledImage; //[SHPImageUtil circleImage:self.scaledImage];
//    [self.addPhotoLabelOverloaded removeFromSuperview];
    self.addPhotoLabelOverloaded.hidden = YES;
//    self.addPhotoLabelOverloaded.userInteractionEnabled = NO;
    
    //    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    //    NSLog(@"imageFile: %@", imageFile);
    //
    //    PFObject *userPhoto = [PFObject objectWithClassName:@"Image"];
    //    NSLog(@"userPhoto: %@", userPhoto);
    //    userPhoto[@"file"] = imageFile;
    //    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //        if (succeeded) {
    //            NSLog(@"Image saved.");
    //            PFFile *imageFile = userPhoto[@"file"];
    //            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
    //                if (!error) {
    //                    NSLog(@"Downloading image...");
    //                    UIImage *image = [UIImage imageWithData:imageData];
    //                    UIImageWriteToSavedPhotosAlbum(image, self,
    //                                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //                }
    //            }];
    //        }
    //    }];
    //    NSLog(@"userPhoto: %@", userPhoto);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        NSLog(@"(SHPTakePhotoViewController) Error saving image to camera roll.");
    }
    else {
        //NSLog(@"(SHPTakePhotoViewController) Image saved to camera roll. w:%f h:%f", self.image.size.width, self.image.size.height);
    }
}

// **************************************************
// *************** END PHOTO SECTION ****************
// **************************************************

@end
