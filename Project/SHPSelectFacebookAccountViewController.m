//
//  SHPSelectFacebookAccountViewController.m
//  Ciaotrip
//
//  Created by andrea sponziello on 06/02/14.
//
//

#import "SHPSelectFacebookAccountViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SHPFacebookPage.h"
#import "SHPApplicationContext.h"

@interface SHPSelectFacebookAccountViewController ()

@end

@implementation SHPSelectFacebookAccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadError = NO;
//    // init table view
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.bounces = YES;
//    self.tableView.hidden = NO;
    
    // setup the pull-to-refresh view
    //    [self.tableView addPullToRefreshWithActionHandler:^{
    //        NSLog(@"Refresh after Pull-to-refresh");
    //        [self initializeData];
    //    }];
    
//    CGRect navBarFrame = self.navigationBar.frame;
//    NSLog(@"navBar y: %f", navBarFrame.origin.y);
//    //    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.navigationBar.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - self.navigationBar.frame.size.height);
    
    [self localizeLabels];
    
    [self initializeData];
}

-(void)localizeLabels {
//    self.cancelButton.title = NSLocalizedString(@"CancelLKey", nil);
//    //    self.navigationBar.topItem.title = NSLocalizedString(@"SelectCategoryTitleLKey", nil);
}

//-(void)viewWillAppear:(BOOL)animated {
//    [self initializeData];
//}

-(void)initializeData {
//    if (!FBSession.activeSession.isOpen) {
        NSLog(@"Opening new session.");
        [FBSession openActiveSessionWithPublishPermissions:[[NSArray alloc] initWithObjects:@"manage_pages", nil]
                                        defaultAudience:FBSessionDefaultAudienceEveryone
                                        allowLoginUI:YES
                                      completionHandler: ^(FBSession *session,
                                                              FBSessionState status,
                                                              NSError *error) {
                                          // VERY IMPORTANT:
                                          // This method is called also every time this session (activeSessio) will be closed
                                          // or modifies his state. For example on closeAndClearTokenInformation. So
                                          // I need to verify the state to ensure that this is called just on this opening.
                                          // 1. http://stackoverflow.com/questions/16744607/facebook-sdk3-5-closeandcleartokeninformation-calls-completion-handler-of-openac
                                          // 2. https://developers.facebook.com/x/bugs/127289947439471/
                                          //NSLog(@"....... session.state %d", session.state);
                                          //NSLog(@"....... FBSessionStateClosed %d", FBSessionStateClosed);
                                          if (session.state != FBSessionStateClosed) {
                                             NSLog(@"Session is now open. Error? %@", error);
                                             [FBSession setActiveSession:session];
                                             [self getFacebookAccounts];
                                          }
                                      }];
//    } else {
//        NSLog(@"Session was open.");
//        [self getFacebookAccounts];
//    }
}

-(void)getFacebookAccounts {
    NSLog(@"Requesting user's accounts.");
    NSString *requestPath = @"/me/accounts";
    FBRequest *accountsReq = [FBRequest requestForGraphPath:requestPath];
    [accountsReq startWithCompletionHandler: ^(FBRequestConnection *connection,
                                               NSDictionary<FBGraphUser> *results,
                                               NSError *error) {
        //        [self hideWaiting];
        if (!error) {
            NSLog(@"User data retriving successfull. Now parsing json.");// %@", results);
            NSArray *pages = [self jsonToPages:results];
            for (SHPFacebookPage *page in pages) {
//                NSLog(@"accessToken: %@", page.accessToken);
//                NSLog(@"category: %@", page.category);
//                NSLog(@"id: %@", page.page_id);
                NSLog(@"name: %@", page.name);
//                NSLog(@"perms: %@", page.perms);
//                NSLog(@"------");
                self.pages = pages;
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"A Request Error occurred.........: %@", error);
            self.loadError = YES;
            [self.tableView reloadData];
        }
    }];
    
    //    [ requestWithGraphPath:@"/me/accounts" andDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source




- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        return NSLocalizedString(@"SelectFacebookPageLKey", nil);
    }
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    NSInteger num;
//    num = self.accounts ? [self.accounts count] : 0;
//    return num;
    if (section == 0) {
            return 1;
    } else { // section 1
        if (self.pages.count > 0) {
            return self.pages.count;
        } else {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *cellId = @"AccountCell";
    cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    if (indexPath.section == 0) {
        name.text = NSLocalizedString(@"FacebookDiaryLKey", nil);
        [cell setUserInteractionEnabled:YES];
        if (!self.applicationContext.postToFacebookPage) {
            NSLog(@"SELECTING DIARY");
            [self checkCell:cell value:YES];
        } else {
            NSLog(@"UN-SELECTING DIARY");
            [self checkCell:cell value:NO];
        }
    } else {
        if (self.pages.count > 0) {
            SHPFacebookPage *page = (SHPFacebookPage *)[self.pages objectAtIndex:indexPath.row];
            NSLog(@"PROCESSING PAGE %@/%@ - CURRENT: %@/%@", page.name, page.page_id, self.applicationContext.postToFacebookPage.name, self.applicationContext.postToFacebookPage.page_id);
            name.text = page.name;
            if (self.applicationContext.postToFacebookPage && [self.applicationContext.postToFacebookPage.page_id isEqualToString:page.page_id]) {
                [self checkCell:cell value:YES];
                NSLog(@"SELECTING PAGE %@", page.name);
            } else {
                NSLog(@"UN-SELECTING PAGE %@", page.name);
                [self checkCell:cell value:NO];
            }
            [cell setUserInteractionEnabled:YES];
        }
        else if (self.pages && self.pages.count == 0) {
            name.text = NSLocalizedString(@"NoResultsLKey", nil);
            [cell setUserInteractionEnabled:NO];
            [self checkCell:cell value:NO];
        }
        else if (self.loadError) {
            name.text = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
            [cell setUserInteractionEnabled:NO];
            [self checkCell:cell value:NO];
        }
        else {
            name.text = NSLocalizedString(@"LoadingLKey", nil);
            [cell setUserInteractionEnabled:NO];
            [self checkCell:cell value:NO];
        }
    }
    return cell;
}

-(void)checkCell:(UITableViewCell *)cell value:(BOOL)checked {
    if (checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"selected s:%d i:%d", indexPath.section, indexPath.row);
//    NSLog(@"CURRENT PAGE %@ - id: %@", self.applicationContext.postToFacebookPage.name, self.applicationContext.postToFacebookPage.page_id);
//    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        self.applicationContext.postToFacebookPage = nil;
    } else {
        self.applicationContext.postToFacebookPage = [self.pages objectAtIndex:indexPath.row];
    }
    SHPFacebookPage *currentPage = self.applicationContext.postToFacebookPage;
    // resets the check on previous category
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
        if (index.section == 0) {
            if (!currentPage) {
                [self checkCell:cell value:YES];
            } else {
                [self checkCell:cell value:NO];
            }
        } else {
            SHPFacebookPage *pageAtRow = (SHPFacebookPage *)[self.pages objectAtIndex:index.row];
            if (currentPage && [currentPage.page_id isEqualToString:pageAtRow.page_id]) {
                [self checkCell:cell value:YES];
            } else {
                [self checkCell:cell value:NO];
            }
        }
    }
//
//    // setting new check
//    UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:indexPath];
//    UIImageView *imageView = (UIImageView *)[cell viewWithTag:21];
//    imageView.image = [UIImage imageNamed: @"check2.png"];
//    NSLog(@"SELECTING NEW CHECK %@", imageView);
//    
//    self.selectedCategory = [self.categories objectAtIndex:indexPath.row];
//    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
//    [options setObject:self.selectedCategory forKey:@"category"];
//    [options setObject:self.categories forKey:@"categories"];
}


// CONNECTION DELEGATE


//-(void)categoriesLoaded:(NSMutableArray *)_categories {
//    //    NSLog(@"CATEGORIES LOADED!!!!!");
//    [self.tableView.pullToRefreshView stopAnimating];
//    [self hideActivityView];
//    self.categories = _categories;
//    if (self.showCategoryAll) {
//        NSLog(@"...........Show Category ALL...........");
//        SHPCategory *categoryAll = [[SHPCategory alloc] init];
//        categoryAll.oid = @"/";
//        categoryAll.name = NSLocalizedString(@"CategoryAllLKey", nil);
//        [self.categories insertObject:categoryAll atIndex:0];
//    } else {
//        NSLog(@"NOT Show Category ALL...........");
//    }
//    [self.tableView reloadData];
//}

//-(void)networkError {
//    // dismiss "Loading Activity" view
//    //    [activityController.view removeFromSuperview];
//    [self hideActivityView];
//    // show "Network error" view
//    [self showErrorView];
//}

//- (IBAction)dismissAction:(id)sender {
//    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
//    if(self.categories) {
//        //        if (self.showCategoryAll) {
//        //            [self.categories removeObjectAtIndex:0]; // removes categoryAll
//        //        }
//        [options setObject:self.categories forKey:@"categories"];
//    }
//    [self.modalCallerDelegate setupViewController:self didCancelSetupWithInfo: options];
//}
//
//-(void)showActivityView {
//    //    NSLog(@"frame y: %f", self.tableView.bounds.origin.y);
//    if (self.activityController == nil) {
//        self.activityController = [[SHPActivityViewController alloc] initWithFrame:self.tableView.frame];
//    }
//    [self.view addSubview:self.activityController.view];
//    [self.activityController startAnimating];
//}
//
//-(void)hideActivityView {
//    [self.activityController.view removeFromSuperview];
//    [self.activityController stopAnimating];
//}
//
//-(void)showErrorView {
//    if (!self.errorController) {
//        self.errorController = [[SHPNetworkErrorViewController alloc] initWithFrame:self.tableView.frame];
//        //        errorController.target = self;
//        [self.errorController setTargetAndSelector:self buttonSelector:@selector(retryDataButtonPressed)];
//        NSString *errorMessage = NSLocalizedString(@"ConnectionErrorLKey", nil);
//        self.errorController.message = errorMessage;
//    }
//    //    [self.view insertSubview:self.errorController.view aboveSubview:self.view];
//    [self.view addSubview:self.errorController.view];
//}
//
//-(void)hideErrorView {
//    [self.errorController.view removeFromSuperview];
//}
//
//-(void)retryDataButtonPressed {
//    NSLog(@"TRYING AGAIN...");
//    [self hideErrorView];
//    [self hideActivityView];
//    [self initializeData];
//}

- (NSArray *)jsonToPages:(NSDictionary *)jsonDictionary {
//    NSError* error;
//    NSDictionary *objects = [NSJSONSerialization
//                             JSONObjectWithData:jsonData
//                             options:kNilOptions
//                             error:&error];
    
    //    NSString *channel = [objects valueForKey:@"channel"];
    //    NSLog(@"Channel: %@", channel);
    //    NSString *date = [objects valueForKey:@"date"];
    //    NSLog(@"Date: %@", date);
//    NSArray *items = [objects valueForKey:@"items"];
    NSLog(@"Iterating json");
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    for(NSDictionary *item in [jsonDictionary objectForKey:@"data"]) {
        SHPFacebookPage *page =[[SHPFacebookPage alloc] init];
        
        NSString *accessToken = [item valueForKey:@"access_token"];
        NSString *category = [item valueForKey:@"category"];
        NSString *page_id = [item valueForKey:@"id"];
        NSString *name = [item valueForKey:@"name"];
        NSString *perms = [item valueForKey:@"perms"];
        
        page.accessToken = accessToken;
        page.category = category;
        page.page_id = page_id;
        page.name = name;
        page.perms = perms;
        
        [pages addObject:page];
        
    }
    return pages;
}

- (IBAction)returnToSelectFacebook:(UIStoryboardSegue*)sender
{
    NSLog(@"CIAO");
    [self.tableView reloadData];
}

@end
