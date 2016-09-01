//
//  SHPLoadInitialDataViewController.m
//  Ciaotrip
//
//  Created by andrea sponziello on 25/02/14.
//
//

#import "SHPLoadInitialDataViewController.h"
#import "SHPCategoryDC.h"
#import "SHPApplicationContext.h"
#import "SHPCategory.h"
#import "SHPAppDelegate.h"
#import "SHPShopDC.h"
#import "SHPShop.h"
#import "SHPObjectCache.h"
//#import "SHPVerifyUploadPermissionsDC.h"
 

@interface SHPLoadInitialDataViewController () {
    UIAlertView* categoriesAlertView;
}
@end

@implementation SHPLoadInitialDataViewController

NSString *shopOid;
static NSString *LAST_SELECTED_CATEGORY_KEY = @"mainListSelectedCategory";
static NSString *LAST_LOADED_CATEGORIES = @"lastLoadedCategories";
static NSString *DICTIONARY_CATEGORIES = @"dictionaryCategories";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // inizializza i servizi di localizzazione. I servizi non partono subito per dare la possibilità
    // di visualizzare il messaggio "La App richiede i servizi di Localizzazione" dopo il
    // lancio del product tour. Se fossero stati attivati immediatamente alla partenza nell'AppDelegate
    // la dialog di richiesta sarebbe comparsa in corrispondenza del Product Tour. E' invece
    // il tour iniziale a dover spiegare come funziona la App e perchè saranno richiesti tali servizi.
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    //SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate initializeLocation];
    NSLog(@"LOADING PERMISSION UPLOAD!!!!!!!!!!!!!");
    [self loadCategories];
    //[self loadCategoriesFromPlist];
    NSLog(@"LOADING LOAD INITIAL DATA VIEW!!!!!!!!!!!!!");
    //[self loadCategories];
    [self.activityIndicator startAnimating];
}

//-(void)loadPermission{
//    SHPVerifyUploadPermissionsDC *verify = [[SHPVerifyUploadPermissionsDC alloc]init];
//    verify.delegate=self;
//    verify.applicationContext=self.applicationContext;
//    [verify verifyUploadPermission];
//}
//
//- (void)permissionCheck:(BOOL)permission{
//    self.applicationContext.permissionUpload=permission;
//    NSLog(@"PERMISSION UPLOAD DI = %hhd",  permission);
//    [self loadCategories];
//}




// ************ LOAD CATEGORIES **************

//-(void)loadCategoriesFromPlist{
//    NSArray *arrayCategories = [self.applicationContext.plistDictionary objectForKey:@"Categories"];
//    NSMutableArray *categories = [[NSMutableArray alloc]init];
//    NSLog(@"CATEGORIES: %@",arrayCategories);
//    for(NSDictionary *item in arrayCategories) {
//        NSString *name = [item valueForKey:@"label"];
//        NSString *type = [item valueForKey:@"type"];
//        NSString *oid = [item valueForKey:@"oid"];
//        SHPCategory *c = [[SHPCategory alloc] init];
//        c.oid = oid;
//        c.name = name;
//        c.type = type;
//        [categories addObject:c];
//    }
//    [self categoriesLoaded:categories error:nil];
//}

-(void)loadCategories {
    SHPCategoryDC *categoryDC = [[SHPCategoryDC alloc] init];
    categoryDC.delegate = self;
    [categoryDC getAll];
}

-(void)categoriesLoaded:(NSMutableArray *)_categories error:(NSError *)error {
//    [self.loadingHud hide:YES];
//    NSString *stringArray = [[NSString alloc] initWithFormat:@"categoriesLoaded %@",error];
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:stringArray delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
    if (error) {
        NSLog(@"ERROR LOADING CATEGORIES!");
        categoriesAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"TryAgainLKey", nil) otherButtonTitles:nil];
        [categoriesAlertView show];
    }
    else {
        NSLog(@"CATEGORIES LOADED!!!!! CALLER: %@",self.caller);
        NSMutableDictionary *dictionaryCategories = [[NSMutableDictionary alloc]init];
        for (SHPCategory *c in _categories) {
            NSLog(@"================== Category: %@ %@ %@ %d", c.oid, c.name, c.type, (int)c.visibility);
            [dictionaryCategories setValue:c.type forKey:c.oid];
        }
        [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:_categories];
        [self.applicationContext setVariable:DICTIONARY_CATEGORIES withValue:dictionaryCategories];
        if ([self.caller respondsToSelector:@selector(firstLoad:)]) {
            NSLog(@"OK: SELF.CALLER respondsToSelector:@selector(firstLoad)!!! %@",self.caller);
            [self.caller performSelector:@selector(firstLoad:) withObject:self.applicationContext];
        } else {
            NSLog(@"ERROR: SELF.CALLER NOT respondsToSelector:@selector(firstLoad)!!! %@",self.caller);
        }
        
        [self dismitionLoading];
        
        
//        NSLog(@"creatureDictionary%@",[self.applicationContext.plistDictionary objectForKey:@"shopOid"]);
//        if([self.applicationContext.plistDictionary objectForKey:@"shopOid"]){
//            shopOid = [NSString stringWithFormat:@"%@",[self.applicationContext.plistDictionary objectForKey:@"shopOid"]];
//            [self shopLoaded];
//        }
//        else{
//            [self dismitionLoading];
//        }
        
    }
}


-(void)shopLoaded{
    self.shopDC = [[SHPShopDC alloc] init];
    self.shopDC.shopsLoadedDelegate=self;
    //[self.shopDC setShopsLoadedDelegate:self];
    if(!self.shop.oid){
        NSLog(@"self.shopsLoadedDelegate: %@",self);
        [self.shopDC searchByShopId:shopOid];
    }
}

- (void)shopsLoaded:(NSArray *)shops {
    NSLog(@"Nr of Shops in delegate: %lu", (unsigned long)[shops count]);
    if(shops.count > 0) {
        NSLog(@"ADDING SHOP TO OBJECTS CACHE");
        self.shop = [shops objectAtIndex:0];
        [self.applicationContext.objectsCache addObject:self.shop withKey:self.shop.oid];
        [SHPApplicationContext saveLastWizardShop:self.shop];
        NSLog(@"SHOP LOADED: %@ ", self.shop.oid);
    } else {
        NSLog(@"Shop not found!");
    }
    [self dismitionLoading];
}


- (void)networkError {
    [self dismitionLoading];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //    [self hideAllAccessoryViews];
    //    [self showLocationErrorView];
    if (actionSheet == categoriesAlertView) {
        [self loadCategories];
    }
}

// **********
-(void)dismitionLoading{
    NSLog(@"dismitionLoading!!!");
    [self.activityIndicator stopAnimating];
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)unwindToSHPLoadInitialData:(UIStoryboardSegue*)sender
{
    NSLog(@"unwindToSHPLoadInitialData:");
    [self initialize];
}
@end
