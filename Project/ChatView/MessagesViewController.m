//
//  MessagesViewController.m
//  Soleto
//
//  Created by Andrea Sponziello on 26/11/14.
//
//

#import "MessagesViewController.h"
#import "ChatMessage.h"
#import "SHPUser.h"
#import "ChatUtil.h"
#import "ChatDB.h"
#import "ChatConversation.h"
#import "SHPApplicationContext.h"
#import "ChatManager.h"
#import "ChatConversationHandler.h"
#import "SHPConversationsVC.h"
#import "SHPImageDownloader.h"
#import "SHPImageUtil.h"
#import "SHPStringUtil.h"
#import "GroupInfoVC.h"
#import "QBPopupMenu.h"
#import "QBPopupMenuItem.h"
#import "SHPHomeProfileTVC.h"
#import "ChatTitleVC.h"
#import "ChatImageCache.h"
#import "ChatImageWrapper.h"

@interface MessagesViewController () {
    SystemSoundID soundID;
}
@end

@implementation MessagesViewController

int MAX_WIDTH_TEXTCHAT = 230;//250.0;
int WIDTH_BOX_DATE = 50.0;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Loading messages...");
    NSLog(@"tableView: %@", self.tableView);
    keyboardShow = NO;//GESTIONE KEYBOARD
    //previewData = [NSDate date];//ISTANZIO DATA PREVIEW
    // GROUP_MOD
    if (self.recipient) {
        [self customizeTitle:self.recipient];
    } else {
        NSString *title = [[NSString alloc] initWithFormat:@"%@ (gruppo)", self.groupName];
        [self customizeTitle:title];
    }
    self.tabBarController.tabBar.hidden=YES;
    // init UI
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    SHPUser *me = self.applicationContext.loggedUser;
    self.senderId = me.username;
    [self registerForKeyboardNotifications];
    [self backgroundTapToDismissKB:YES];
    
    [self initConversationHandler];
    originalViewHeight = self.view.bounds.size.height;
    heightTable = 0;// self.tableView.bounds.size.height;
    
    self.bottomReached = YES; // TODO
    
    // MENU
////**    [self mainMenu];
////**    [self photoMenu];
    [self setupLabels];
    [self initImageCache];
    [self popUpMenu];
    [self buildUnreadBadge];
    [self setupConnectionStatus];
    
//    [self testConnection];
}

-(void)setupLabels {
    [self.sendButton setTitle:NSLocalizedString(@"ChatSend", nil) forState:UIControlStateNormal];
}

// DEBUG ONLY!
-(void)testConnection {
    NSLog(@"IT'S SO EASY TO TEST A CONNECTION! :) SO...LET'S TEST! SETTING UP CONNECTION TEST.");
    
    float lasttime = [[NSDate alloc] init].timeIntervalSince1970;
    NSLog(@"LASTTIME: %f", lasttime);
    Firebase *messagesRef = [ChatUtil conversationMessagesRef:self.conversationId];
    [[[messagesRef queryOrderedByChild:@"timestamp"] queryStartingAtValue:@(lasttime)] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"xxxxxxxxx TEST CHILD ADDED %@\n", snapshot);
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)initImageCache {
    // cache setup
    self.imageCache = (ChatImageCache *) [self.applicationContext getVariable:@"chatUserIcons"];
    if (!self.imageCache) {
        self.imageCache = [[ChatImageCache alloc] init];
        self.imageCache.cacheName = @"chatUserIcons";
        // test
        // [self.imageCache listAllImagesFromDisk];
        // [self.imageCache empty];
        [self.applicationContext setVariable:@"chatUserIcons" withValue:self.imageCache];
    }
}

-(void)setupConnectionStatus {
    ChatManager *chat = [ChatManager getSharedInstance];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/.info/connected", chat.firebaseRef];
    self.connectedRef = [[Firebase alloc] initWithUrl:url];
    self.connectedRefHandle = [self.connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if([snapshot.value boolValue]) {
            NSLog(@"connected");
            self.usernameButton.hidden = NO;
            self.activityIndicator.hidden = YES;
            self.sendButton.enabled = YES;
            [self.activityIndicator stopAnimating];
            self.statusLabel.text = NSLocalizedString(@"ChatConnected", nil);
        } else {
            NSLog(@"not connected");
            self.usernameButton.hidden = YES;
            self.activityIndicator.hidden = NO;
            self.sendButton.enabled = NO;
            [self.activityIndicator startAnimating];
            self.statusLabel.text = NSLocalizedString(@"ChatDisconnected", nil);
        }
    }];
}

-(void)buildUnreadBadge {
    self.unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 4, 16, 16)];
    [self.unreadLabel setBackgroundColor:[UIColor redColor]];
    [self.unreadLabel setTextColor:[UIColor whiteColor]];
    self.unreadLabel.font = [UIFont systemFontOfSize:11];
    self.unreadLabel.textAlignment = NSTextAlignmentCenter;
    self.unreadLabel.layer.masksToBounds = YES;
    self.unreadLabel.layer.cornerRadius = 8.0;
    [self.navigationController.navigationBar addSubview:self.unreadLabel];
    self.unreadLabel.hidden = YES;
}

-(void)updateUnreadMessagesCount {
    if (self.unread_count > 0) {
        self.unreadLabel.hidden = NO;
        self.unreadLabel.text = [[NSString alloc] initWithFormat:@"%d", self.unread_count];
    } else {
        self.unreadLabel.hidden = YES;
    }
    
    // Get the previous view controller
//    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
//    NSLog(@"previous %@", previousVC);
//    NSString *__count = [[NSString alloc] initWithFormat:@"Chat (%d)", count];
//    
//    UIBarButtonItem *__backButton = [[UIBarButtonItem alloc]
//                                     initWithTitle:__count
//                                     style:UIBarButtonItemStylePlain
//                                     target:previousVC
//                                     action:@selector(backButtonClicked:)];
//    previousVC.navigationItem.backBarButtonItem = __backButton;
}

-(void)removeUnreadBadge {
    NSLog(@"Removing unread label... %@", self.unreadLabel);
    [self.unreadLabel removeFromSuperview];
}

-(void)customizeTitle:(NSString *)title {
    self.navigationItem.title = title;
    
//    NSDictionary<NSString *,id> *attrs = self.navigationController.navigationBar.titleTextAttributes;
//    NSLog(@"attrs: %@", attrs);
//    //output
//    {
//        NSColor = "UIDeviceRGBColorSpace 0.121569 0.121569 0.678431 1";
//        NSFont = "<UICTFont: 0x100e671b0> font-family: \"PingFangTC-Light\"; font-weight: normal; font-style: normal; font-size: 17.00pt";
//        NSShadow = "NSShadow {1, 0} color = {(null)}";
//    }
    
//    UILabel *navTitleView = [[UILabel alloc] init];
//    navTitleView.text = title;
//    navTitleView.numberOfLines = 1;
//    navTitleView.font = [attrs objectForKey:@"NSFont"];
//    //navTitleLabel.font = [UIFont systemFontOfSize:20.0]; // boldSystemFontOfSize
//    navTitleView.backgroundColor = [UIColor blackColor];
//    navTitleView.shadowColor = [UIColor clearColor]; //[UIColor colorWithWhite:0.0 alpha:0.5];
//    navTitleView.textAlignment = NSTextAlignmentCenter;
//    navTitleView.textColor = [attrs objectForKey:@"NSColor"];
//    [navTitleView sizeToFit];
//    
//    // tap
    //    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToProfile)];
//    tapGest.cancelsTouchesInView = YES;// without this, tap on buttons is captured by the view
//    [navTitleView addGestureRecognizer:tapGest];

    
    
    
    // VISTA
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    ChatTitleVC *vc = [mystoryboard instantiateViewControllerWithIdentifier:@"ChatTitle"];
    UIView *view = vc.view;
//    [view sizeToFit];
//    float alertHeight = 30;
//    CGRect f = view.frame;
    view.frame = CGRectMake(0, 0, 200, 40);
    NSLog(@"w %f h %f", view.frame.size.width, view.frame.size.height);
    NSLog(@"vc.usernameButton %@ title %@", vc.usernameButton, title);
    [vc.usernameButton setTitle:title forState:UIControlStateNormal];
    [vc.usernameButton addTarget:self
               action:@selector(goToProfile:)
     forControlEvents:UIControlEventTouchUpInside];
    self.usernameButton = vc.usernameButton;
    self.statusLabel = vc.statusLabel;
    self.activityIndicator = vc.activityIndicator;
    self.navigationItem.titleView = vc.view;
    // FINE VISTA
    
//    // BOTTONE ORIGINALE
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:title forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blueColor]
//                       forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    [button sizeToFit];
//    [button addTarget:self
//               action:@selector(goToProfile:)
//     forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.titleView = button;
//    // FINE BOTTONE
    
    
    
    // back button
//    [self backButtonSetup];
    
}


//-(void)backButtonSetup {
//    if (!self.backButton) {
//        self.backButton = [[UIBarButtonItem alloc]
//                           initWithTitle:@"Messaggi"
//                           style:UIBarButtonItemStylePlain
//                           target:self
//                           action:@selector(backButtonClicked:)];
//    }
//    self.navigationItem.backBarButtonItem = self.backButton;
//}

//-(void)backButtonClicked:(UIBarButtonItem*)sender
//{
//    NSLog(@"..Back");
//    [self.navigationController popViewControllerAnimated:YES];
//}
-(void)chatTitleButtonPressed {
    NSLog(@"title button pressed");
}

-(void)goToProfile:(UIButton*)sender {
    //NSLog(@"goToProfile");
//    self.profileVC = (SHPHomeProfileTVC *)[self.applicationContext getVariable:@"profileVC"];
    
    if (self.groupId) {
        [self performSegueWithIdentifier:@"GroupInfo" sender:self];
    } else {
        if (!self.profileVC) {
            self.profileSB = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            self.profileNC = [self.profileSB instantiateViewControllerWithIdentifier:@"navigationProfile"];
            self.profileVC = (SHPHomeProfileTVC *)[[self.profileNC viewControllers] objectAtIndex:0];
    //        [self.applicationContext setVariable:@"profileVC" withValue:self.profileVC];
        }
        NSLog(@"storyb -------------->>>>>> %@", self.profileSB);
        NSString *username = self.recipient;
        self.profileVC.applicationContext = self.applicationContext;
        SHPUser *authorProfile = [[SHPUser alloc] init];
        authorProfile.username = username;
//        self.profileVC.user = authorProfile;
        self.profileVC.otherUser = authorProfile;
        [self.navigationController pushViewController:self.profileVC animated:YES];
    }
}

//-(void)goToProfile:(UIButton*)sender {
//    //NSLog(@"goToProfile");
//    NSString *username = self.recipient;
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
//    UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"navigationProfile"];
//    SHPHomeProfileTVC *VC = (SHPHomeProfileTVC *)[[nc viewControllers] objectAtIndex:0];
//    VC.applicationContext = self.applicationContext;
//    SHPUser *authorProfile = [[SHPUser alloc] init];
//    authorProfile.username = username;
////    authorProfile.photoImage = self.userImage;
//    VC.user = authorProfile;
//    [self.navigationController pushViewController:VC animated:YES];
//    //[self performSegueWithIdentifier: @"toProfile" sender: self];
//}

-(void)popUpMenu {
//    QBPopupMenuItem *itemCopy = [QBPopupMenuItem itemWithTitle:@"Copicchia" target:self action:@selector(copicchia:)];
//    //        QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithImage:[UIImage imageNamed:@"image"] target:self action:@selector(action:)];
//    self.popupMenu = [[QBPopupMenu alloc] initWithItems:@[itemCopy]];
    
    QBPopupMenuItem *item_copy = [QBPopupMenuItem itemWithTitle:@"Copia" target:self action:@selector(copy_action:)];
    QBPopupMenuItem *item_resend = [QBPopupMenuItem itemWithTitle:@"Copia" target:self action:@selector(resend_action:)];
    QBPopupMenuItem *item_delete = [QBPopupMenuItem itemWithTitle:@"Copia" target:self action:@selector(delete_action:)];
    
//    QBPopupMenuItem *item5 = [QBPopupMenuItem itemWithImage:[UIImage imageNamed:@"clip"] target:self action:@selector(action)];
//    QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:@"Delete" image:[UIImage imageNamed:@"trash"] target:self action:@selector(action)];
    NSArray *items = @[item_copy];
    
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
    popupMenu.height = 30;
    popupMenu.navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    popupMenu.statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    popupMenu.delegate = self;
    self.popupMenu = popupMenu;
}

-(void)popupMenuDidDisappear:(QBPopupMenu *)menu {
    [self backgroundTapToDismissKB:YES];
}

-(void)copy_action:(id)sender {
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    generalPasteboard.string = self.selectedText;
    NSLog(@"Text copied!");
}

- (void)longPressOnCellGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    NSLog(@"LONG PRESS!!!!!");
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Action");
        [self showCustomPopupMenu:recognizer];
    }
}

-(void)showCustomPopupMenu:(UIGestureRecognizer *)recognizer {
    CGPoint pressLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *pressIndexPath = [self.tableView indexPathForRowAtPoint:pressLocation];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:pressIndexPath];
    UILabel *message_label = (UILabel *)[cell viewWithTag:3];
    self.selectedText = message_label.text;
    UIView *sfondo_cella = (UIView *)[cell viewWithTag:100];
    NSLog(@"msg: %@", message_label.text);
    CGFloat abs_x = sfondo_cella.frame.origin.x + cell.frame.origin.x + self.view.frame.origin.x; // l'ultimo è zero
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:pressIndexPath];
    CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
    CGFloat abs_y = rectInSuperview.origin.y + sfondo_cella.frame.origin.y;
    NSLog(@"abs_y %f", abs_y);
    // absolute to view, not tableView
    CGRect absolute_to_view_rect = CGRectMake(abs_x, abs_y, message_label.frame.size.width, message_label.frame.size.height);
    // disable keyboard's gesture recognizer
    [self backgroundTapToDismissKB:NO];
    [self.popupMenu showInView:self.tableView targetRect:absolute_to_view_rect animated:YES];
    // test
//    CGRect targetRect = absolute_to_view_rect;
//    UIView *targetV = [[UIView alloc] initWithFrame:targetRect];
//    [targetV setBackgroundColor:[UIColor blueColor]];
    NSLog(@"VIEW %@", self.view);
    NSLog(@"TABLEVIEW %@", self.tableView);
//    [self.view addSubview:targetV];
//    [self.view addSubview:targetV];
//    NSLog(@"frame %f %f %f %f", targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height);
//    CGRect targetRect2 = CGRectMake(44, 268, 100, 40);
//    UIView *targetV2 = [[UIView alloc] initWithFrame:targetRect2];
//    [targetV2 setBackgroundColor:[UIColor redColor]];
//    [self.tableView addSubview:targetV2];
    // test end
}

//-(void)mainMenu {
//    // init the action menu
//    NSString *groupInfoButtonTitle = nil;
//    if (self.groupId) {
//        NSLog(@"MENU GROUP ON...");
//        if (self.groupId) {
//            groupInfoButtonTitle = @"Info gruppo";
//        }
//    }
//    //    else {
//    //        NSLog(@"MENU OFF");
//    //        self.menuButton.enabled = NO;
//    //        self.menuButton.tintColor = [UIColor clearColor];
//    //    }
//    NSString *sendImageButtonTitle = @"Invia immagine";
//    if (groupInfoButtonTitle) {
//        self.menuSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:groupInfoButtonTitle, sendImageButtonTitle, nil];
//    }
//    else {
//        self.menuSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:sendImageButtonTitle, nil];
//    }
//    self.menuSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//    
//    self.menuButton.enabled = YES;
//    self.menuButton.tintColor = nil;
//}
//
//-(void)photoMenu {
//    // init the photo action menu
//    NSString *takePhotoButtonTitle = @"Scatta foto";
//    NSString *chooseExistingButtonTitle = @"Scegli dalla galleria";
//    
//    self.photoMenuSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:takePhotoButtonTitle, chooseExistingButtonTitle, nil];
//    self.photoMenuSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    [self updateUnreadMessagesCount];
    if (self.textToSendAsChatOpens) {
        [self sendMessage:self.textToSendAsChatOpens];
        self.textToSendAsChatOpens = nil;
        [self.messageTextField becomeFirstResponder];
    }
}

// TIP: why this method? http://www.yichizhang.info/2015/03/02/prescroll-a-uitableview.html
-(void)viewDidLayoutSubviews {
    NSLog(@"DID LAYOUT SUBVIEWS");
    [super viewDidLayoutSubviews];
    [self scrollToLastMessage:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"VIEW WILL DISAPPEAR...");
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
    [self removeUnreadBadge];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    if (self.isMovingFromParentViewController) {
        NSLog(@"isMovingFromParentViewController: OK");
        self.navigationItem.titleView = nil;
        self.tabBarController.tabBar.hidden=NO;
        self.conversationHandler.delegateView = nil;
        [self.conversationsVC resetCurrentConversation];
        self.conversationsVC = nil;
        for (NSString *k in self.imageDownloadsInProgress) {
            NSLog(@"Removing downloader: %@", k);
            SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:k];
            [iconDownloader cancelDownload];
            iconDownloader.delegate = nil;
        }
        [self.connectedRef removeObserverWithHandle:self.connectedRefHandle];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

-(void)initConversationHandler {
    ChatManager *chat = [ChatManager getSharedInstance];
    ChatConversationHandler *handler = [chat getConversationHandlerByConversationId:self.conversationId];
    if (!handler) {
        NSLog(@"Conversation Handler not found. Creating & initializing a new one with conv-id %@", self.conversationId);
        // GROUP_MOD
        if (self.recipient) {
            handler = [[ChatConversationHandler alloc] initWithRecipient:self.recipient conversationId:self.conversationId user:self.applicationContext.loggedUser];
        } else {
            NSLog(@"*** CONVERSATION HANDLER IN GROUP MOD!!!!!!!");
            handler = [[ChatConversationHandler alloc] initWithGroupId:self.groupId conversationId:self.conversationId user:self.applicationContext.loggedUser];
        }
        
        [chat addConversationHandler:handler];
        handler.delegateView = self;
        self.conversationHandler = handler;
        
        // db
        NSLog(@"Restoring DB archived conversations.");
        [self.conversationHandler restoreMessagesFromDB];
        NSLog(@"Archived messages count %lu", (unsigned long)self.conversationHandler.messages.count);
        
        NSLog(@"Connecting handler to firebase.");
        [self.conversationHandler connect];
        NSLog(@"Handler ref: %@", handler.messagesRef);
        NSLog(@"Adding new handler %@ to Conversations Manager.", handler);
    } else {
        handler.delegateView = self;
        self.conversationHandler = handler;
    }
}


-(void)didFinishInitConversationHandler:(ChatConversationHandler *)handler error:(NSError *)error {
    if (!error) {
        NSLog(@"ChatConversationHandler Initialization finished with success.");
    } else {
        NSLog(@"ChatConversationHandler Initialization finished with error: %@", error);
    }
}

//************************************************//
//INIZIO GESTIONE KEYBOARD
//************************************************//
-(void)backgroundTapToDismissKB:(BOOL)activated
{
    if (activated) {
        if (!self.tapToDismissKB) {
            self.tapToDismissKB = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
            self.tapToDismissKB.cancelsTouchesInView = YES;// without this, tap on buttons is captured by the view
        }
        [self.view addGestureRecognizer:self.tapToDismissKB];
    } else if (self.tapToDismissKB) {
        [self.view removeGestureRecognizer:self.tapToDismissKB];
    }
    
}

-(void)dismissKeyboard {
//    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown %ld",self.messageTextField.autocorrectionType);
    NSLog(@"Content Size: %f", self.tableView.contentSize.height);
    if(keyboardShow == NO){
        NSLog(@"KEYBOARD-SHOW == NO!");
        CGFloat content_h = self.tableView.contentSize.height;
        
        NSDictionary* info = [aNotification userInfo];
        NSTimeInterval animationDuration;
        UIViewAnimationCurve animationCurve;
        CGRect keyboardFrame;
        [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
        [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
        
        CGFloat viewport_h_with_kb = self.view.frame.size.height - keyboardFrame.size.height;
        CGFloat navbar_h = 64.0;
        CGFloat textbox_h = 44.0;
        CGFloat messages_viewport_h_with_kb = viewport_h_with_kb - navbar_h - textbox_h;
        //CGFloat viewport_final_h = viewport_h_with_kb;
        
        
        /////
        NSLog(@"ANIMATING...");
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:animationDuration animations:^{
            self.layoutContraintBottomBarMessageBottomView.constant = keyboardFrame.size.height;
            [self.view layoutIfNeeded];
        }];
        /////
        
        if (content_h > messages_viewport_h_with_kb) {
           if (self.bottomReached) {
                [self scrollToLastMessage:YES];
            }
        }
        keyboardShow = YES;
    }
    else {
        NSLog(@"Suggestion hide/show");
        NSLog(@"KEYBOARD-SHOW == YES!");
        //START apertura e chiusura suggerimenti keyboard
        NSDictionary* info = [aNotification userInfo];
        CGRect keyboardFrame;
        [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
        CGFloat beginHeightKeyboard = keyboardFrame.size.height;
        NSLog(@"Keyboard info1 %f",beginHeightKeyboard);
        [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        CGFloat endHeightKeyboard = keyboardFrame.size.height;
        NSLog(@"Keyboard info2 %f",endHeightKeyboard);
        CGFloat difference = beginHeightKeyboard-endHeightKeyboard;

        NSLog(@"Difference: %f", difference);
        NSTimeInterval animationDuration;
        CGFloat viewport_h_with_kb = self.view.frame.size.height + difference;
        CGFloat viewport_final_h = viewport_h_with_kb;
        
        /////
        NSLog(@"ANIMATING...");
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:animationDuration animations:^{
            self.layoutContraintBottomBarMessageBottomView.constant = keyboardFrame.size.height;
            [self.view layoutIfNeeded];
        }];
        /////
    }
    
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"KEYBOARD HIDING...");
    NSDictionary* info = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    //START ANIMATION VIEW
    /////
    NSLog(@"ANIMATING...");
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:animationDuration animations:^{
        self.layoutContraintBottomBarMessageBottomView.constant = 0;
        [self.view layoutIfNeeded];
    }];
    /////
    keyboardShow = NO;
    //END ANIMATION VIEW

}
//************************************************//
//FINE GESTIONE KEYBOARD
//************************************************//

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *messages = self.conversationHandler.messages;
    NSInteger rows_count = 1;
    if (messages) {
        rows_count = messages.count;
    }
    return rows_count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 50;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *messages = self.conversationHandler.messages;
    ChatMessage *previousData;
    ChatMessage *message = (ChatMessage *)[messages objectAtIndex:indexPath.row];
    int numberDaysLastChat = 0;
    
    if(indexPath.row>0){
        previousData = (ChatMessage *)[messages objectAtIndex:indexPath.row-1];
        numberDaysLastChat = (int)[SHPStringUtil daysBetweenDate:previousData.date andDate:message.date];
    }
    //previewData = message.date;
    CGSize maxSize = CGSizeMake(MAX_WIDTH_TEXTCHAT, 99999);
    CGRect labelRect = [message.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    int dimCell = 8+labelRect.size.height+14;//19 testo - 31 nuvola - 14 margine
    
    if(![message.sender isEqualToString:previousData.sender] && numberDaysLastChat<=0){
        dimCell = dimCell+7;
        if(dimCell<40){
            dimCell=40;
        }
    }
    if(dimCell<33){
        dimCell=33;
    }
    if(numberDaysLastChat>0 || indexPath.row==0){
        dimCell +=34;
    }
    heightTable +=dimCell;
    
    //NSLog(@"************* dimCell - %ld :: %d :: %d",(long)indexPath.row ,dimCell, numberDaysLastChat);
    //NSLog(@"************* dimCell:: %d MESSAGGIO - %@",dimCell,message.text);
    return (dimCell);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *messageCellLeft = @"CellChatLeft";//messageCell
    static NSString *messageCellLeftWithSpace = @"CellChatLeftWithSpace";//messageCell
    static NSString *messageCellLeftWithDate = @"CellChatLeftWithDate";//messageCell
    static NSString *messageCellRight = @"CellChatRight";//messageCell
    static NSString *messageCellRightWithSpace = @"CellChatRightWithSpace";//messageCell
    static NSString *messageCellRightWithDate = @"CellChatRightWithDate";//messageCell
    static NSString *noMessagesCell = @"noMessagesCell";
//    static NSString *loadingCell = @"loadingCell";
    
    NSDate *dateToday = [NSDate date];//ISTANZIO DATA PREVIEW
    UIColor *colorCloud;
    UIColor *messageColor;
    UITableViewCell *cell;
    int numberDaysPrevChat = 0;
    int numberDaysNextChat = 0;
    NSString *dateChat;
    ChatMessage *message;
    ChatMessage *previousMessage;
    ChatMessage *nextMessage;
    
    NSArray *messages = self.conversationHandler.messages;
    if (messages && messages.count > 0) {
        message = (ChatMessage *)[messages objectAtIndex:indexPath.row];
        if(indexPath.row>0){
            previousMessage = (ChatMessage *)[messages objectAtIndex:(indexPath.row-1)];
            if(messages.count > (indexPath.row+1)){
                nextMessage = (ChatMessage *)[messages objectAtIndex:(indexPath.row+1)];
                numberDaysNextChat = (int)[SHPStringUtil daysBetweenDate:message.date andDate:nextMessage.date];
            }
            numberDaysPrevChat = (int)[SHPStringUtil daysBetweenDate:previousMessage.date andDate:message.date];
            //NSLog(@"N GIORNI :::: %d - TRA %@ E %@",numberDaysPrevChat,previousMessage.date ,message.date);
            dateChat = [self formatDateMessage:numberDaysPrevChat message:message row:indexPath.row];
        }else{
            numberDaysPrevChat = (int)[SHPStringUtil daysBetweenDate:message.date andDate:dateToday];
            //NSLog(@"N GIORNI :::: %d - TRA %@ E %@",numberDaysPrevChat,dateToday ,message.date);
            dateChat = [self formatDateMessage:numberDaysPrevChat message:message row:indexPath.row];
        }
        
        if ([message.sender isEqualToString:self.senderId]) {
            messageColor = [UIColor whiteColor];
            if(numberDaysPrevChat>0 || indexPath.row==0){
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellRightWithDate forIndexPath:indexPath];
            }
            else if(![previousMessage.sender isEqualToString:self.senderId] && previousMessage.sender){
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellRightWithSpace forIndexPath:indexPath];
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellRight forIndexPath:indexPath];
            }
            
            colorCloud = [SHPImageUtil colorWithHexString:@"0F96FF"];
        } else {
            messageColor = [UIColor darkGrayColor];
            if(numberDaysPrevChat>0 || indexPath.row==0){
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellLeftWithDate forIndexPath:indexPath];
            }
            else if([previousMessage.sender isEqualToString:self.senderId] && previousMessage.sender){
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellLeftWithSpace forIndexPath:indexPath];
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellLeft forIndexPath:indexPath];
            }
            colorCloud = [SHPImageUtil colorWithHexString:@"EDECEC"];//cfdcfc
        }
        
        UILabel *day_label = (UILabel *)[cell viewWithTag:200];
        UILabel *message_view = (UILabel *)[cell viewWithTag:3];
        
        UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnCellGestureRecognizer:)];
        [message_view addGestureRecognizer:gestureRecognizer];
        message_view.userInteractionEnabled = YES;
        
        
        UILabel *time_label = (UILabel *)[cell viewWithTag:4];
        UIView *sfondo = (UIView *)[cell viewWithTag:100];
        
        //-----------------------------------------------------------//
        //START IMAGE CELL MESSAGE
        //-----------------------------------------------------------//
        UIImageView *recipient_thumb = (UIImageView *)[cell viewWithTag:10];
        recipient_thumb.hidden = YES;
        if(![message.sender isEqualToString:self.senderId] && (![message.sender isEqualToString:nextMessage.sender] || numberDaysPrevChat>0)) {
           recipient_thumb.hidden = NO;
//            NSString *imageURL = [SHPUser photoUrlByUsername:message.sender];
//            UIImage *cached_image = [self.applicationContext.smallImagesCache getImage:imageURL];
//            if(!cached_image) {
//                [self startIconDownload:message.sender forIndexPath:indexPath];
//            } else {
//                recipient_thumb.image = cached_image;
//            }
            
            NSString *imageURL = [SHPUser photoUrlByUsername:message.sender];
            ChatImageWrapper *cached_image_wrap = (ChatImageWrapper *)[self.imageCache getImage:imageURL];
            UIImage *user_image = cached_image_wrap.image;
            if(!cached_image_wrap) {
                // if a download is deferred or in progress, return a placeholder image
                UIImage *circled = [SHPImageUtil circleImage:[UIImage imageNamed:@"avatar"]];
                recipient_thumb.image = circled;
            } else {
                recipient_thumb.image = [SHPImageUtil circleImage:user_image];
            }
            
        }
        //-----------------------------------------------------------//
        //END IMAGE CELL MESSAGE
        //-----------------------------------------------------------//
        message_view.text = message.text;
        [message_view sizeToFit];
        if(numberDaysPrevChat>0 || indexPath.row==0){
            day_label.text = dateChat;
        }
        sfondo.backgroundColor = colorCloud;
        [self customRoundImage:sfondo];
        [sfondo sizeToFit];
        
        //-----------------------------------------------------------//
        //START CUSTOM CORNER RADIUS CELL MESSAGE
        //-----------------------------------------------------------//
        UIView *borderTR = (UIView *)[cell viewWithTag:101];
        UIView *borderBR = (UIView *)[cell viewWithTag:102];
        [borderTR setHidden:YES];
        [borderBR setHidden:YES];
        //NSLog(@"ndpc: %d - ndnc: %d - ns: %@ - pms: %@ - nms: %@",numberDaysPrevChat,numberDaysNextChat,message.sender,previousMessage.sender,nextMessage.sender);
        //set border TR
        if(numberDaysPrevChat==0 && [message.sender isEqualToString:previousMessage.sender]){
            [self customcornerRadius:borderTR cornerRadius:4.0];
            borderTR.backgroundColor = colorCloud;
            [borderTR setHidden:NO];
        }
        //set border BR
        if(numberDaysNextChat==0 && [message.sender isEqualToString:nextMessage.sender]){
            [self customcornerRadius:borderBR cornerRadius:4.0];
            borderBR.backgroundColor = colorCloud;
            [borderBR setHidden:NO];
        }
        //-----------------------------------------------------------//
        //END CUSTOM CORNER RADIUS CELL MESSAGE
        //-----------------------------------------------------------//
        
        
        //-----------------------------------------------------------//
        //START STATE MESSAGE
        //-----------------------------------------------------------//
//        UIImageView *me_thumb = (UIImageView *)[cell viewWithTag:11];
//        NSLog(@"RENDERING MESSAGE sender:%@ recipient:%@ text:%@ id/key:%@",message.sender, message.recipient, message.text, message.messageId);
        time_label.text = [message dateFormattedForListView];
        message_view.textColor = messageColor;
        
        UIImageView *status_image_view = (UIImageView *)[cell viewWithTag:22];
        switch (message.status) {
            case MSG_STATUS_SENDING:
//                NSLog(@"SENDING!!!!!!!!!!");
                status_image_view.image = [UIImage imageNamed:@"chat_watch"];
                //message_view.textColor = [UIColor lightGrayColor];
                break;
            case MSG_STATUS_SENT:
//                NSLog(@"SENT!!!!!!!!!!");
                status_image_view.image = [UIImage imageNamed:@"chat_check"];
                //message_view.textColor = messageColor;
                break;
            case MSG_STATUS_RECEIVED:
//                NSLog(@"RECEIVED!!!!!!!!!!");
                status_image_view.image = [UIImage imageNamed:@"chat_double_check"];
                //message_view.textColor = messageColor;
                break;
            case MSG_STATUS_FAILED:
//                NSLog(@"FAILED!!!!!!!!!!");
                status_image_view.image = [UIImage imageNamed:@"chat_failed"];
                //message_view.textColor = [UIColor redColor];
                break;
            default:
                break;
        }
        //-----------------------------------------------------------//
        //END STATE MESSAGE
        //-----------------------------------------------------------//
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:noMessagesCell forIndexPath:indexPath];
    }
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    return (action == @selector(copy:));
//}
//
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
//    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    if([[cell viewWithTag:3] isKindOfClass:[UILabel class]])
//    {
//        UILabel *message_label = (UILabel *)[cell viewWithTag:3];
//        NSLog(@"msg: %@", message_label.text);
//        
//        generalPasteboard.string = message_label.text;
//    } else {
//        NSLog(@"Not a label. No text to copy in pasteboard.");
//    }
//    
//}








//#pragma mark - Gestures
//- (void)longPressOnCellGestureRecognizer:(UIGestureRecognizer *)recognizer
//{
//    NSLog(@"LONG PRESS!!!!!");
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint pressLocation = [recognizer locationInView:self.tableView];
//        NSIndexPath *pressIndexPath = [self.tableView indexPathForRowAtPoint:pressLocation];
//        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:pressIndexPath];
//        self.cellWithMenu = cell;
//        UITextView *message_view = (UITextView *)[cell viewWithTag:3];
//        NSLog(@"msg: %@", message_view.text);
//        
//        NSLog(@"message view frame x %f,y %f,w %f,h %f", message_view.frame.origin.x, message_view.frame.origin.y, message_view.frame.size.width, message_view.frame.size.height);
//        CGRect target_rect = CGRectMake(pressLocation.x, pressLocation.y, 1, 1);
//        
//        NSLog(@"target_rect x %f,y %f,w %f,h %f", target_rect.origin.x, target_rect.origin.y, target_rect.size.width, target_rect.size.height);
//        
////        [self.popupMenu showInView:self.view targetRect:target_rect animated:YES];
//        
////        NSLog(@"message_view %@ canbecome %d???",message_view, [message_view canBecomeFirstResponder]);
////        NSLog(@"object type: %@", NSStringFromClass([message_view class]));
////        NSLog(@"recognizer.view %@ canbecome %d???",recognizer.view, [recognizer.view canBecomeFirstResponder]);
////        [recognizer.view becomeFirstResponder];
////        UIMenuController *menuController = [UIMenuController sharedMenuController];
////        UIMenuItem *listMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copicchia" action:@selector(copicchia:)];
////        [menuController setMenuItems:[NSArray arrayWithObject:listMenuItem]];
////        
////        
////        [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
//////        [menuController setTargetRect:message_label.frame inView:self.view];
////        [menuController setMenuVisible:YES animated:YES];
//        
//    }
//    
//}

//
//-(BOOL)canBecomeFirstResponder {
//    return YES;
//}
//
//- (BOOL)becomeFirstResponder {
//    return YES;
//}
//
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
////    return YES;
//    BOOL result = NO;
//    if(@selector(copicchia:) == action) { // || @selector(customAction:) == action) {
//        NSLog(@"ONLY COPICCHIA COMMAND!");
//        result = YES;
//    }
//    NSLog(@"RESULT = %d", result);
//    return result;
//}

// UIMenuController Methods

// Default copy method
//- (void)copicchia:(id)sender {
//    NSLog(@"Copicchia pressed on %@", sender);
//    UITextView *message_view = (UITextView *)[self.cellWithMenu viewWithTag:3];
////    [message_view resignFirstResponder];
//}

//// Our custom method
//- (void)customAction:(id)sender {
//    NSLog(@"Custom Action");
//}











-(NSString*)formatDateMessage:(int)numberDaysBetweenChats message:(ChatMessage*)message row:(CGFloat)row {
    NSString *dateChat;
    if(numberDaysBetweenChats>0 || row==0){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *today;
        today = [NSDate date];
        int days = (int)[SHPStringUtil daysBetweenDate:message.date andDate:today];
        if(days==0){
            dateChat = NSLocalizedString(@"oggi", nil);
        }
        else if(days==1){
            dateChat = NSLocalizedString(@"ieri", nil);
        }
        else if(days<8){
            [dateFormatter setDateFormat:@"EEEE"];
            dateChat = [dateFormatter stringFromDate:message.date];
        }
        else{
            [dateFormatter setDateFormat:@"dd MMM"];
            dateChat = [dateFormatter stringFromDate:message.date];
        }
    }
    return dateChat;
}

- (IBAction)sendAction:(id)sender {
    NSString *text = self.messageTextField.text;
    [self sendMessage:text];
}

-(void)sendMessage:(NSString *)text {
    NSString *trimmed_text = [text stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceCharacterSet]];
    if(trimmed_text.length > 0) {
        [self.conversationHandler sendMessage:trimmed_text];
        self.messageTextField.text = @"";
    }
}

- (IBAction)prindb:(id)sender {
    NSLog(@"Printing messages...");
    [self printDBMessages];
}

-(void)printDBMessages {
    NSLog(@"--- all messages for conv %@", self.conversationId);
    NSArray *messages = [[ChatDB getSharedInstance] getAllMessagesForConversation:self.conversationId];
    for (ChatMessage *msg in messages) {
        //NSLog(@"*** MESSAGE FROM SQLITE\n****\nmessageId:%@\nconversationid:%@\nsender:%@\nrecipient:%@\ntext:%@\nstatus:%d\ntimestamp:%@", msg.messageId, msg.conversationId, msg.sender, msg.recipient, msg.text, msg.status, msg.date);
        NSLog(@"%@>%@:%@ [%@]", msg.sender, msg.recipient, msg.text, msg.messageId);
    }
    
//    NSLog(@"--- all messages:");
//    NSArray *allmessages = [[ChatDB getSharedInstance] getAllMessages];
//    for (ChatMessage *msg in allmessages) {
//        //NSLog(@"*** MESSAGE FROM SQLITE\n****\nmessageId:%@\nconversationid:%@\nsender:%@\nrecipient:%@\ntext:%@\nstatus:%d\ntimestamp:%@", msg.messageId, msg.conversationId, msg.sender, msg.recipient, msg.text, msg.status, msg.date);
//        NSLog(@"%@>%@:%@ [id:%@ conv:%@]", msg.sender, msg.recipient, msg.text, msg.messageId, msg.conversationId);
//    }
    
}

-(void)finishedReceivingMessage:(ChatMessage *)message {
    NSLog(@"MessagesVC: FINISHED RECEIVING MESSAGE %@", message.text);
    //    for (ChatMessage *m in self.conversationHandler.messages) {
    //        NSLog(@"text: %@", m.text);
    //    }
    if (!self.playingSound) {
        [self playSound];
    }
    [self.tableView reloadData];
    [self scrollToLastMessage:YES];
}

-(void)playSound {
    double now = [[NSDate alloc] init].timeIntervalSince1970;
    if (now - self.lastPlayedSoundTime < 3) {
        NSLog(@"TOO EARLY TO PLAY ANOTHER SOUND");
        return;
    }
    // help: https://github.com/TUNER88/iOSSystemSoundsLibrary
    // help: http://developer.boxcar.io/blog/2014-10-08-notification_sounds/
    NSString *path = [NSString stringWithFormat:@"%@/inline.caf", [[NSBundle mainBundle] resourcePath]];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
//    [self startSoundTimer];
    
    self.lastPlayedSoundTime = now;
}

//static float soundTime = 3.0;
//
//-(void)startSoundTimer {
//    self.playingSound = YES;
//    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:soundTime target:self selector:@selector(endSoundTimer) userInfo:nil repeats:NO];
//}
//
//-(void)endSoundTimer {
//    [self.soundTimer invalidate];
//    self.soundTimer = nil;
//    self.playingSound = NO;
//}

//DEPRECATO da eliminare dal protocollo
-(void)reloadView {
    [self.tableView reloadData];
}

-(void)scrollToLastMessage: (BOOL)animated {
    NSArray *messages = self.conversationHandler.messages;
//    NSLog(@"scroll to last message. messages.count: %ld", messages.count);
    if (messages && messages.count > 0) {
//        NSLog(@"LAST MESSAGE: %@", ((ChatMessage *)[messages objectAtIndex:messages.count - 1]).text);
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: messages.count-1 inSection: 0];
        [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: animated];
    }
}

//# user images
//- (void)startIconDownload:(NSString *)username forIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *imageURL = [SHPUser photoUrlByUsername:username];
//    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageURL];
//    //    NSLog(@"IconDownloader..%@", iconDownloader);
//    if (iconDownloader == nil)
//    {
//        iconDownloader = [[SHPImageDownloader alloc] init];
//        //        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
//        //        [options setObject:indexPath forKey:@"indexPath"];
//        //        iconDownloader.options = options;
//        iconDownloader.imageURL = imageURL;
//        iconDownloader.delegate = self;
//        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageURL];
//        [iconDownloader startDownload];
//    }
//}
//
//// called by our ImageDownloader when an icon is ready to be displayed
//- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader
//{
////    SHPImageDownloader *downloader = (SHPImageDownloader *) [self.imageDownloadsInProgress objectForKey:imageURL];
//    downloader.delegate = nil;
//    UIImage *circled = [SHPImageUtil circleImage:image];
//    [self.applicationContext.smallImagesCache addImage:circled withKey:imageURL];
//    [self.imageDownloadsInProgress removeObjectForKey:imageURL];
//    [self.tableView reloadData];
//}

-(void)terminatePendingImageConnections {
    NSLog(@"''''''''''''''''''''''   Terminate all pending IMAGE connections...");
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    NSLog(@"total downloads: %d", (int)allDownloads.count);
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
    }
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

// end user images

-(void)disposeResources {
    [self terminatePendingImageConnections];
}

-(void)dealloc {
    NSLog(@"Deallocating MessagesViewController.");
}



//EXTRA
-(void)customRoundImage:(UIView *)customImageView
{
    customImageView.layer.cornerRadius = 15;
    customImageView.layer.masksToBounds = NO;
    customImageView.layer.borderWidth = 0;
    customImageView.layer.borderColor = [UIColor grayColor].CGColor;
}

-(void)customcornerRadius:(UIView *)customImageView cornerRadius:(CGFloat)cornerRadius
{
    customImageView.layer.cornerRadius = cornerRadius;
    customImageView.layer.masksToBounds = NO;
    customImageView.layer.borderWidth = 0;
}

- (IBAction)menuAction:(id)sender {
    [self.menuSheet showInView:self.parentViewController.tabBarController.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.menuSheet) {
        NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([option isEqualToString:@"Info gruppo"]) {
            [self performSegueWithIdentifier:@"GroupInfo" sender:self];
        }
        else if ([option isEqualToString:@"Invia immagine"]) {
            NSLog(@"invia immagine");
            [self.photoMenuSheet showInView:self.parentViewController.tabBarController.view];
        }
    } else {
        switch (buttonIndex) {
            case 0:
            {
                [self takePhoto];
                break;
            }
            case 1:
            {
                [self chooseExisting];
                break;
            }
        }
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GroupInfo"]) {
        GroupInfoVC *vc = (GroupInfoVC *)[segue destinationViewController];
        NSLog(@"vc %@", vc);
        vc.applicationContext = self.applicationContext;
        vc.groupId = self.groupId;
    }
}

// **************************************************
// **************** TAKE PHOTO SECTION **************
// **************************************************

- (void)takePhoto {
    NSLog(@"taking photo with user %@...", self.applicationContext.loggedUser);
    if (self.imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:^{NSLog(@"FINITO!");}];
}

- (void)chooseExisting {
    NSLog(@"choose existing...");
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    NSLog(@"cinitializeCamera...");
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // enable to crop
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    NSLog(@"initializePhotoLibrary...");
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;// SavedPhotosAlbum;// SavedPhotosAlbum;
    self.photoLibraryController.allowsEditing = YES;
    //self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self afterPickerCompletion:picker withInfo:info];
}

-(void)afterPickerCompletion:(UIImagePickerController *)picker withInfo:(NSDictionary *)info {
    self.bigImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"BIG IMAGE: %@", self.bigImage);
    // enable to crop
    // self.scaledImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"edited image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    if (!self.bigImage) {
        self.bigImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSLog(@"original image w:%f h:%f", self.bigImage.size.width, self.bigImage.size.height);
    }
    // end
    
    self.scaledImage = [SHPImageUtil scaleImage:self.bigImage toSize:CGSizeMake(self.applicationContext.settings.uploadImageSize, self.applicationContext.settings.uploadImageSize)];
    NSLog(@"SCALED IMAGE w:%f h:%f", self.scaledImage.size.width, self.scaledImage.size.height);
    
    if (picker == self.imagePickerController) {
        UIImageWriteToSavedPhotosAlbum(self.bigImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    NSLog(@"image: %@", self.scaledImage);
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.scaledImage];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
    
//    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
//    NSLog(@"imageFile: %@", imageFile);
//    
//    PFObject *userPhoto = [PFObject objectWithClassName:@"Image"];
//    NSLog(@"userPhoto: %@", userPhoto);
//    userPhoto[@"file"] = imageFile;
//    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"Image saved.");
//            PFFile *imageFile = userPhoto[@"file"];
//            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//                if (!error) {
//                    NSLog(@"Downloading image...");
//                    UIImage *image = [UIImage imageWithData:imageData];
//                    UIImageWriteToSavedPhotosAlbum(image, self,
//                                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
//                }
//            }];
//        }
//    }];
//    NSLog(@"userPhoto: %@", userPhoto);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        NSLog(@"(SHPTakePhotoViewController) Error saving image to camera roll.");
    }
    else {
        //NSLog(@"(SHPTakePhotoViewController) Image saved to camera roll. w:%f h:%f", self.image.size.width, self.image.size.height);
    }
}

// **************************************************
// *************** END PHOTO SECTION ****************
// **************************************************

@end
