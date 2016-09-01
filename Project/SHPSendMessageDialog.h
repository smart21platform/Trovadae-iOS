//
//  SHPSendMessageDialog.h
//  Secondamano
//
//  Created by Andrea Sponziello on 12/02/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHPSendMessageDialog : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
- (IBAction)sendAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;

@property (assign, nonatomic) BOOL canceled;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *productDescription;
@property (strong, nonatomic) NSString *username;

@property (strong, nonatomic) NSString *userMessage;

@end
