//
//  SHPReportViewController.m
//  Dressique
//
//  Created by andrea sponziello on 24/01/13.
//
//

#import "SHPReportViewController.h"
#import "SHPReportAbuseItem.h"
#import "SHPReportDC.h"
#import "SHPProduct.h"
#import "SHPApplicationContext.h"
#import "SHPReportDC.h"
#import "SHPTextBoxViewController.h"
#import "MBProgressHUD.h"
#import "SHPComponents.h"


@interface SHPReportViewController () {
    BOOL reportSent;
}

@end

@implementation SHPReportViewController

//@synthesize applicationContext;
//@synthesize product;
//
//@synthesize reportItems;
//@synthesize selectedItem;
//
//@synthesize modalCallerDelegate;
//
//@synthesize hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    reportSent = NO;
    self.selectedItemText = @"";
    
    // init table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.hidden = NO;
    
    self.reportItems = [[NSMutableArray alloc] init];
    SHPReportAbuseItem *item;
    
    item = [[SHPReportAbuseItem alloc] init];
    item.descriptionKey = @"Abuse1LKey";
    item.code = 1900;
    [self.reportItems addObject:item];
    
    item = [[SHPReportAbuseItem alloc] init];
    item.descriptionKey = @"Abuse2LKey";
    item.code = 1800;
    [self.reportItems addObject:item];
    
//    item = [[SHPReportAbuseItem alloc] init];
//    item.descriptionKey = @"Abuse3LKey";
//    item.code = 1700;
//    [self.reportItems addObject:item];
    
    item = [[SHPReportAbuseItem alloc] init];
    item.descriptionKey = @"Abuse4LKey";
    item.code = 1000;
    [self.reportItems addObject:item];
    
    item = [[SHPReportAbuseItem alloc] init];
    item.descriptionKey = @"Abuse5LKey";
    item.code = 100;
    [self.reportItems addObject:item];
    
    item = [[SHPReportAbuseItem alloc] init];
    item.descriptionKey = @"Abuse6LKey";
    item.code = 0;
    [self.reportItems addObject:item];
    
//    for (SHPReportAbuseItem *_item in self.reportItems) {
//        NSLog(@"item %@", _item.descriptionKey);
//    }
    self.ReportButton.title = NSLocalizedString(@"ReportLKey", nil);
    self.CancelButton.title = NSLocalizedString(@"CancelLKey", nil);
    
    [self customizeTitle:NSLocalizedString(@"ReportLKey", nil)];
}

-(void)customizeTitle:(NSString *)title {
    [SHPComponents titleLogoForViewController:self];
    self.navigationItem.title = NSLocalizedString(@"CancelLKey", nil);
//    self.navigationBar.topItem.title = title;
//    UILabel *navTitleLabel = [SHPComponents appTitleLabel:title withSettings:self.applicationContext.settings];
//    self.navigationBar.topItem.titleView = navTitleLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setReportButton:nil];
    [self setCancelButton:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}


#pragma mark - Table view data source




- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num;
    num = self.reportItems.count;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)__tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *itemCellId = @"AbuseItemCell";
    cell = [__tableView dequeueReusableCellWithIdentifier:itemCellId];
    NSInteger itemIndex = indexPath.row;
    SHPReportAbuseItem *item = [self.reportItems objectAtIndex:itemIndex];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    NSString *descriptionKey = item.descriptionKey;
    textLabel.text = NSLocalizedString(descriptionKey, nil);
    if ([self.reportItems objectAtIndex:itemIndex] == self.selectedItem) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    // selected color
//    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
//    myBackView.backgroundColor = selectedCellBGColor;
//    cell.selectedBackgroundView = myBackView;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"WhyAreYouReportingLKey", nil);
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"selected s:%d i:%d", (int)indexPath.section, indexPath.row);
    NSInteger itemIndex = indexPath.row;
    self.selectedItem = [self.reportItems objectAtIndex:itemIndex];
//    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
//    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView reloadData];
    if (self.selectedItem.code == 0) { // other
        [self performSegueWithIdentifier:@"OtherText" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"OtherText"]) {
        SHPTextBoxViewController *textBoxVC = [segue destinationViewController];
        NSLog(@">>>>>>>>>>>>>>>> %@", self.selectedItemText);
        textBoxVC.text = self.selectedItemText;
        textBoxVC.completionHandler = ^(NSString *text, BOOL canceled) {
            if (!canceled && text && ![text isEqualToString:@""]) {
                NSLog(@">>>>>>>>>>>>>>>>..... %@", text);
                self.selectedItemText = text;
            }
//            else {
//                self.selectedItem = nil;
//                [self.tableView reloadData];
//            }
        };
        textBoxVC.applicationContext = self.applicationContext;
    }
}

//// ////


- (IBAction)ReportAction:(id)sender {
    if (reportSent) {
        return;
    } else if(!self.selectedItem) {
        self.hud.labelText = NSLocalizedString(@"PleaseSelectAReasonForReportingThisItemLKey", nil);
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamation-point-image"]];

//        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox-circle"]];
        
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.center = self.view.center;
        self.hud.userInteractionEnabled = YES;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:0.8222];
        return;
    }
    // save with reportDC
    self.dc = [[SHPReportDC alloc] init];
    self.dc.delegate = self;
    reportSent = YES;
    [self.dc sendReportForObject:@"Product" withId:self.product.oid withAbuseType:self.selectedItem.code withText:self.selectedItemText withUser:self.applicationContext.loggedUser];
}

-(void)didFinishReport:(SHPReportDC *)dc withError:(id)error {
    NSLog(@"Finished Report");
//    [self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo:nil];
    if (self.modalCallerDelegate && [self.modalCallerDelegate respondsToSelector:@selector(justReported)]) {
        [self.modalCallerDelegate performSelector:@selector(justReported) withObject:nil];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)CancelAction:(id)sender {
    [self.dc cancelConnection];
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)dealloc {
    NSLog(@"REPORT VIEW DEALLOCATED.");
}
@end
