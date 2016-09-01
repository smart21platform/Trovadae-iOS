//
//  SHPShareSettingsViewController.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 13/02/14.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

@interface SHPShareSettingsViewController : UITableViewController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;

- (IBAction)selectFbPage:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *currentFacebookAccountLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeFacebookAccountButton;

@end
