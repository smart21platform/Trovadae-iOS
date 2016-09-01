//
//  SHPThanksDialog.h
//  Secondamano
//
//  Created by Andrea Sponziello on 26/02/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHPThanksDialog : UIViewController

- (IBAction)closeAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImage;

@end
