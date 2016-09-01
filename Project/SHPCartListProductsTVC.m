//
//  SHPCartListProductsTVC.m
//  Eurofood
//
//  Created by Dario De Pascalis on 02/07/14.
//
//

#import "SHPCartListProductsTVC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPProduct.h"
#import "SHPObjectCart.h"

@interface SHPCartListProductsTVC ()
@end

@implementation SHPCartListProductsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    carrello = [[SHPObjectCart alloc] init];
    
    [self initialize];
}


-(void)initialize{
    nItems=0;
    totalPrice=0;
    [self customizeTitle:nil];
    //SHPProduct *product = [[SHPProduct alloc]init];
    //[self.refreshControl beginRefreshing];
    NSLog(@"applicationContext: %d", self.applicationContext.dictionaryArrayCart.count);
    for(NSArray *item in self.applicationContext.dictionaryArrayCart){
        NSLog(@"item %@",item);
        //nItems=nItems+[item[1] intValue];
        //product = item[0];
        //totalPrice = totalPrice + [product.price floatValue];
    }
    [self.refreshControl endRefreshing];
    self.labelTotalCart.text = [NSString stringWithFormat:@"Totale provvisorio (%d articoli): %f", nItems, totalPrice];
}

-(void)customizeTitle:(NSString *)title {
    if(title == nil){
        UIImage *logo = [UIImage imageNamed:@"title-logo"];
        UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
        self.navigationItem.titleView = titleLogo;
        self.navigationItem.title=nil;
    }else{
        //[SHPComponents titleLogoForViewController:self];
        self.navigationItem.title = title;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.refreshControl beginRefreshing];
    [self initialize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
