//
//  SHPSendMessageDialog.m
//  Secondamano
//
//  Created by Andrea Sponziello on 12/02/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "SHPSendMessageDialog.h"

@implementation SHPSendMessageDialog

-(void)viewDidLoad {
    [super viewDidLoad];
    
//    self.topMessageLabel.text = NSLocalizedString(@"SendMessageDialogTopLabel", nil);
    self.topMessageLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"SendMessageDialogTopLabel", nil), self.username];
                             
    NSString *buttonTitle = NSLocalizedString(@"SendMessageDialogButton", nil);
    [self.sendButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.messageTextView  becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
    self.usernameLabel.text = self.username;
    self.descriptionTextView.text = self.productDescription;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"unwind..."]) {
//        //NSLog(@"goToPoiDetail");
//        SHPPoiDetailTVC *VC = [segue destinationViewController];
//        VC.applicationContext = self.applicationContext;
//        VC.shop = self.shop;
//        VC.imageMap = self.imageMap;
//        VC.distance = self.product.distance;
//    }
}

- (IBAction)sendAction:(id)sender {
    NSString *alertMessage = [[NSString alloc] initWithFormat:@"Invio il messaggio a %@?", self.username];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"CancelLKey", nil), nil];
    alertView.tag = 1;
    [alertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"Conferma");
            if(actionSheet.tag == 1) {
                NSLog(@"tag = 1");
                [self sendMessage];
            }
            break;
        }
        case 1:
        {
            NSLog(@"Annulla");
            break;
        }
    }
}

-(void)sendMessage {
    self.userMessage = [self.messageTextView.text stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];
    if ([self.userMessage length] > 0) {
        self.canceled = NO;
        [self performSegueWithIdentifier:@"unwindToProductDetail" sender:self];
    }
}

- (IBAction)cancelAction:(id)sender {
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.canceled = YES;
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"unwindToProductDetail" sender:self];
}

@end
