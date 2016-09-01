//
//  GroupInfoVC.m
//  Smart21
//
//  Created by Andrea Sponziello on 04/05/15.
//
//

#import "GroupInfoVC.h"
#import "ChatDB.h"
#import "ChatGroup.h"
#import "GroupMembersVC.h"
#import "SHPApplicationContext.h"

@interface GroupInfoVC ()

@end

@implementation GroupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Info gruppo";
    
    ChatDB *db = [ChatDB getSharedInstance];
    self.group = [db getGroupById:self.groupId];
    
    self.groupNameLabel.text = self.group.name;
    self.membersLabel.text = [ChatGroup membersArray2String:self.group.members];
    
    NSString *created_by_msg = @"Gruppo creato da";
    self.createdByLabel.text = [[NSString alloc] initWithFormat:@"%@ %@.",created_by_msg, self.group.owner];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd LLLL yyyy"];
    NSString *createdOn_s = [formatter stringFromDate:self.group.createdOn];
    NSString *created_on_msg = @"Creato il";
    self.createdOnLabel.text = [[NSString alloc] initWithFormat:@"%@ %@.", created_on_msg, createdOn_s];
    
    self.adminLabel.text = self.group.owner;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger index = indexPath.row;
    if (index == 1) {
        [self performSegueWithIdentifier:@"GroupMembers" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GroupMembers"]) {
        GroupMembersVC *vc = (GroupMembersVC *)[segue destinationViewController];
        NSLog(@"vc %@", vc);
        vc.members = self.group.members; // set in didSelectRowAtIndexPath
        NSLog(@"%@ %@", vc.members, self.group.members);
        vc.applicationContext = self.applicationContext;
    }
}


@end
