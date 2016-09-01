//
//  SHPFirstStepWizardTVC.m
//  San Vito dei Normanni
//
//  Created by Dario De Pascalis on 17/07/14.
//
//

#import "SHPFirstStepWizardTVC.h"
#import "SHPApplicationContext.h"
#import "SHPWizardStep1Types.h"
//#import "SHPLoginHomeViewController.h"
#import "SHPDataController.h"
#import "SHPComponents.h"
#import "SHPProductDC.h"
#import "SHPProduct.h"
#import "SHPImageRequest.h"
#import "SHPImageUtil.h"
#import "SHPCreatedProductsLoader.h"
#import "SHPProductsLoaderStrategy.h"
#import "SHPProductDetail.h"
#import "SHPCurrentUploadsViewController.h"
#import "SHPConnectionsController.h"
#import "SHPConstants.h"
#import "SHPCaching.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPAuthenticationVC.h"
#import "SHPAppDelegate.h"
#import "SHPWizardStepStartReport.h"
#import "SHPWizardLandingPageTVC.h"
#import <pop/POP.h>

@interface SHPFirstStepWizardTVC ()
@end

@implementation SHPFirstStepWizardTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"SHPFirstStepWizardTVC %@", self.applicationContext);
    appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;

    isLoadingData = NO;
    deleteProduct = [[NSString alloc] initWithFormat:@""];
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    // init table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [SHPComponents titleLogoForViewController:self];
    
    //self.applicationContext.connectionsController.controllers=nil;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *viewDictionary = [plistDictionary objectForKey:@"View"];
    viewDictionary = [viewDictionary objectForKey:@"Wizard"];
    buttonReportVisible = [[viewDictionary objectForKey:@"ADD_REPORT"] boolValue];
    otypeReport =[NSString stringWithString:[viewDictionary objectForKey:@"OTYPE_REPORT"]];
    
    
    self.viewSegnalazione.hidden = NO;
    
    if(!buttonReportVisible || buttonReportVisible == NO){
        self.viewSegnalazione.hidden = YES;
        [self.viewSegnalazione setFrame:CGRectMake(self.viewSegnalazione.frame.origin.x, self.viewSegnalazione.frame.origin.y, self.viewSegnalazione.frame.size.width, 0)];
    }
    
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear **************** %@",self.applicationContext);
    [self.refreshControl endRefreshing];
    self.applicationContext = appDelegate.applicationContext;
    //se mi sono sloggato pulisce la tabella
    if (!self.applicationContext.loggedUser) {
        self.products = nil;
        NSLog(@" viewWillAppear products: %@",self.products);
        [self.tableView reloadData];
        
        if (self.refreshControl) {
            self.refreshControl = nil;
        }
        
    }
    else {
        if (!self.refreshControl) {
            UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
            refreshControl.tintColor = [UIColor grayColor];
            [refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
            self.refreshControl = refreshControl;
        }
        if(isLoadingData==YES){
            NSLog(@"isLoadingData: %d",isLoadingData);
            [self initialize];
        }
        else if([self.applicationContext getVariable:@"deleteProduct"]){
            NSLog(@"deleteProduct: %@",[self.applicationContext getVariable:@"deleteProduct"]);
            if(![(NSString *)[self.applicationContext getVariable:@"deleteProduct"] isEqualToString:@""]) {
                NSLog(@"PASSA: %@",self.products);
                self.products = nil;
                //[self.tableView reloadData];
                [self initialize];
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"DID APPEAR!");
    [self initialize];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"FirstStepWizard"];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    if (self.isMovingFromParentViewController) {
//        [self.countUploadsTimer invalidate];
//        self.countUploadsTimer=nil;
//        [self.createdProductsLoader.productDC cancelDownload];
//    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    if (countUploadsTimer) {
//        [countUploadsTimer invalidate];
//        countUploadsTimer = nil;
//    }
    
}

-(void)initialize{
    NSLog(@"INITIALIZING USER: %@",self.applicationContext.loggedUser);
    [SHPUserInterfaceUtil applyTitleString:(NSString *) NSLocalizedString(@"AddNewPost", nil) toAttributedLabel:self.labelButtonAdd];

    self.buttonAdd.layer.cornerRadius = self.buttonAdd.frame.size.height/2;
    self.buttonAdd.layer.masksToBounds = YES;
//    self.buttonAdd.layer.borderWidth = 0.1;
    [self.buttonAddReport setTitle:NSLocalizedString(@"AddNewReport", nil) forState:UIControlStateNormal];
    
    if (self.applicationContext.loggedUser) {
        NSLog(@"INITIALIZING USER");
        [self resetData];
        [self searchProducts];
    }
    else{
       // [self.refreshControl endRefreshing];

//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
//        UINavigationController *navigationController = [sb instantiateViewControllerWithIdentifier:@"start"];
//        SHPAuthentication *vc = (SHPAuthentication *)[[navigationController viewControllers] objectAtIndex:0];
        
        //[self goToAuthentication];

        //[self performSegueWithIdentifier:@"toLogin" sender:self];
    }
}

-(void)goToAuthentication{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    SHPAuthenticationVC *vc = (SHPAuthenticationVC *)[sb instantiateViewControllerWithIdentifier:@"StartAuthentication"];
    vc.applicationContext = self.applicationContext;
    //vc.disableButtonClose = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
}


-(void)resetData {
    NSLog(@"RESETTING DATA");
    self.products = nil;
    searchStartPage = 0;
    self.loader.searchStartPage = searchStartPage;
    noMoreData = NO;
    [self terminatePendingConnections];
    [imageDownloadsInProgress removeAllObjects];
}

-(void)terminatePendingConnections {
    NSLog(@"Terminating pending connections...");
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
        [obj cancelDownload];
    }
    [imageDownloadsInProgress removeAllObjects];
}

-(void)searchProducts {
    [self initCreatedLoader];
    self.loader.authUser = self.applicationContext.loggedUser;
    [self.loader loadProducts];
}

-(void)initCreatedLoader {
    self.createdProductsLoader = [[SHPCreatedProductsLoader alloc] init];
    self.createdProductsLoader.searchPageSize = self.applicationContext.settings.productsTablePageSize;
    self.createdProductsLoader.authUser = nil;
    self.createdProductsLoader.createdByUser = self.applicationContext.loggedUser;
    self.createdProductsLoader.productDC.delegate = self;
    self.loader = self.createdProductsLoader;
}

//-------------- DELEGATE --------------//
//[self.loader loadProducts]
- (void)loaded:(NSArray *)products {
    self.products = [[NSMutableArray alloc] init];
    isLoadingData = NO;
    NSLog(@"COUNTER _ PRODUCT UPLODATI %d", counter);
    if(counter && (counter==0 || counter<0) ){
         NSLog(@"STOP TIMER: %d",counter);
        [self stopTimer];
    }
    //passo id prodotto che è in fase di cancellazione e al caricamento dei prodotti se è stato caricato
    //perchè non ancora cancellato lo nascondo
    if([self.applicationContext getVariable:@"deleteProduct"]){
        self.idProductDeleting = (NSString *)[self.applicationContext getVariable:@"deleteProduct"];
        [self.applicationContext setVariable:@"deleteProduct" withValue:@""];
    }
    for (SHPProduct *product in products) {
        if(![product.oid isEqualToString:self.idProductDeleting]){
           [self.products addObject:product];
        }
    }
    //[self.products addObjectsFromArray:products];
    //NSLog(@"LOADED _ PRODUCT UPLODATI %@", self.products[0]);
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}
//------------ END DELEGATE -------------//


-(void)setupUploadsCountTimer {
    NSLog(@"START TIMERRRRRRR");
    countUploadsTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateCurrentUploads:) userInfo:nil repeats:YES];
}

-(void)stopTimer {
    if (countUploadsTimer) {
        [countUploadsTimer invalidate];
    }
    countUploadsTimer = nil;
    NSLog(@"countUploadsTimer: %@",countUploadsTimer);
}

-(void)updateCurrentUploads:(NSTimer *)timer {
    NSLog(@"num download: %d",counter);

    if(!(self.applicationContext.connectionsController.controllers.count==counter)){
        counter = (int)self.applicationContext.connectionsController.controllers.count;
        NSLog(@"NW num download: %d",counter);
        isLoadingData = YES;
        [self initialize];
    }
    else if(counter==0){
        NSLog(@"STOP TIMER: %d",counter);
        [self stopTimer];
    }
}




// TABLEVIEW DELEGATE
- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0)return 1;
    return self.products.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.applicationContext.loggedUser) {
        return 0;
    }
    else if(!self.products && indexPath.section == 0){
        return 60;
    }
    else if(indexPath.section == 0 && self.applicationContext.connectionsController.controllers.count==0)
    {
        return 0;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *shopCellId;
    
    if(!self.products){
        shopCellId = @"LoadingCell";
        cell = (UITableViewCell *)[_tableView dequeueReusableCellWithIdentifier:shopCellId];
        UILabel *labelLoading = (UILabel *)[cell viewWithTag:10];
        labelLoading.text = NSLocalizedString(@"UploadsInProgressLKey", nil);
        UIActivityIndicatorView *activityInd = (UIActivityIndicatorView *)[cell viewWithTag:11];
        [activityInd startAnimating];
    }
    else if(indexPath.section == 0){
        shopCellId = @"UploadCell";
        cell = (UITableViewCell *)[_tableView dequeueReusableCellWithIdentifier:shopCellId];
        UILabel *countUpload = (UILabel *)[cell viewWithTag:10];
        int conn_count = (int) self.applicationContext.connectionsController.controllers.count;
        NSString *_counts = [[NSString alloc] initWithFormat:@"%d %@",conn_count,  NSLocalizedString(@"UploadsInProgressLKey", nil)];
        countUpload.text = _counts;
        if(conn_count>0){
            [self setupUploadsCountTimer];
        }
    }
    else if(indexPath.section==1){
        shopCellId = @"CellCreated";
        cell = (UITableViewCell *)[_tableView dequeueReusableCellWithIdentifier:shopCellId];
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:11];
        UILabel *titleProduct = (UILabel *)[cell viewWithTag:12];
        UILabel *titleLoaded = (UILabel *)[cell viewWithTag:13];
        

        SHPProduct *product = self.products[indexPath.row];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd MMMM YYYY"];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        NSString *dateCreated = [[dateFormat stringFromDate:product.createdOn] capitalizedString];
        NSString *stringLoaded = [NSString stringWithFormat:@"%@: %@ %@ '%@'",NSLocalizedString(@"UploadedDateLKey", nil), dateCreated, NSLocalizedString(@"inCategoryLKey", nil), product.categoryLabel];
        
        if(product.title && ![product.title isEqualToString:@""]){
            titleProduct.text = product.title;
            titleLoaded.text = stringLoaded;
        }
        else if(product.longDescription && ![product.longDescription isEqualToString:@""] && ![product.longDescription isEqualToString:@"(null)"]){
            titleProduct.text = product.longDescription;
            titleLoaded.text = stringLoaded;
        }
        else{
            titleProduct.text = @"";
            titleLoaded.text = stringLoaded;
        }
        
        int w = 100;
        int h = 100;
        NSString *url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", product.imageURL, (int)w, (int)h];
        UIImage *cacheImage = [self.applicationContext.categoryIconsCache getImage:url];
        UIImage *archiveIcon = [SHPCaching restoreImage:url];

        if (cacheImage) {
            NSLog(@"cacheImage");
            iconView.image = cacheImage;
        }
        else if (archiveIcon) {
            NSLog(@"archiveIcon");
            iconView.image = archiveIcon;
        }
        else {
            NSLog(@"imageRquest");
            iconView.image = nil;
            SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
            [imageRquest downloadImage:url
                     completionHandler:
             ^(UIImage *image, NSString *imageURL, NSError *error) {
                 if (image) {
                     NSLog(@"SAVE IMAGE %@", imageURL);
                     [SHPCaching saveImage:image inFile:imageURL];
                     [self.applicationContext.categoryIconsCache addImage:image withKey:imageURL];
                     iconView.image = image;
                 }
             }];
        }
        [SHPImageUtil customIcon:iconView];
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==0){//self.applicationContext.connectionsController.controllers.count>0 &&
         [self performSegueWithIdentifier:@"toCurrentUploads" sender:self];
    }else if(indexPath.section==1){
        productLoaded = self.products[indexPath.row];
        //selectedProductID = productLoaded.oid;
        [self performSegueWithIdentifier: @"toDetailProduct" sender: self];
    }
}





- (void)networkError {
    //[self dismitionLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toLogin"]) {
        [self goToAuthentication];
    }
    else if ([[segue identifier] isEqualToString:@"toCurrentUploads"]) {
        SHPCurrentUploadsViewController *vc = (SHPCurrentUploadsViewController *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toDetailProduct"]) {
        NSLog(@"+++++++++++++++++++++++++++++++++++++++++ toDetailProduct");
        SHPProductDetail *vc = [segue destinationViewController];
        //SHPProduct *product = [[SHPProduct alloc] init];
        //product.oid = selectedProductID;
        vc.product = productLoaded;
        vc.applicationContext = self.applicationContext;
    }
}

-(void)goToWizard
{
    NSLog(@"+++++++++++++++++++++++++++++++++++++++++ actionStartWizard");
    if (!self.applicationContext.loggedUser) {
        [self goToAuthentication];
    }else{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"WizardStoryboard" bundle:nil];
        UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"start"];//[segue destinationViewController];
        SHPWizardLandingPageTVC *vc = (SHPWizardLandingPageTVC *)[[nc viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        
        NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
        [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:wizardDictionary];
        
        nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:nc animated:YES completion:NULL];
    }
}

-(void)goToWizardReport
{
    NSLog(@"+++++++++++++++++++++++++++++++++++++++++ goToWizardReport");
    if (!self.applicationContext.loggedUser) {
        [self goToAuthentication];
    }else{
        NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
        [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:wizardDictionary];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"WizardStoryboard" bundle:nil];
        UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"start"];//startReportOtype[segue destinationViewController];
        //SHPWizardStepStartReport *vc = (SHPWizardStepStartReport *)[[nc viewControllers] objectAtIndex:0];
        SHPWizardStep1Types *vc = (SHPWizardStep1Types *)[[nc viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.typeSelected = otypeReport;
        nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:nc animated:YES completion:NULL];
    }
}


- (IBAction)actionAddReport:(id)sender {
    [self goToWizardReport];
}

- (IBAction)actionStartWizard:(id)sender {
    // animate button
    POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.7, 0.7)];
    sprintAnimation.autoreverses = YES;
    [self.buttonAdd pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
    
    [self goToWizard];
}


- (IBAction)returnToFirstStep:(UIStoryboardSegue*)sender
{
    NSLog(@"+++++++++++++++++++++++++++++++++++++++++ returnToFirstStep");
    //addProduct = YES;
    isLoadingData = NO;
    [self.tableView reloadData];
}

-(void)dealloc {
    NSLog(@"DEALLOCATING SHP-FIRST-STEP-WIZARD-VC");
}

@end
