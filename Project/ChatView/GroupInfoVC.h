//
//  GroupInfoVC.h
//  Smart21
//
//  Created by Andrea Sponziello on 04/05/15.
//
//

#import <UIKit/UIKit.h>

@class ChatGroup;
@class SHPApplicationContext;

@interface GroupInfoVC : UITableViewController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;

@property(strong, nonatomic) NSString *groupId;
@property(strong, nonatomic) ChatGroup *group;

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *membersLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic) IBOutlet UILabel *adminLabel;

@end
