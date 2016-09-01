//
//  SHPCurrentUploadsViewController.m
//  Dressique
//
//  Created by andrea sponziello on 05/02/13.
//
//

#import "SHPCurrentUploadsViewController.h"
#import "SHPApplicationContext.h"
#import "SHPConnectionsController.h"
#import "SHPDataController.h"
#import "SHPProductUploaderDC.h"
//#import "SHPAddProductViewController.h"
#import "SHPComponents.h"
#import "SHPCategory.h"
#import "SHPShop.h"
#import "UIView+Property.h"

@interface SHPCurrentUploadsViewController ()

@end

@implementation SHPCurrentUploadsViewController

@synthesize tableView;
@synthesize applicationContext;
@synthesize stateUpdateTimer;
@synthesize selectedDataController;

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
	
    // init table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.hidden = NO;
    
//    NSLog(@"Current uploads count %d", self.applicationContext.connectionsController.controllers.count);
//    if (self.applicationContext.connectionsController.controllers.count > 0) {
//        for (SHPDataController *dc in self.applicationContext.connectionsController.controllers) {
//            NSLog(@"Upload description %@ progress %f state %d", dc.description, dc.progress, dc.currentState);
//        }
//    }
    
    [SHPComponents titleLogoForViewController:self];
    
    [self setupUploadsStateTimer];
}

-(void)viewDidDisappear:(BOOL)animated {
    if (self.stateUpdateTimer) {
        [self.stateUpdateTimer invalidate];
        self.stateUpdateTimer = nil;
    }
}

-(NSArray *)currentUploads {
    NSArray *sortedArray;
    sortedArray = [self.applicationContext.connectionsController.controllers sortedArrayUsingSelector:@selector(compare:)];
    NSArray* reversed = [[sortedArray reverseObjectEnumerator] allObjects];
    return reversed;
}

-(void)setupUploadsStateTimer {
    self.stateUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentState:) userInfo:nil repeats:YES];
}

-(void) updateCurrentState:(NSTimer *)timer {
    [self.tableView reloadData];
}

// TABLEVIEW DELEGATE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //    NSLog(@"ROWS IN SECTION!!!");
    NSInteger num;
    num = [self currentUploads].count;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *shopCellId = @"UploadCell";
    cell = (UITableViewCell *)[_tableView dequeueReusableCellWithIdentifier:shopCellId];
    NSInteger index = indexPath.row;
    //SHPDataController *dc = [[self currentUploads] objectAtIndex:index];
    SHPProductUploaderDC *dc2 = [[self currentUploads] objectAtIndex:index];
    //NSLog(@"[self currentUploads] %@ ", dc2.productDescription);
    NSLog(@"Rendering cell description %@ progress %f state %d", dc2.productDescription, dc2.progress, (int)dc2.currentState);
    
    cell = [self buildCell:cell withDataController:dc2 atIndexPath:indexPath];
    return cell;
}

-(UITableViewCell *)buildCell:(UITableViewCell *)cell withDataController:(SHPProductUploaderDC *)dc atIndexPath:(NSIndexPath *)indexPath {
    
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:1];
    if(dc.productDescription.length>1){
        descriptionLabel.text = [dc.productDescription capitalizedString];
    }else{
        descriptionLabel.text = [dc.productTitle capitalizedString];
    }
    
    
    UIButton *tryAgainButton = (UIButton *)[cell viewWithTag:5];
    tryAgainButton.property = dc; //[NSNumber numberWithInt:(indexPath.row)];
    [tryAgainButton addTarget:self action:@selector(tryAgainPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[tryAgainButton setImage:[UIImage imageNamed:@"ICO_RELOAD"] forState:UIControlStateNormal];
    
    
    UIButton *removeUploadButton = (UIButton *)[cell viewWithTag:6];
    removeUploadButton.property = dc; //[NSNumber numberWithInt:(indexPath.row)];
    [removeUploadButton addTarget:self action:@selector(removeUploadPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[removeUploadButton setImage:[UIImage imageNamed:@"checkKO"] forState:UIControlStateNormal];
    
    UILabel *currentStateLabel = (UILabel *)[cell viewWithTag:2];
    UIProgressView *progressView = (UIProgressView *) [cell viewWithTag:4];
    NSString *currentStateLabel_s = nil;
    if (dc.currentState == 10) { // UPLOADING
//        int progress_x100 = (int)roundf(100 * dc.progress);
//        currentStateLabel_s = [[NSString alloc] initWithFormat:@"%d%%", progress_x100];
//        currentStateLabel.textColor = [UIColor grayColor];
//        cell.accessoryType = UITableViewCellAccessoryNone;
        currentStateLabel.hidden = YES;
        progressView.hidden = NO;
        progressView.progress = dc.progress;
        tryAgainButton.hidden = YES;
        removeUploadButton.hidden = YES;
    } else if (dc.currentState == 20) { // FAILED
        currentStateLabel_s = NSLocalizedString(@"UploadFailedLKey", nil);
        currentStateLabel.textColor = [UIColor redColor];
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        currentStateLabel.hidden = NO;
        progressView.hidden = YES;
        tryAgainButton.hidden = NO;
        removeUploadButton.hidden = NO;
    } else if (dc.currentState == 30) { // TERMINATED
        currentStateLabel_s = @"UploadFinishedLKey";
        currentStateLabel.textColor = [UIColor blackColor];
//        cell.accessoryType = UITableViewCellAccessoryNone;
        currentStateLabel.hidden = NO;
        progressView.hidden = YES;
        tryAgainButton.hidden = YES;
        removeUploadButton.hidden = YES;
    }
    currentStateLabel.text = currentStateLabel_s;
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
    imageView.image = [(SHPProductUploaderDC *)dc productImage];
    return cell;
}

//- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"selected s:%d i:%d", indexPath.section, indexPath.row);
//    
//    SHPDataController *dc = (SHPDataController *)[[self currentUploads] objectAtIndex:indexPath.row];
//    if (dc.currentState == 20) { // if state=failed go to modify product form
//        self.selectedDataController = dc;
//        [self performSegueWithIdentifier:@"AddProduct" sender:self];
//    }
//    
//}

// FINE TABLEVIEW DELEGATE

-(void)tryAgainPressed:(id)sender
{
    SHPProductUploaderDC *uploadDC = (SHPProductUploaderDC *)((UIButton *)sender).property;
    self.selectedDataController = uploadDC;
    NSLog(@"try again upload %@", uploadDC);
    [self.selectedDataController send];
    [self.tableView reloadData];
//    NSNumber *index = (NSNumber *)((UIButton *)sender).property;
//    NSInteger index_int = [index integerValue];
//    NSLog(@"try Again pressed for index %d", index_int);
}

-(void)removeUploadPressed:(id)sender
{
    SHPProductUploaderDC *uploadDC = (SHPProductUploaderDC *)((UIButton *)sender).property;
    self.selectedDataController = uploadDC;
    NSLog(@"remove upload %@", uploadDC);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SeiSicuroDelete", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            // cancel
            NSLog(@"Delete canceled");
            break;
        }
        case 1:
        {
            // ok
            NSLog(@"Deleting. Select the reference with an instance property got from the button.property.");
            [self.selectedDataController cancelConnection];
            [self.applicationContext.connectionsController removeDataController:self.selectedDataController];
            // TODO introdurre un metodo DISPOSE nella classe base DataController e richiamarlo in ConnectionsController.removeDataController e ripostare la variabile di istanza selectedDataController al tipo base.
            [SHPProductUploaderDC deleteMeFromPersistentConnections:self.selectedDataController.uploadId];
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AddProduct"]) {
        // DISABLE THIS SEGUE!
        NSLog(@"disable this segue!!!");
//        SHPAddProductViewController *addProductVC = [segue destinationViewController];
//        SHPProductUploaderDC *uploader = (SHPProductUploaderDC *)self.selectedDataController;
//        
//        addProductVC.image = uploader.productImage;
//        addProductVC.selectedDescription = uploader.productDescription;
//        addProductVC.selectedPrice = uploader.productPrice;
//        addProductVC.selectedBrand = uploader.productBrand;
//        SHPCategory *selectedCategory = [[SHPCategory alloc] init];
//        selectedCategory.oid = uploader.productCategoryOid;
//        selectedCategory.name = uploader.productCategoryName;
//        addProductVC.selectedCategory = selectedCategory;
//        SHPShop *selectedShop = [[SHPShop alloc] init];
//        selectedShop.oid = uploader.productShopOid;
//        selectedShop.source = uploader.productShopSource;
//        selectedShop.googlePlacesReference = uploader.productShopGooglePlacesReference;
//        addProductVC.selectedShop = selectedShop;
//        
//        addProductVC.applicationContext = self.applicationContext;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeAction:(id)sender {
    if (self.stateUpdateTimer) {
        [self.stateUpdateTimer invalidate];
        self.stateUpdateTimer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc {
    NSLog(@"CURRENT UPLOADS VIEW DEALLOC");
}

@end
