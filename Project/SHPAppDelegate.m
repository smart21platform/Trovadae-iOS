//
//  SHPAppDelegate.m
//  Shopper
//
//  Created by andrea sponziello on 24/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "SHPApplicationContext.h"
#import "SHPApplicationSettings.h"
#import "SHPCaching.h"
#import "SHPConstants.h"
#import "SHPUser.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SHPAuth.h"
#import "SHPConnectionsController.h"
#import "SHPObjectCache.h"
#import "SHPFacebookConnectionsHandler.h"
#import "SHPTimelineProductsLoader.h"
#import "SHPProductDC.h"
#import "SHPProductsViewController2.h"
#import "SHPProductUploaderDC.h"
#import "SHPStringUtil.h"
#import "SHPSendTokenDC.h"
#import "SHPNewNotificationsCountDC.h"
#import "SHPNotificationsViewController.h"
#import "MBProgressHUD.h"
#import "SHPImageUtil.h"
#import "ChatManager.h"
#import "Appirater.h"
#import "ChatRootNC.h"
#import "SHPConversationsVC.h"
#import <Parse/Parse.h>

#import <sys/utsname.h>

@implementation SHPAppDelegate

NSString *const BFTaskMultipleExceptionsException = @"BFMultipleExceptionsException";

@synthesize window = _window;
@synthesize applicationContext;

static NSString *NOTIFICATION_TYPE_KEY = @"t"; //type
static NSString *NOTIFICATION_TYPE_LIKE_KEY = @"like_msg";
static NSString *NOTIFICATION_TYPE_URI_KEY = @"uri";
static NSString *NOTIFICATION_TYPE_ALERT_KEY = @"alert";
static NSString *NOTIFICATION_TYPE_CHAT_KEY = @"chat";


static NSString *NOTIFICATION_URI_KEY = @"cURI";
static NSString *NOTIFICATION_ALERT_KEY = @"alert";
static NSString *NOTIFICATION_PRODUCCT_ID_KEY = @"productID";
static NSString *NOTIFICATION_APS_KEY = @"aps";
static NSString *NOTIFICATION_BADGE_KEY = @"badge";

int TAB_NOTIFICATIONS_INDEX;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Initializing...");
    // application context initialization
    SHPApplicationContext *context = [[SHPApplicationContext alloc] init];
    self.applicationContext = context;
    
    // initi connections
    self.applicationContext.connections = [[NSMutableDictionary alloc] init];
    
    //----------------------------------------------------------------------------//
    NSLog(@"Init Parse...");
    //----------------------------------------------------------------------------//
    // Initialize Parse.
    
    // Salve Smart
    //    [Parse setApplicationId:@"i2Eg6RiHZa6V4to1nlArgBS02YB2asjVSZu279eA"
    //                  clientKey:@"VDEYanraAKyQwdhYIK7pQhZXM585Dyii8cR56T6w"];
    
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    self.applicationContext.plistDictionary=plistDictionary;
    
    NSDictionary *parse_config = [plistDictionary objectForKey:@"Parse"];
    NSString *applicationId = [parse_config objectForKey:@"applicationId"];
    NSString *clientKey = [parse_config objectForKey:@"clientKey"];
    
    // Chat21
    [Parse setApplicationId:applicationId
                  clientKey:clientKey];
//    [Parse setApplicationId:@"i2Eg6RiHZa6V4to1nlArgBS02YB2asjVSZu279eA"
//                  clientKey:@"VDEYanraAKyQwdhYIK7pQhZXM585Dyii8cR56T6w"];
    
    // [Optional] Track statistics around application opens.
//    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    NSLog(@"Parse initialized.");
    //----------------------------------------------------------------------------//
    
    //----------------------------------------------------------------------------//
    //START FACEBOOK LOGIN
    //http://www.appcoda.com/ios-programming-facebook-login-sdk/
    //----------------------------------------------------------------------------//
    [FBLoginView class];
    [FBProfilePictureView class];
    //----------------------------------------------------------------------------//
    //END FACEBOOK LOGIN
    //----------------------------------------------------------------------------//
    
    //----------------------------------------------------------------------------//
    //CONFIG NAVIGATION BAR
    //----------------------------------------------------------------------------//
    // application context initialization
//    SHPApplicationContext *context = [[SHPApplicationContext alloc] init];
//    self.applicationContext = context;
//    
//    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
//    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
//    self.applicationContext.plistDictionary=plistDictionary;
    
    
    // chat config
    // ChatManager *chat = [ChatManager getSharedInstance];
    NSDictionary *settings_config = [plistDictionary objectForKey:@"Config"];
    NSString *tenant = [settings_config objectForKey:@"tenantName"];
    NSLog(@"initialize chat on tenant: %@", tenant);
    
    NSDictionary *settingsDictionary = [plistDictionary objectForKey:@"Settings"];
    NSString *firebase_chat_ref = (NSString *)[settingsDictionary objectForKey:@"Firebase-chat-ref"];
    NSLog(@"initialize chat on firebase ref: %@", firebase_chat_ref);
    [ChatManager initializeWithFirebaseRef:firebase_chat_ref tenant:tenant context:applicationContext];
    // end chat config

    
    
    if([settingsDictionary valueForKey:@"TAB_NOTIFICATIONS_INDEX"]){
        TAB_NOTIFICATIONS_INDEX = [[settingsDictionary valueForKey:@"TAB_NOTIFICATIONS_INDEX"] intValue];
    }else{
        TAB_NOTIFICATIONS_INDEX = -1;
    }
    
    TAB_NOTIFICATIONS_INDEX = [[settingsDictionary valueForKey:@"TAB_NOTIFICATIONS_INDEX"] intValue];
    NSLog(@"TAB_NOTIFICATIONS_INDEX %d", TAB_NOTIFICATIONS_INDEX);
    
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        NSDictionary *navigationBarDictionary = [plistDictionary objectForKey:@"BarNavigation"];
        
        bool traslucent = [[navigationBarDictionary valueForKey:@"traslucent"] boolValue];
        [[UINavigationBar appearance] setTranslucent:traslucent];
        
        UIColor *colorBackground = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"colorBackground"]];
        [[UINavigationBar appearance] setBarTintColor:colorBackground];
        
        UIColor *tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
        [[UINavigationBar appearance] setTintColor: tintColor];
        
        UIColor *shadowColorText = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"shadowColorText"]];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = shadowColorText;
        shadow.shadowOffset = CGSizeMake(1, 0);
        
        NSString *fontText = [navigationBarDictionary valueForKey:@"fontText"];
        float fontSizeText = [[navigationBarDictionary valueForKey:@"fontSizeText"] floatValue];
        //UIFont *font = [UIFont fontWithName:fontText size:fontSizeText];
        
        
        NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: tintColor,
                                          NSShadowAttributeName: shadow,
                                          NSFontAttributeName: [UIFont fontWithName:fontText size:fontSizeText]
                                          };
        
        [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
        UIColor *buttonItemColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"buttonItemColor"]];
        [[UIBarButtonItem appearance] setTintColor:buttonItemColor];
    }
    bool statusBarStyle = [[settingsDictionary objectForKey:@"setStatusBarStyle"] boolValue];
    if(statusBarStyle == YES){
        [[UIApplication sharedApplication] setStatusBarStyle : UIStatusBarStyleLightContent];//];
        NSLog(@"Status bar UIStatusBarStyleLightContent");
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle : UIStatusBarStyleDefault];//UIStatusBarStyleLightContent];
    }
    
    //----------------------------------------------------------------------------//
    //END NAVIGATION BAR
    
    
    //----------------------------------------------------------------------------//
    //START APPIRATER
    //----------------------------------------------------------------------------//
    //https://github.com/arashpayan/appirater/blob/master/README.md
    NSString *appID = (NSString *)[settingsDictionary objectForKey:@"appID"];
    [Appirater setAppId:appID];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    //----------------------------------------------------------------------------//
    //END APPIRATER
    //----------------------------------------------------------------------------//

    
    
    //SET Google Analytics
    //----------------------------------------------------------------------------//
    //http://www.raywenderlich.com/53459/google-analytics-ios
    /******* Set your tracking ID here *******/
    //static NSString *const googleAnalyticsId = @"UA-58967469-2";
//    NSString *googleAnalyticsId = [settingsDictionary valueForKey:@"googleAnalyticsId"];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    //[GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    //[GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    //[[GAI sharedInstance] trackerWithTrackingId:googleAnalyticsId];
    
    //END Google Analytics
    //----------------------------------------------------------------------------//
    
    // initialize settings
    SHPApplicationSettings *settings = [[SHPApplicationSettings alloc] initWithFile:@"settings"];
    context.settings = settings;
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTitleColor:settings.appTitleColor forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTitleColor:settings.appTitleColor forState:UIControlStateHighlighted];
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    // init lastUsedShops
    context.onDiskLastUsedShops = [SHPCaching restoreLastUsedShops];
    // init onDiskData
    self.applicationContext.onDiskData = [SHPCaching restoreDictionaryFromFile:SHPCONST_LAST_DATA_FILE_NAME];
    if (!self.applicationContext.onDiskData) {
        self.applicationContext.onDiskData = [[NSMutableDictionary alloc] init];
    }
    //    NSString *name = @"Soleto";
    //    [SHPApplicationContext saveSearchLocationName:name];
    
    //restore searchLocationPosition & Name
    context.searchLocation = [SHPApplicationContext restoreSearchLocation];
    context.searchLocationName = [SHPApplicationContext restoreSearchLocationName];
    NSLog(@"--------------------%@", context.searchLocationName);
    
    // init main list image cache
    SHPImageCache *mainListImageCache = [[SHPImageCache alloc] init];
    mainListImageCache.maxSize = self.applicationContext.settings.productListImageCacheSize;
    context.mainListImageCache = mainListImageCache;
    
    // init product detail image cache
    SHPImageCache *detailImageCache = [[SHPImageCache alloc] init];
    detailImageCache.maxSize = context.settings.productDetailImageCacheSize;
    context.productDetailImageCache = detailImageCache;
    
    SHPImageCache *smallImagesCache = [[SHPImageCache alloc] init];
    smallImagesCache.maxSize = self.applicationContext.settings.smallImagesCacheSize;
    context.smallImagesCache = smallImagesCache;
    
    SHPImageCache *categoryIconsCache = [[SHPImageCache alloc] init];
    categoryIconsCache.maxSize = 20; // TODO in settings
    context.categoryIconsCache = categoryIconsCache;
    
    SHPObjectCache *objectsCache = [[SHPObjectCache alloc] init];
    context.objectsCache = objectsCache;
    
    SHPConnectionsController *connectionsController = [[SHPConnectionsController alloc] init];
    self.applicationContext.connectionsController = connectionsController;
    
    // init with persistent current uploads (in event of crash this preserves current uploads)
    NSMutableArray *uploadIds = [SHPProductUploaderDC uploadIdsOnDisk];
    NSLog(@"Saved uploads count: %d", (int)uploadIds.count);
    for (NSString *id in uploadIds) {
        NSLog(@"Upload Id: %@", id);
        SHPProductUploaderDC *uploaderDC = [SHPProductUploaderDC getPersistentUploaderById:id];
        uploaderDC.connectionsControllerDelegate = connectionsController;
        uploaderDC.applicationContext = applicationContext;
        [connectionsController addDataController:uploaderDC];
    }
    self.applicationContext.backgroundConnections = [[NSMutableArray alloc] init];
    NSLog(@"INITIALIZED self.applicationContext %@", self.applicationContext);
    [self initUser];
    NSLog(@"SAVED LOGGED USER: %@", self.applicationContext.loggedUser);
    if (![context isFirstLaunch]) {
        [self initializeLocation]; //***************** DA RIPRISTINARE **************************************//
    }
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    self.applicationContext.tabBarController = tabController;
    
    [self buildTabBar];
    [self configTabBar];
    //------------------------------------------------------------------------------------------------------------------//
    //END DARIO
    //------------------------------------------------------------------------------------------------------------------//
    NSArray *controllers = [tabController viewControllers];
    tabController.delegate = self;
    int controllerIndex = 0;
    for(UIViewController *vc in controllers) {
        if ([vc class] == [UINavigationController class]) {
            NSArray *viewControllers = [(UINavigationController *)vc viewControllers];
            if (viewControllers.count > 0) {
                UIViewController *firstController = [[(UINavigationController *)vc viewControllers] objectAtIndex:0];
                //NSLog(@"Initializing Root Controller at index %d - %@", controllerIndex, firstController);
                if ([firstController respondsToSelector:@selector(setApplicationContext:)]) {
                    [firstController setValue:context forKey:@"applicationContext"];
                }
                if ([firstController respondsToSelector:@selector(setLoader:)]) {
                    //NSLog(@"Controller is HomeController and responds to setLoader. Creating and setting Loader and Title...");
                    
                    // title
                    //                    SHPProductsViewController2 *productsViewController = (SHPProductsViewController2 *) firstController;
                    //                    [productsViewController updateViewTitle:@""];
                    
                    // loader
                    SHPTimelineProductsLoader *loader = [[SHPTimelineProductsLoader alloc] init];
                    loader.authUser = context.loggedUser;
                    loader.searchStartPage = 0;
                    loader.searchPageSize = context.settings.mainListSearchPageSize;
                    loader.searchLocation = self.applicationContext.lastLocation;
                    loader.productDC.delegate = (SHPProductsViewController2 *) firstController;
                    [firstController setValue:loader forKey:@"loader"];
                }
            } else {
                NSLog(@"viewControllers.count = 0!");
            }
        }
        controllerIndex++;
    }
    
    
    // preloading chat controllers
    NSLog(@"Preloading ChatRootNC");
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
        [nc loadViewIfNeeded]; // preload navigation controller
        [nc.topViewController loadViewIfNeeded]; // preload conversations' view
        NSLog(@"ChatRootNC loaded.");
    } else {
        NSLog(@"ChatRootNC does'n exist.");
    }

    
    
    
    // #notificationworkflow
    
    // NOTE: The notification-registration workflow starts in "applicationDidBecomeActive"
    // Get remote push notifications on application startup
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"REMOTE NOTIFICATION STARTED THE APPLICATION!");
        [self processRemoteNotification:userInfo];
    }
    // activate DC to POLL the count of new notifications
    //[self startNewNotificationsPolling];
    [self startPushNotifications:application];
    
    return YES;
}

-(void)startPushNotifications:(UIApplication *)application {
    // START NOTIFICATION
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *user_settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                  categories:nil];
    [application registerUserNotificationSettings:user_settings];
    [application registerForRemoteNotifications];
}

-(void)buildTabBar {
    NSDictionary *tabBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarTab"];
    NSArray *tabBarMenuItems = [tabBarDictionary objectForKey:@"Menu"];
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    // Adding tabbar controllers (using StoryboardID)
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    UIViewController *vc = [[UIViewController alloc]init];
    for (NSDictionary *tabBarConfig in tabBarMenuItems) {
        NSString *StoryboardControllerID = [tabBarConfig objectForKey:@"StoryboardControllerID"];
        if([tabBarConfig objectForKey:@"StoryboardName"]){
            storyboard = [UIStoryboard storyboardWithName:[tabBarConfig objectForKey:@"StoryboardName"] bundle: nil];
        }else{
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        }
        vc = [storyboard instantiateViewControllerWithIdentifier:StoryboardControllerID];
        NSLog(@"Adding controller %@", StoryboardControllerID);
        [controllers addObject:vc];
    }
    [tabController setViewControllers:controllers];
    
    // configuring tabbar buttons
    UITabBar *tabBar = tabController.tabBar;
    int i=0;
    for(UITabBarItem *tab in tabBar.items) {
        NSDictionary *tabBarItemConfig = [tabBarMenuItems objectAtIndex:i];
        NSLog(@"tabBarItemConfig %@, %@", tabBarItemConfig[@"title"], tabBarItemConfig[@"StoryboardControllerID"]);
        //UIImage *image = [UIImage imageNamed:tabBarItemConfig[@"icon"]];
        //image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        //UIImage *imageSelected = [image imageWithRenderingMode:UIImageRenderingModeAutomatic];//UIImageRenderingModeAlwaysOriginal
        tab.title = tabBarItemConfig[@"title"];
        //        [tab setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaLTStd-Roman" size:10.0f], NSFontAttributeName,  [UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        
        [tab setImage:[[UIImage imageNamed:tabBarItemConfig[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAutomatic]];//UIImageRenderingModeAlwaysOriginal
        [tab setSelectedImage:[[UIImage imageNamed:tabBarItemConfig[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
        //UIColor *tintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"tintColor"]];
        i++;
    }
}

-(void)configTabBar{
    //----------------------------------------------------------------------------//
    //CONFIG TABBAR
    //----------------------------------------------------------------------------//
    // http://stackoverflow.com/questions/18795117/change-tab-bar-tint-color-ios-7
    //http://www.appcoda.com/ios-programming-how-to-customize-tab-bar-background-appearance/
    
    if ([[UITabBar class] respondsToSelector:@selector(appearance)]) {
        NSDictionary *tabBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarTab"];
        UIColor *tintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"tintColor"]];
        [[UITabBar appearance] setTintColor: tintColor]; //set button active
        //[[UITabBar appearance] setSelectedImageTintColor:tintColor];
        
        UIColor *barTintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"barTintColor"]];
        [[UITabBar appearance] setBarTintColor:barTintColor]; //set background tabbar
        
        
        // [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
        //                                        forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : tintColor }
                                                 forState:UIControlStateSelected];
        //[[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
        //                                                            NSForegroundColorAttributeName : [UIColor redColor]
        //                                                            } forState:UIControlStateNormal];
    }
}

-(NSDictionary *)checkItemTabTagIn:(NSArray *)arrayTabbar itemTabTag:(int)tag{
    for (NSDictionary *itemTab in arrayTabbar){
        if(tag == [itemTab[@"tag"] intValue]){
            return itemTab;
        }
    }
    return nil;
}

//-(void)assignNameTabBarItems:(UITabBarController *)tabController {
//    // localize tabbar buttons' titles
//    // OCCHIO AGLI INDICI DELL'ARRAY!!!
//    UIViewController *uvButtonHome = [tabController.viewControllers objectAtIndex:TAB_HOME_INDEX];
//    uvButtonHome.tabBarItem.title = NSLocalizedString(@"HomeLKey", nil);
//    UIViewController *uvButtonSearch = [tabController.viewControllers objectAtIndex:TAB_SEARCH_INDEX];
//    uvButtonSearch.tabBarItem.title = NSLocalizedString(@"ExploreLKey", nil);
////    UIViewController *uvButton3 = [tabController.viewControllers objectAtIndex:2];
////    uvButton3.tabBarItem.title = NSLocalizedString(@"AddLKey", nil);
//
//    UIViewController *uvButtonNotificationsOFF = (UIViewController *)[self.applicationContext getVariable:@"notifications-off"];
//    uvButtonNotificationsOFF.tabBarItem.title = NSLocalizedString(@"NotificationsLKey", nil);
//
//    UIViewController *uvButtonNotificationsON = (UIViewController *)[self.applicationContext getVariable:@"notifications-on"];
//    uvButtonNotificationsON.tabBarItem.title = NSLocalizedString(@"NotificationsLKey", nil);
//
////    UIViewController *uvButton4 = [tabController.viewControllers objectAtIndex:TAB_NOTIFICATIONS_INDEX];
////    uvButton4.tabBarItem.title = NSLocalizedString(@"NotificationsLKey", nil); // 2
////    UIViewController *uvButton5 = [tabController.viewControllers objectAtIndex:TAB_NOTIFICATIONS_INDEX + 1]; // 3
////    uvButton5.tabBarItem.title = NSLocalizedString(@"NotificationsLKey", nil);
//    UIViewController *uvButtonMenu = [tabController.viewControllers objectAtIndex:TAB_MENU_INDEX];
//    uvButtonMenu.tabBarItem.title = NSLocalizedString(@"MoreKey", nil);
//
//}

// #notificationsworkflow
//static float NOTIFICATIONS_DELAY = 60.0; //seconds

// #notificationsworkflow
-(void)startNewNotificationsPolling {
    NSLog(@"Start notification polling");
    [self performSelector:@selector(findNewNotificationsCount) withObject:nil];
}

// #notificationsworkflow
-(void)findNewNotificationsCount {
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //    NSLog(@"findNewNotificationsCount call after timeout. %@", self.applicationContext.loggedUser);
    //    SHPNewNotificationsCountDC *nndc = [[SHPNewNotificationsCountDC alloc] init];
    //    [nndc getCountForUser:self.applicationContext.loggedUser completionHandler:^(NSInteger count, NSError *error) {
    //        NSLog(@"SHPNewNotificationsCountDC response with count %d. Updating badge", count);
    //        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    //        if (count > 0 && TAB_NOTIFICATIONS_INDEX>=0) {
    //            [[[[tabController tabBar] items] objectAtIndex:TAB_NOTIFICATIONS_INDEX] setBadgeValue:[NSString stringWithFormat:@"%d", (int)count]];
    ////            [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    //        }
    ////        else {
    ////            [[[[tabController tabBar] items] objectAtIndex:3] setBadgeValue:nil];
    ////            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    ////        }
    //    }];
    //    // restart loop
    ////    NSLog(@"Restarting loop.");
    //    [self performSelector:@selector(findNewNotificationsCount) withObject:nil afterDelay:NOTIFICATIONS_DELAY];
}

// #notificationsworkflow
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"REMOTE NOTIFICATION CAUGHT WHILE APPLICATION WAS RUNNING.");
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        NSLog(@"APPLICATION WAS RUNNING IN BACKGROUND!");
        [self processRemoteNotification:userInfo];
    }
    else {
        NSLog(@"APPLICATION IS RUNNING IN FOREGROUND!");
        //ignored. timed polling is good enough?
    }
}

//-(void) registerForRemoteNotifications {
//    // registering for remote notifications
//    [self registerToAPN];
//}

// #notificationsworkflow
-(void) registerToAPN {
    NSLog(@">>>>>> Registering App for remote notifications...");
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound];
    }
    
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    //    {
    //        // iOS 8 Notifications
    //        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    //        [[UIApplication sharedApplication] registerForRemoteNotifications];
    //    }
    //    else
    //    {
    //        // iOS < 8 Notifications
    //        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    //         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    //    }
    // delegetes:
    // didRegisterForRemoteNotificationsWithDeviceToken
    // didFailToRegisterForRemoteNotificationsWithError
}

// #notificationsworkflow
-(void) processRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"REMOTE NOTIFICATION: %@", userInfo);
    NSString *notification_type = [userInfo objectForKey:NOTIFICATION_TYPE_KEY]; // type
    NSLog(@">>>>>>>> ........... ********* notification_type: %@", notification_type);
    NSDictionary *aps = [userInfo objectForKey:NOTIFICATION_APS_KEY];
    NSLog(@"aps: %@", aps);
    NSString *alert = [aps objectForKey:NOTIFICATION_ALERT_KEY];
    NSLog(@"alert: %@", alert);
    
    if ([notification_type isEqualToString:NOTIFICATION_TYPE_LIKE_KEY]) { // like notification
        NSString *productID = [userInfo objectForKey:NOTIFICATION_PRODUCCT_ID_KEY];
        NSString *badge = [[userInfo objectForKey:NOTIFICATION_APS_KEY] objectForKey:NOTIFICATION_BADGE_KEY];
        NSLog(@"Badge: %@", badge);
        NSLog(@"ProductID: %@", productID);
        
        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        UINavigationController *notificationsNavigationController = [controllers objectAtIndex:TAB_NOTIFICATIONS_INDEX];
        SHPNotificationsViewController *nc = [[notificationsNavigationController viewControllers] objectAtIndex:0];
        //[nc openViewForProductID:productID];
        tabController.selectedIndex = TAB_NOTIFICATIONS_INDEX;
    }
    else if ([notification_type isEqualToString:NOTIFICATION_TYPE_URI_KEY]) {
        NSString *contentURI = [userInfo objectForKey:NOTIFICATION_URI_KEY];
        NSLog(@"contentURI: %@", contentURI);
        
        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        UINavigationController *nc = [controllers objectAtIndex:TAB_HOME_INDEX];
        
        SHPProductsViewController2 *productsVC = [[nc viewControllers] objectAtIndex:0];
        if ([contentURI hasPrefix:@"http:"]) {
            [productsVC openWebViewForURL:contentURI];
        }
        else if ([contentURI hasPrefix:@"alert:"]) {
            [productsVC openAlertMessage:alert];
        }
        else { // if ([contentURI hasPrefix:@"deal:"])
            [productsVC openViewForProductID:contentURI]; // EX. "event://UUID" | UUID | deal://UUID
        }
        tabController.selectedIndex = TAB_HOME_INDEX;
    }
    else if ([notification_type isEqualToString:NOTIFICATION_TYPE_ALERT_KEY]) {
        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        UINavigationController *nc = [controllers objectAtIndex:TAB_HOME_INDEX];
        
        SHPProductsViewController2 *productsVC = [[nc viewControllers] objectAtIndex:0];
        [productsVC openAlertMessage:alert];
        
        tabController.selectedIndex = TAB_HOME_INDEX;
    }
    else if ([notification_type isEqualToString:NOTIFICATION_TYPE_CHAT_KEY]) {
        NSString *sender = [userInfo objectForKey:@"sender"];
        NSString *to = [userInfo objectForKey:@"to"];
        NSString *conversationId = [userInfo objectForKey:@"convId"];
        NSString *badge = [[userInfo objectForKey:NOTIFICATION_APS_KEY] objectForKey:NOTIFICATION_BADGE_KEY];
        NSString *alert = [[userInfo objectForKey:NOTIFICATION_APS_KEY] objectForKey:NOTIFICATION_ALERT_KEY];
        
        NSLog(@"==>Sender: %@", sender);
        NSLog(@"==>To: %@", to);
        NSLog(@"==>Alert: %@", alert);
        NSLog(@"==>ConversationId: %@", conversationId);
        NSLog(@"==>Badge: %@", badge);
        
        //---------- move to conv tab
        int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
        NSLog(@"processRemoteNotification: messages_tab_index %d", chat_tab_index);
        // move to the converstations tab
        if (chat_tab_index >= 0) {
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            UITabBarController *tabController = (UITabBarController *)window.rootViewController;
            NSArray *controllers = [tabController viewControllers];
            ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
            [nc popToRootViewControllerAnimated:NO];
            SHPConversationsVC *vc = nc.viewControllers[0];
            
            //            [vc loadViewIfNeeded]; // CONVERSATIONS VIEW IS PRELOADED, REMOVE THIS LINE
            //            vc.selectedRecipient = sender;
            [vc openConversationWithRecipient:sender];
            tabController.selectedIndex = chat_tab_index;
        } else {
            NSLog(@"No Chat Tab configured");
        }
    }

    
    
}



// #notificationsworkflow
// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    self.registeredToAPN = YES;
    //    const void *devTokenBytes = [devToken bytes];
    NSString *devTokenHEXString = [SHPStringUtil data2HexadecimalString:devToken];
    self.deviceToken = devTokenHEXString;
    NSLog(@">>>>>>> Application successfully regitered to APN with devToken %@", devTokenHEXString);
    [self sendDeviceTokenToProvider:devTokenHEXString]; // custom method
    
    // PARSE NOTIFICATIONS
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:devToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

-(void)saveParseInstallationWithUsername:(NSString *)username deviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (deviceToken) {
        [currentInstallation setDeviceTokenFromData:deviceToken];
    }
    if (username) {
        [currentInstallation setObject:self.applicationContext.loggedUser.username forKey:@"username"];
    }
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSInteger errCode = [error code];
        if (succeeded) {
            NSLog(@"AppDelegate. Installation successfully saved...");
        }
        else {
            NSLog(@"AppDelegate. Installation saved with error: %d", (int) errCode);
        }
    }];
}

// #notificationsworkflow
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@">>>>>>> Error in APN registration: %@", err);
}

// #notificationworkflow
-(void)sendDeviceTokenToProvider:(NSString *)devToken {
    NSLog(@"Registering Token to Provider");
    SHPSendTokenDC *tokenDC = [[SHPSendTokenDC alloc] init];
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    if (self.applicationContext.loggedUser) {
        [tokenDC sendToken:devToken withUser:self.applicationContext.loggedUser lang:langID completionHandler:^(NSError *error) {
            if (!error) {
                NSLog(@"Successfully registered DEVICE to Provider WITH USER.");
                //                self.registeredToProvider = YES;
            }
            else {
                NSLog(@"Error while registering devToken to Provider!");
                // If there is an error in registration it is not a big issue.
                // This method is always called every time the application goes in background
                // and newly became active (see: ApplicationDidBecomeActive)
            }
        }];
    }
    else {
        [tokenDC sendToken:devToken lang:langID completionHandler:^(NSError *error) {
            if (!error) {
                NSLog(@"Successfully registered DEVICE to Provider WITHOUT USER.");
                //                self.registeredToProvider = YES;
            }
            else {
                NSLog(@"Error while registering devToken to Provider!");
            }
        }];
    }
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"SELECTED!!!!!");
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSLog(@"VIEW CONTROLLER: %@", viewController);
    NSLog(@"SELECTED VIEW CONTROLLER:%@", tabBarController.selectedViewController);
    NSLog(@"SELECTED INDEX: %d", (int)tabBarController.selectedIndex);
    
    //return viewController != tabBarController.selectedViewController;
    if(TAB_NOTIFICATIONS_INDEX>=0){
        UIViewController *notificationsViewController = [tabBarController.viewControllers objectAtIndex:TAB_NOTIFICATIONS_INDEX];
        if ( (viewController == notificationsViewController) &&  (viewController == tabBarController.selectedViewController) ) {
            return false;
        }
    }
    return true;
}

-(void)initializeLocation {
    NSLog(@"INITIALIZING LOCATION!");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    
    if (self.locationManager.location) {
        self.applicationContext.lastLocation = self.locationManager.location;
        self.applicationContext.searchLocation = self.locationManager.location;
    }
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // low power
    // Once configured, the location manager must be "started".
    NSLog(@"significantLocationChangeMonitoringAvailable? %d", [CLLocationManager significantLocationChangeMonitoringAvailable]);
    [self enableLocationServices];
}

-(void)initUser {
    SHPUser *user = [SHPAuth restoreSavedUser];
    if (user) {
        self.applicationContext.loggedUser = user;
    } else {
        self.applicationContext.loggedUser = nil;
    }
}

-(void)disableLocationServices {
    NSLog(@"Disabling location services...");
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    } else {
        [self.locationManager stopUpdatingLocation];
    }
}

static NSString *TIMED_OUT_STATE = @"LocationManager timed out";
static NSString *UPDATED_STATE = @"LocationManager updated";
static float UPDATE_LOCATION_TIMEOUT = 60.0; // 1 min
static float UPDATE_LOCATION_REFRESH_DELAY = 300.0; // 5 min
static float UPDATE_LOCATION_DELAY_AFTER_TIMEOUT_OR_ERROR = 180.0; // 3 min


-(void)enableLocationServices {
    NSLog(@"Enabling location services...");
    NSLog(@"locationManager %@", self.locationManager);
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        NSLog(@"significantLocationChangeMonitoringAvailable: yes");
        [self.locationManager startMonitoringSignificantLocationChanges];
    } else {
        NSLog(@"significantLocationChangeMonitoringAvailable: no");
        NSLog(@"Using [CLLocationManager startUpdatingLocation]");
        [self startLocationManager];
    }
}

-(void)startLocationManager {
    [self.locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:TIMED_OUT_STATE afterDelay:UPDATE_LOCATION_TIMEOUT];
}

// ******** LOCATION SERVICES ********

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //    NSLog(@"APP >> Notified location %@", newLocation);
    self.applicationContext.lastLocation = newLocation;
    [self stopUpdatingLocation:UPDATED_STATE];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location Manager error: %@", error);
    // after timeout start monitoring again after a delay
    [self performSelector:@selector(startLocationManager) withObject:nil afterDelay:UPDATE_LOCATION_DELAY_AFTER_TIMEOUT_OR_ERROR];
}

- (void)stopUpdatingLocation:(NSString *)state {
    //    NSLog(@"Location State: %@", state);
    //    NSLog(@"stopUpdatingLocation!");
    if ([state isEqualToString:TIMED_OUT_STATE]) {
        //        NSLog(@"Location Manager timed out.");
        // after timeout start monitoring again after a delay
        [self performSelector:@selector(startLocationManager) withObject:nil afterDelay:UPDATE_LOCATION_DELAY_AFTER_TIMEOUT_OR_ERROR];
        return;
    }
    [self.locationManager stopUpdatingLocation];
    [self performSelector:@selector(startLocationManager) withObject:nil afterDelay:UPDATE_LOCATION_REFRESH_DELAY];
}

// **** APP DELEGATES ****

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"App >> applicationWillResignActive...");
    [self disableLocationServices];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"App >> applicationDidEnterBackground...");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"App >> applicationWillEnterForeground...");
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"App >> applicationDidBecomeActive...");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // http://stackoverflow.com/questions/4443817/how-to-know-when-a-uiviewcontroller-view-is-shown-after-being-in-the-background
    
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navc = (UINavigationController *)[tabController selectedViewController];
    UIViewController *topvc = [navc topViewController];
    if ([topvc respondsToSelector:@selector(viewControllerDidBecomeActive)]) {
        [topvc performSelector:@selector(viewControllerDidBecomeActive)];
    }
    
    [self enableLocationServices];
    
    // #notificationworkflow
    // Note: every time the application became active it attempts a new
    // device registration to APN (if a previous one was failed)
    if (!self.deviceToken) {
        [self registerToAPN];
    } else {
        [self sendDeviceTokenToProvider:self.deviceToken];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"App >> applicationWillTerminate...");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"App >> applicationDidReceiveMemoryWarning. Caches empting...");
    [self.applicationContext.productDetailImageCache empty];
    [self.applicationContext.mainListImageCache empty];
    [self.applicationContext.smallImagesCache empty];
    [self.applicationContext.categoryIconsCache empty];
}


// FACEBOOK


//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation
//{
//    NSLog(@"Facebook app callback");
//    return [FBSession.activeSession handleOpenURL:url];
//}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//
//    BOOL wasHandled = [FBAppCall handleOpenURL:url
//                             sourceApplication:sourceApplication];
//
//    // add app-specific handling code here
//    return wasHandled;
//}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}




-(NSString*) machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

//- (NSString *)getModel {
//    size_t size;
//    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
//    char *model = malloc(size);
//    sysctlbyname("hw.machine", model, &size, NULL, 0);
//    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
//    free(model);
//    if ([sDeviceModel isEqual:@"i386"])      return @"Simulator";  //iPhone Simulator
//    if ([sDeviceModel isEqual:@"iPhone1,1"]) return @"iPhone1G";   //iPhone 1G
//    if ([sDeviceModel isEqual:@"iPhone1,2"]) return @"iPhone3G";   //iPhone 3G
//    if ([sDeviceModel isEqual:@"iPhone2,1"]) return @"iPhone3GS";  //iPhone 3GS
//    if ([sDeviceModel isEqual:@"iPhone3,1"]) return @"iPhone4 AT&T";  //iPhone 4 - AT&T
//    if ([sDeviceModel isEqual:@"iPhone3,2"]) return @"iPhone4 Other";  //iPhone 4 - Other carrier
//    if ([sDeviceModel isEqual:@"iPhone3,3"]) return @"iPhone4";    //iPhone 4 - Other carrier
//    if ([sDeviceModel isEqual:@"iPhone4,1"]) return @"iPhone4S";   //iPhone 4S
//    if ([sDeviceModel isEqual:@"iPhone5,1"]) return @"iPhone5";    //iPhone 5 (GSM)
//    if ([sDeviceModel isEqual:@"iPod1,1"])   return @"iPod1stGen"; //iPod Touch 1G
//    if ([sDeviceModel isEqual:@"iPod2,1"])   return @"iPod2ndGen"; //iPod Touch 2G
//    if ([sDeviceModel isEqual:@"iPod3,1"])   return @"iPod3rdGen"; //iPod Touch 3G
//    if ([sDeviceModel isEqual:@"iPod4,1"])   return @"iPod4thGen"; //iPod Touch 4G
//    if ([sDeviceModel isEqual:@"iPad1,1"])   return @"iPadWiFi";   //iPad Wifi
//    if ([sDeviceModel isEqual:@"iPad1,2"])   return @"iPad3G";     //iPad 3G
//    if ([sDeviceModel isEqual:@"iPad2,1"])   return @"iPad2";      //iPad 2 (WiFi)
//    if ([sDeviceModel isEqual:@"iPad2,2"])   return @"iPad2";      //iPad 2 (GSM)
//    if ([sDeviceModel isEqual:@"iPad2,3"])   return @"iPad2";      //iPad 2 (CDMA)
//
//    NSString *aux = [[sDeviceModel componentsSeparatedByString:@","] objectAtIndex:0];
//
//    //If a newer version exist
//    if ([aux rangeOfString:@"iPhone"].location!=NSNotFound) {
//        int version = [[aux stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] intValue];
//        if (version == 3) return @"iPhone4";
//        if (version >= 4) return @"iPhone4s";
//
//    }
//    if ([aux rangeOfString:@"iPod"].location!=NSNotFound) {
//        int version = [[aux stringByReplacingOccurrencesOfString:@"iPod" withString:@""] intValue];
//        if (version >=4) return @"iPod4thGen";
//    }
//    if ([aux rangeOfString:@"iPad"].location!=NSNotFound) {
//        int version = [[aux stringByReplacingOccurrencesOfString:@"iPad" withString:@""] intValue];
//        if (version ==1) return @"iPad3G";
//        if (version >=2) return @"iPad2";
//    }
//    //If none was found, send the original string
//    return sDeviceModel;
//}


@end
