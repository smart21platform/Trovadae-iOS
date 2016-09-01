//
//  GroupMembersVC.h
//  Smart21
//
//  Created by Andrea Sponziello on 05/05/15.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

@interface GroupMembersVC : UITableViewController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableArray *members;

@end
