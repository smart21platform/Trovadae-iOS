//
//  SHPConversationsVC.m
//  Soleto
//
//  Created by Andrea Sponziello on 07/11/14.
//
//

#import "SHPConversationsVC.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "ChatConversation.h"
#import "MessagesViewController.h"
#import "ChatUtil.h"
#import "ChatConversationsHandler.h"
#import "ChatManager.h"
#import "ChatDB.h"
#import "SHPImageDownloader.h"
#import "SHPImageUtil.h"
#import "ChatConversationHandler.h"
#import "ChatGroupsHandler.h"
#import "SHPSelectUserVC.h"
#import "SHPChatCreateGroupVC.h"
#import "SHPChatSelectGroupMembers.h"
#import "ChatGroup.h"
#import <Parse/Parse.h>
#import "ChatImageCache.h"
#import "ParseChatNotification.h"
#import "ChatParsePushService.h"
#import "MessagesViewController.h"
#import "ChatPresenceHandler.h"
#import "ChatImageWrapper.h"
#import "ChatTitleVC.h"

@interface SHPConversationsVC ()
@end

@implementation SHPConversationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"DIDLOADINGCONVERSATIONSVIEW");
    if(!self.applicationContext) {
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    
    [self initImageCache];
    
    // init user info dc
    self.userLoader = [[SHPUserDC alloc]init];
    self.userLoader.delegate = self;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.groupsMode = NO;
    
    [self backButtonSetup];
//    [self customizeTitleView];
    self.navigationItem.title = @"Chat";
    [self initializeWithSignedUser];
    [self setupConnectionStatus];
}

// ------------------------------
// --------- USER INFO ----------
// ------------------------------
-(void)getAllUserInfo {
    [self.userLoader findByUsername:self.me];
}

//DELEGATE
//--------------------------------------------------------------------//
-(void)usersDidLoad:(NSArray *)__users error:(NSError *)error
{
    NSLog(@"usersDidLoad: %@ - %@",__users, error);
    SHPUser *tmp_user;
    if(__users.count > 0) {
        tmp_user = [__users objectAtIndex:0];
        // get company
        NSArray *parts = [tmp_user.email componentsSeparatedByString: @"@"];
        NSString *domain;
        if (parts.count > 0) {
            domain = [parts lastObject];
            //For saving
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:domain forKey:@"chatDomain"];
            [defaults synchronize];
        }
        // save user in NSUserDefaults
        // updateTitle
        [self changeTitle];
    } else {
    }
}
// ------------------------------------
// --------- USER INFO END ------------
// ------------------------------------

-(void)setupConnectionStatus {
    ChatManager *chat = [ChatManager getSharedInstance];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/.info/connected", chat.firebaseRef];
    self.connectedRef = [[Firebase alloc] initWithUrl:url];
    self.connectedRefHandle = [self.connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        if([snapshot.value boolValue]) {
//            NSLog(@"connected");
//            self.statusLabel.text = NSLocalizedString(@"ChatConnected", nil);
//        } else {
//            NSLog(@"not connected");
//            self.statusLabel.text = NSLocalizedString(@"ChatDisconnected", nil);
//        }
        if([snapshot.value boolValue]) {
            NSLog(@"connected");
            self.usernameButton.hidden = NO;
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
            self.statusLabel.text = NSLocalizedString(@"ChatConnected", nil);
        } else {
            NSLog(@"not connected");
            self.usernameButton.hidden = YES;
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
            self.statusLabel.text = NSLocalizedString(@"ChatDisconnected", nil);
        }
    }];
}

//-(void)customizeTitleView {
//    NSLog(@"CUSTOMIZING TITLE VIEW");
//    self.navigationItem.titleView = nil;
//    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
//    ChatTitleVC *vc = [mystoryboard instantiateViewControllerWithIdentifier:@"ChatTitle"];
//    UIView *view = vc.view;
//    view.frame = CGRectMake(0, 0, 200, 40);
////    NSLog(@"w %f h %f", view.frame.size.width, view.frame.size.height);
////    NSLog(@"vc.usernameButton %@ title %@", vc.usernameButton, title);
////    [vc.usernameButton addTarget:self
////                          action:@selector(goToProfile:)
////                forControlEvents:UIControlEventTouchUpInside];
//    self.usernameButton = vc.usernameButton;
//    self.statusLabel = vc.statusLabel;
//    self.activityIndicator = vc.activityIndicator;
//    self.navigationItem.titleView = vc.view;
//}

-(void)setupTitle:(NSString *)title {
    [self.usernameButton setTitle:title forState:UIControlStateNormal];
}

-(void)changeTitle {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *title = (NSString *)[defaults objectForKey:@"chatDomain"];
    if (!title) {
        title = @"Chat";
    }
    [self setupTitle:title];
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

-(void)backButtonSetup {
    if (!self.backButton) {
        self.backButton = [[UIBarButtonItem alloc]
                           initWithTitle:@"Chat"
                           style:UIBarButtonItemStylePlain
                           target:self
                           action:@selector(backButtonClicked:)];
    }
    self.navigationItem.backBarButtonItem = self.backButton;
}

-(void)backButtonClicked:(UIBarButtonItem*)sender
{
    NSLog(@"Back");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"**** viewWillAppear...");
    [self initializeWithSignedUser];
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate saveParseInstallationWithUsername:self.me deviceToken:nil];
    
    // TEMP PARSE LOGIN
//    if (self.me) {
//        NSLog(@"Updating current parse installation with username %@", self.me);
//        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//        currentInstallation.channels = @[ @"global" ];
//        [currentInstallation setObject:self.me forKey:@"username"];
//        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            NSInteger errCode = [error code];
//            if (succeeded) {
//                NSLog(@"Conversations. Installation successfully saved...");
//            }
//            else {
//                NSLog(@"Conversations. Installation saved with error: %d", (int) errCode);
//            }
//        }];
//    }
    
    // save installation for parse notifications
    // 1. registerForRemoteNotifications is called from "application didFinishLaunchingWithOptions" on startup
    // but only if user is just logged-in
    // 2. if user is not logged-in registerForRemoteNotifications is called iimediately after authentication
    // 3. registerForRemoteNotifications is called also from here every time this view appears?
    // 4. registerForRemoteNotifications is called from applicationDidEnterBackground?
}

-(void)initializeWithSignedUser {
    NSLog(@"Initializing user. Signed in as %@", self.applicationContext.loggedUser.username);
    
    NSString *loggedUser = self.applicationContext.loggedUser.username;
    if (loggedUser && !self.me) { // > just signed in / first load after startup
        NSLog(@"**** You just logged In/First load! Connecting to chat");
        // just signedIn
        // TODO reset handlers on every signin
        // can be as easy as:
        // [self.applicationContext.chatManager disposeConversationsHandler];
        // then:
//        self.navigationItem.title = loggedUser;
//        [self customizeTitle:loggedUser];
        
        self.me = loggedUser;
        
        ChatManager *chat = [ChatManager getSharedInstance];
        [chat logout];
        [chat login:loggedUser];
        
        [self initConversationsHandler];
        if (self.groupsMode) {
            [self initGroupsHandler];
        }
        
        [self getAllUserInfo];
        
        [self.tableView reloadData];
    }
    else if (!loggedUser && self.me) {
        NSLog(@"**** You just logged out! Disposing current chat handlers...");
//        for (ChatConversationHandler *h in self.applicationContext.chatManager.handlers) {
//            NSLog(@"printing handler... %@", h);
//            NSString *className = NSStringFromClass([h class]);
//            NSLog(@"printing handler class: %@", className);
//            NSLog(@"printing handler ref: %@", h.conversationId);
//        }
        self.me = nil;
        self.conversationsHandler = nil;
//        [self.applicationContext.chatManager disposeHandlers];
        [[ChatManager getSharedInstance] logout];
//        [chat logout];
        
        [self.tableView reloadData];
    }
    else if (loggedUser && ![self.me isEqualToString:loggedUser]) { // user changed
        // user changed
        // reset handlers
        NSLog(@"**** User changed! Disposing current chat handlers and creating new one...");
        self.me = nil;
        self.conversationsHandler = nil;
//        [self.applicationContext.chatManager disposeHandlers];
        [[ChatManager getSharedInstance] logout];
//        [chat logout];
        NSLog(@"Creating new handlers...");
//        self.navigationItem.title = loggedUser;
//        [self customizeTitle:loggedUser];
//        self.me = loggedUser;
        
        ChatManager *chat = [ChatManager getSharedInstance];
        [chat logout];
        [chat login:loggedUser];
        
        [self initConversationsHandler];
        if (self.groupsMode) {
            [self initGroupsHandler];
        }
        
        [self getAllUserInfo];
        
        [self.tableView reloadData];
    }
    else if (!loggedUser) { // logged out
        NSLog(@"**** User still not logged in.");
        // not signed in
        // do nothing
    }
    else if (loggedUser && [loggedUser isEqualToString:self.me]) {
        NSLog(@"**** You are logged in with the same user. Do nothing.");
    }
}

//-(void)setupConnectionStatus {
//    ChatManager *chat = [ChatManager getSharedInstance];
//    NSString *url = [[NSString alloc] initWithFormat:@"%@/.info/connected", chat.firebaseRef];
//    Firebase *connectedRef = [[Firebase alloc] initWithUrl:url];
//    [connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        if([snapshot.value boolValue]) {
//            NSLog(@"connected");
//        } else {
//            NSLog(@"not connected");
//        }
//    }];
//}

-(void)initConversationsHandler {
    ChatManager *chat = [ChatManager getSharedInstance];
    ChatConversationsHandler *handler = chat.conversationsHandler;
    if (!handler) {
        NSLog(@"Conversations Handler not found. Creating & initializing a new one.");
        handler = [chat createConversationsHandlerForUser:self.applicationContext.loggedUser];
        handler.delegateView = self;
        self.conversationsHandler = handler;
        NSLog(@"Restoring DB archived conversations.");
        [self.conversationsHandler restoreConversationsFromDB];
        NSLog(@"Archived conversations count %lu", (unsigned long)self.conversationsHandler.conversations.count);
        [self update_unread];
        [self update_unread_ui];
        NSLog(@"Connecting handler to firebase.");
        [self.conversationsHandler connect];
    } else {
        NSLog(@"Conversations Handler instance already set. Assigning delegate.");
        handler.delegateView = self;
        self.conversationsHandler = handler;
    }
}

//-(void)initPresenceHandler {
//    ChatManager *chat = [ChatManager getSharedInstance];
//    ChatPresenceHandler *handler = chat.presenceHandler;
//    if (!handler) {
//        NSLog(@"Presence Handler not found. Creating & initializing a new one.");
//        handler = [chat createPresenceHandlerForUser:self.applicationContext.loggedUser];
//        handler.delegate = self;
//        self.presenceHandler = handler;
//        NSLog(@"Connecting handler to firebase.");
//        [self.presenceHandler connect];
//    } else {
//        NSLog(@"Conversations Handler instance already set. Assigning delegate.");
//        handler.delegate = self;
//        self.presenceHandler = handler;
//    }
//}

-(void)initGroupsHandler {
    ChatManager *chat = [ChatManager getSharedInstance];
    ChatGroupsHandler *handler = chat.groupsHandler;
    if (!handler) {
        NSLog(@"Groups Handler not found. Creating & initializing a new one.");
        handler = [chat createGroupsHandlerForUser:self.applicationContext.loggedUser];
        [handler connect];
    }
}

//#protocol SHPConversationsViewDelegate

-(void)didFinishConnect:(ChatConversationsHandler *)handler error:(NSError *)error {
    if (!error) {
        NSLog(@"ChatConversationsHandler Initialization finished with success.");
    } else {
        NSLog(@"ChatConversationsHandler Initialization finished with error: %@", error);
    }
}

//protocol SHPConversationsViewDelegate

-(void)finishedReceivingConversation:(ChatConversation *)conversation {
    NSLog(@"New conversation received %@", conversation.last_message_text);
    NSLog(@"Update received during conversation: %@", self.conversationsHandler.currentOpenConversationId);
    [self showNotificationWindow:conversation];
    [self.tableView reloadData];
//    [self printAllConversations];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self update_unread];
        [self update_unread_ui];
    });
}

-(void)printAllConversations {
    NSLog(@"====== CONVERSATIONS DUMP ======");
    NSMutableArray *conversations = [[[ChatDB getSharedInstance] getAllConversations] mutableCopy];
    for (ChatConversation *c in conversations) {
        NSLog(@"user: %@ id:%@ converswith:%@ sender:%@ recipient:%@",c.user, c.conversationId, c.conversWith, c.sender, c.recipient);
    }
    NSLog(@"====== END.");
    
    NSLog(@"-------- CONVERSATIONS DUMP 2 --------");
    NSMutableArray *_conversations = self.conversationsHandler.conversations;
    for (ChatConversation *c in _conversations) {
        NSLog(@"user: %@ id:%@ converswith:%@ sender:%@ recipient:%@",c.user, c.conversationId, c.conversWith, c.sender, c.recipient);
    }
    NSLog(@"-------- END.");
    
    NSLog(@"########## CONVERSATIONS DUMP 2 ##########");
    
    NSMutableArray *__conversations = [[[ChatDB getSharedInstance] getAllConversationsForUser:self.me] mutableCopy];
    for (ChatConversation *c in __conversations) {
        NSLog(@"user: %@ id:%@ converswith:%@ sender:%@ recipient:%@",c.user, c.conversationId, c.conversWith, c.sender, c.recipient);
    }
    NSLog(@"########## END.");
    
}

-(void)showNotificationWindow:(ChatConversation *)conversation {
    NSString *currentConversationId = self.conversationsHandler.currentOpenConversationId;
    if ( conversation.is_new
         && !self.view.window // conversationsview hidden
         && conversation.conversationId != currentConversationId ) {
        
        UIImage *userImage = [SHPImageUtil circleImage:[UIImage imageNamed:@"avatar"]];
        NSString *imageURL = [SHPUser photoUrlByUsername:conversation.sender];
        ChatImageWrapper *cached_image_wrap = [self.imageCache getImage:imageURL];
        UIImage *cached_image = cached_image_wrap.image;
        UIImage *_circled_cached_image = [SHPImageUtil circleImage:cached_image];
        if(_circled_cached_image) {
            userImage = _circled_cached_image;
        }
        [ChatUtil showNotificationWithMessage:conversation.last_message_text image:userImage sender:conversation.sender];
    }
}

-(void)update_unread_ui {
    [self update_unread_badge];
}

-(void)update_unread_badge {
    NSString *_count;
    if (self.unread_count > 0) {
        _count = [NSString stringWithFormat:@"%d", self.unread_count];
    } else {
        _count = nil;
    }
    int messages_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
    [[self.tabBarController.tabBar.items objectAtIndex:messages_tab_index] setBadgeValue:_count];
}

-(void)update_unread {
    int count = 0;
    for (ChatConversation *c in self.conversationsHandler.conversations) {
        if (c.is_new) {
            count++;
        }
    }
    self.unread_count = count;
    
//    // back button
//    if (count == 0) {
//        self.backButton.title = @"Chat";
//    } else {
//        self.backButton.title = [[NSString alloc] initWithFormat:@"Chat (%d)", count];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        [label setBackgroundColor:[UIColor redColor]];
//        label.text = _count;
//    }
    
    // notify next VC
    if (self.navigationController.viewControllers.count > 1) {
        MessagesViewController *nextVC = [self.navigationController.viewControllers objectAtIndex:1];
        if ([nextVC respondsToSelector:@selector(updateUnreadMessagesCount)]) {
            nextVC.unread_count = count;
            [nextVC performSelector:@selector(updateUnreadMessagesCount) withObject:nil];
        }
        
    }
}

#pragma mark - Table view data source

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSString *title = NSLocalizedString(@"DeleteConversationTitle", nil);
        NSString *msg = NSLocalizedString(@"DeleteConversationMessage", nil);
        NSString *cancel = NSLocalizedString(@"CancelLKey", nil);
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancel otherButtonTitles:@"OK", nil];
        self.removingConversationAtIndexPath = indexPath;
        [alertView show];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        NSArray *conversations = self.conversationsHandler.conversations;
        if (conversations && conversations.count > 0) {
            return conversations.count;
        } else {
            return 1; // message cell
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (self.groupsMode) {
            return 40;
        } else {
            return 0;
        }
    }
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"..................>>>> RENDERING CELLS");
    NSString *me = self.applicationContext.loggedUser.username;
    static NSString *conversationCellName = @"conversationPreviewCell";
    static NSString *menuCellName = @"menuCell";
    static NSString *messageCellName = @"NoConversationsCell";
    
    UITableViewCell *cell;
    NSArray *conversations = self.conversationsHandler.conversations;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:menuCellName forIndexPath:indexPath];
    }
    else if (indexPath.section == 1) {
        if (conversations && conversations.count > 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:conversationCellName forIndexPath:indexPath];
            UILabel *subject_label = (UILabel *)[cell viewWithTag:2];
            UILabel *message_label = (UILabel *)[cell viewWithTag:3];
            UILabel *date_label = (UILabel *)[cell viewWithTag:4];
            ChatConversation *conversation = (ChatConversation *)[conversations objectAtIndex:indexPath.row];
            
//            NSLog(@"CONVERSATION GROUP ID: %@ NAME: %@: ", conversation.groupId, conversation.groupName);
            // SUBJECT LABEL
            if (conversation.groupId) {
                subject_label.text = conversation.groupName; // FIND FULLNAME
            } else {
                subject_label.text = conversation.conversWith; // FIND FULLNAME
            }
            
            // MESSAGE LABEL
            if (conversation.groupId) {
                if (conversation.status == CONV_STATUS_FAILED) {
                    message_label.text = [[NSString alloc] initWithFormat:@"Errore nella creazione del gruppo. Tocca per riprovare"];
                }
                else if (conversation.status == CONV_STATUS_JUST_CREATED) {
                    message_label.text = conversation.last_message_text; //[[NSString alloc] initWithFormat:@"Hai creato il gruppo \"%@\"", conversation.groupName];
                }
                else if (conversation.status == CONV_STATUS_LAST_MESSAGE) {
                    message_label.text = [conversation textForLastMessage:me];
                }
            } else {
                message_label.text = [conversation textForLastMessage:me];
            }
            
            // CONVERSATION IMAGE
            UIImageView *image_view = (UIImageView *)[cell viewWithTag:1];
//            NSLog(@"CONVERSATION GROUP_ID %@", conversation.groupId);
            if (conversation.groupId) {
                // TODO: load group image
//                NSLog(@"STILL NO IMAGE SUPPORT FOR GROUPS > %@", conversation.groupName);
                image_view.image = [UIImage imageNamed:@"icon_circled_group"];
            } else {
//                NSLog(@"IMAGE FOR USER %@.", conversation.conversWith);
                NSString *imageURL = [SHPUser photoUrlByUsername:conversation.conversWith];
                ChatImageWrapper *cached_image_wrap = (ChatImageWrapper *)[self.imageCache getImage:imageURL];
                UIImage *user_image = cached_image_wrap.image;
                if(!cached_image_wrap) { // user_image == nil if image saving gone wrong!
                    //NSLog(@"USER %@ IMAGE NOT CACHED. DOWNLOADING...", conversation.conversWith);
                    [self startIconDownload:conversation.conversWith forIndexPath:indexPath];
                    // if a download is deferred or in progress, return a placeholder image
                    UIImage *circled = [SHPImageUtil circleImage:[UIImage imageNamed:@"avatar"]];
                    image_view.image = circled;
                } else {
                    //NSLog(@"USER IMAGE CACHED. %@", conversation.conversWith);
                    image_view.image = [SHPImageUtil circleImage:user_image];
                    // update too old images
                    double now = [[NSDate alloc] init].timeIntervalSince1970;
                    double reload_timer_secs = 86400; // one day
                    if (now - cached_image_wrap.createdTime.timeIntervalSince1970 > reload_timer_secs) {
                        //NSLog(@"EXPIRED image for user %@. Created: %@ - Now: %@. Reloading...", conversation.conversWith, cached_image_wrap.createdTime, [[NSDate alloc] init]);
                        [self startIconDownload:conversation.conversWith forIndexPath:indexPath];
                    } else {
                        //NSLog(@"VALID image for user %@. Created %@ - Now %@", conversation.conversWith, cached_image_wrap.createdTime, [[NSDate alloc] init]);
                    }
                }
            }
            
            date_label.text = [conversation dateFormattedForListView];
            
            if (conversation.status == CONV_STATUS_LAST_MESSAGE) {
                if (conversation.is_new) {
                    // BOLD STYLE
                    subject_label.font = [UIFont boldSystemFontOfSize:subject_label.font.pointSize];
                    message_label.textColor = [UIColor blackColor];
                    message_label.font = [UIFont boldSystemFontOfSize:message_label.font.pointSize];
                }
                else {
                    // NORMAL STYLE
                    subject_label.font = [UIFont systemFontOfSize:subject_label.font.pointSize];
                    message_label.textColor = [UIColor lightGrayColor];
                    message_label.font = [UIFont systemFontOfSize:message_label.font.pointSize];
                }
            } else {
                // NORMAL STYLE
                subject_label.font = [UIFont systemFontOfSize:subject_label.font.pointSize];
                message_label.textColor = [UIColor lightGrayColor];
                message_label.font = [UIFont systemFontOfSize:message_label.font.pointSize];
            }
        } else {
            NSLog(@"*conversations.count = 0");
            if (!self.applicationContext.loggedUser) {
                NSLog(@"Rendering NO USER CELL...");
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellName forIndexPath:indexPath];
                UILabel *message = (UILabel *)[cell viewWithTag:1];
                message.text = @"Connettiti";
                cell.userInteractionEnabled = NO;
            }
            else {
                NSLog(@"Rendering NO CONVERSATIONS CELL...");
                cell = [tableView dequeueReusableCellWithIdentifier:messageCellName forIndexPath:indexPath];
                UILabel *message = (UILabel *)[cell viewWithTag:1];
                message.text = NSLocalizedString(@"NoConversationsYet", nil);
                cell.userInteractionEnabled = NO;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected s:%d i:%d", (int)indexPath.section, (int)indexPath.row);
    
    if (indexPath.section == 0) { // toolbar
        return;
    }
    
    NSArray *conversations = self.conversationsHandler.conversations;
    
    ChatConversation *selectedConversation = (ChatConversation *)[conversations objectAtIndex:indexPath.row];
    self.selectedConversationId = selectedConversation.conversationId;
    NSLog(@"selected conv: %@ and conversWith: %@", selectedConversation, selectedConversation.conversWith);
    self.selectedRecipient = selectedConversation.conversWith;
    self.selectedGroupId = selectedConversation.groupId;
    self.selectedGroupName = selectedConversation.groupName;
    
    NSLog(@"Opening conversation with id: %@, recipient: %@, groupId: %@, groupName: %@", self.selectedConversationId, self.selectedRecipient, self.selectedGroupId, self.selectedGroupName);
    // updates the conversation status to "read"
//    [ChatConversation updateConversation:selectedConversation.ref message_text:selectedConversation.last_message_text sender:selectedConversation.sender recipient:selectedConversation.recipient timestamp:selectedConversation.date.timeIntervalSince1970 is_new:NO conversWith:selectedConversation.conversWith];
    
    if (selectedConversation.status == CONV_STATUS_FAILED) {
        // TODO
        NSLog(@"Not implemented. Re-start group creation workflow");
        return;
    }
    
    ChatManager *chat = [ChatManager getSharedInstance];
    selectedConversation.is_new = NO;
    [chat updateConversationIsNew:selectedConversation.ref is_new:selectedConversation.is_new];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"CHAT_SEGUE" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"CHAT_SEGUE"]) {
        NSLog(@"Preparing chat_segue...");
        MessagesViewController *vc = (MessagesViewController *)[segue destinationViewController];
        NSLog(@"vc %@", vc);
        // conversationsHandler will update status of new conversations (they come with is_new = true) with is_new = false (because the conversation is open and so new messages are all read)
        self.conversationsHandler.currentOpenConversationId = self.selectedConversationId;
        vc.conversationsVC = self;
        
        vc.conversationId = self.selectedConversationId;
        NSLog(@"self.selectedRecipient: %@", self.selectedRecipient);
        vc.recipient = self.selectedRecipient; // set in didSelectRowAtIndexPath
        vc.groupId = self.selectedGroupId;
        vc.groupName = self.selectedGroupName;
        vc.unread_count = self.unread_count;
        vc.textToSendAsChatOpens = self.selectedRecipientTextToSend;
        self.selectedRecipientTextToSend = nil;
        
        // reset
        NSLog(@".....................RESETTING SELECTED RECIPIENT....................");
        self.selectedRecipient = nil;
        self.selectedGroupId = nil;
        self.selectedGroupName = nil;
        
        NSLog(@".------- SETTING APP CONTEXT and RECIPIENT: %@ %@", self.applicationContext, vc.recipient);
        vc.applicationContext = self.applicationContext;
        vc.senderId = self.me;
        
    }
    else if ([[segue identifier] isEqualToString:@"SelectUser"]) {
        NSLog(@"SelectUser");
        UINavigationController *navigationController = [segue destinationViewController];
        SHPSelectUserVC *vc = (SHPSelectUserVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.modalCallerDelegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"CreateGroup"]) {
        NSLog(@"CreateGroup");
        UINavigationController *navigationController = [segue destinationViewController];
        SHPChatCreateGroupVC *vc = (SHPChatCreateGroupVC *)[[navigationController viewControllers] objectAtIndex:0];
        NSLog(@"APPLICATION CONTEXT CREATEGROUP... %@", self.applicationContext);
        vc.applicationContext = self.applicationContext;
        vc.modalCallerDelegate = self;
    }
}

// use this method to start conversation using the "SelectUser" dialog.
//-(void)openConversationWithRecipient:(SHPUser *)user {
//    NSLog(@"Opening conversation view with recipient %@", user.username);
//    self.selectedRecipient = user.username;
//    NSDictionary *settings_config = [self.applicationContext.plistDictionary objectForKey:@"Config"];
//    NSString *tenant = [settings_config objectForKey:@"tenantName"];
//    self.selectedConversationId = [ChatUtil conversationIdWithSender:self.me receiver:user.username tenant:tenant];
//    NSLog(@"Auto Generated Conversation ID: %@", self.selectedConversationId);
//    [self performSegueWithIdentifier:@"CHAT_SEGUE" sender:self];
//}

-(void)openConversationWithRecipient:(NSString *)username {
    NSLog(@"Opening conversation view with recipient %@", username);
    [self loadViewIfNeeded];
    self.selectedRecipient = username;
    NSDictionary *settings_config = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    NSString *tenant = [settings_config objectForKey:@"tenantName"];
    self.selectedConversationId = [ChatUtil conversationIdWithSender:self.me receiver:username tenant:tenant];
    NSLog(@"Auto Generated Conversation ID: %@", self.selectedConversationId);
    [self performSegueWithIdentifier:@"CHAT_SEGUE" sender:self];
}

// REFACTOR AND REMOVE!!!!
// DO NOT CALL THIS METHOD EXTERNALLY. SIMPLY SET "SELECTEDRECIPIENT" INSTEAD (THIS METHOD IS CALLED FROM INSIDE VIEWDIDAPPEAR IF SELECTEDRECIPIENT IS SET).
// example: from the "message button" in user profile, conversations started from outside this view, etc.
-(void)openConversationWithSelectedRecipient {
    NSLog(@"Opening conversation view with recipient %@", self.selectedRecipient);
    // prepare the controller
    NSDictionary *settings_config = [self.applicationContext.plistDictionary objectForKey:@"Config"];
    NSString *tenant = [settings_config objectForKey:@"tenantName"];
//    self.selectedRecipient = user;
    NSLog(@"ME------------------------************----------->>>>> %@", self.me);
    self.selectedConversationId = [ChatUtil conversationIdWithSender:self.me receiver:self.selectedRecipient tenant:tenant];
    NSLog(@"Auto Generated Conversation ID: %@", self.selectedConversationId);
    [self performSegueWithIdentifier:@"CHAT_SEGUE" sender:self];
}

-(void)resetCurrentConversation {
    self.conversationsHandler.currentOpenConversationId = nil;
}


- (IBAction)newGroupAction:(id)sender {
    NSLog(@"Nuovo gruppo");
    [self performSegueWithIdentifier:@"CreateGroup" sender:self];
}

- (IBAction)testAction:(id)sender {
    ChatManager *chat = [ChatManager getSharedInstance];
    [chat firebaseScout];
}

- (IBAction)printAction:(id)sender {
    [self printDBConvs];
}

- (IBAction)printGroupsAction:(id)sender {
    [self printDBGroups];
}

//# user images

- (void)startIconDownload:(NSString *)username forIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageURL = [SHPUser photoUrlByUsername:username];
    NSLog(@"START DOWNLOADING IMAGE: %@ imageURL: %@", username, imageURL);
    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageURL];
    //    NSLog(@"IconDownloader..%@", iconDownloader);
    if (iconDownloader == nil)
    {
        iconDownloader = [[SHPImageDownloader alloc] init];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:indexPath forKey:@"indexPath"];
        iconDownloader.options = options;
        iconDownloader.imageURL = imageURL;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageURL];
        [iconDownloader startDownload];
    }
}

// callback for the icon loaded
- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader {
//    NSLog(@"+******** IMAGE AT URL: %@ DID LOAD: %@", imageURL, image);
    if (!image) {
        return;
    }
    //UIImage *circled = [SHPImageUtil circleImage:image];
    [self.imageCache addImage:image withKey:imageURL];
    NSDictionary *options = downloader.options;
    NSIndexPath *indexPath = [options objectForKey:@"indexPath"];
//    NSLog(@"+******** appImageDidLoad row: %ld", indexPath.row);
    
    // if the cell for the image is visible updates the cell
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == indexPath.row && index.section == indexPath.section) {
            UITableViewCell *cell = [(UITableView *)self.tableView cellForRowAtIndexPath:index];
            UIImageView *iv = (UIImageView *)[cell viewWithTag:1];
            iv.image = [SHPImageUtil circleImage:image];
        }
    }
    [self.imageDownloadsInProgress removeObjectForKey:imageURL];
}

-(void)terminatePendingImageConnections {
    NSLog(@"''''''''''''''''''''''   Terminate all pending IMAGE connections...");
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
//    NSLog(@"total downloads: %d", allDownloads.count);
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
    }
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

// end user images

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
            NSLog(@"Deleting conversation...");
            NSInteger conversationIndex = self.removingConversationAtIndexPath.row;
            ChatConversation *removingConversation = (ChatConversation *)[self.conversationsHandler.conversations objectAtIndex:conversationIndex];
            NSLog(@"Removing conversation id %@ / ref %@",removingConversation.conversationId, removingConversation.ref);
            
            [self.tableView beginUpdates];
            NSLog(@"INDEXPATHS TO REMOVE %d - %d", (int)self.removingConversationAtIndexPath.row, (int)self.removingConversationAtIndexPath.section);
            NSLog(@"ROWS BEFORE %d", (int)[self.tableView numberOfRowsInSection:1]);
            ChatManager *chat = [ChatManager getSharedInstance];
            [chat removeConversation:removingConversation];
            NSLog(@"REMOVING CONVERSATIONS COUNT BEFORE %d", (int)self.conversationsHandler.conversations.count);
            NSLog(@"REMOVING CONVERSATIONS INDEX %d", (int)conversationIndex);
            [self.conversationsHandler.conversations removeObjectAtIndex:conversationIndex];
            NSLog(@"REMOVING CONVERSATIONS COUNT AFTER %d", (int)self.conversationsHandler.conversations.count);
            NSLog(@"SELF.TABLEVIEW %@", self.tableView);
            [self.tableView deleteRowsAtIndexPaths:@[self.removingConversationAtIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"ROWS AFTER %d", (int)[self.tableView numberOfRowsInSection:1]);
            [self.tableView endUpdates];
            
            // verify
            ChatConversation *conv = [[ChatDB getSharedInstance] getConversationById:removingConversation.conversationId];
            NSLog(@"Verifying conv %@", conv);
            NSArray *messages = [[ChatDB getSharedInstance] getAllMessagesForConversation:removingConversation.conversationId];
            NSLog(@"resting messages count %lu", (unsigned long)messages.count);
        }
    }
}

-(void)disposeResources {
    [self terminatePendingImageConnections];
}

-(void)printDBConvs {
    NSString *current_user = self.applicationContext.loggedUser.username;
    NSLog(@"Conversations for user %@...", current_user);
    NSArray *convs = [[ChatDB getSharedInstance] getAllConversationsForUser:current_user];
    for (ChatConversation *conv in convs) {
        NSLog(@"[%@] new?%d sender:%@ recip: %@ groupId: %@ \"%@\"", conv.conversationId, conv.is_new, conv.sender, conv.recipient, conv.groupId, conv.last_message_text);
    }
}

-(void)printDBGroups {
    NSString *current_user = self.applicationContext.loggedUser.username;
    NSLog(@"Groups for user %@...", current_user);
//    NSArray *groups = [[ChatDB getSharedInstance] getAllGroupsForUser:self.me];
    NSArray *groups = [[ChatDB getSharedInstance] getAllGroups];
    for (ChatGroup *g in groups) {
        NSLog(@"ID:%@ NAME:%@ OWN:%@ MBRS:%@", g.groupId, g.name, g.owner, [ChatGroup membersArray2String:g.members]);
    }
}

- (void)setupViewController:(UIViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo {
    NSLog(@"setupViewController...");
    if([controller isKindOfClass:[SHPSelectUserVC class]])
    {
        SHPUser *user = nil;
        if ([setupInfo objectForKey:@"user"]) {
            user = [setupInfo objectForKey:@"user"];
            NSLog(@">>>>>> SELECTED: user %@", user.username);
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if (user) {
                [self openConversationWithRecipient:user.username];
            }
        }];
    }
    else if([controller isKindOfClass:[SHPChatSelectGroupMembers class]])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        NSMutableArray *groupMembers = (NSMutableArray *)[setupInfo objectForKey:@"groupMembers"];
        NSLog(@"Members...");
        NSMutableArray *membersIDs = [[NSMutableArray alloc] init];
        for (SHPUser *u in groupMembers) {
            [membersIDs addObject:u.username];
            NSLog(@"added member id: %@", u.username);
        }
        NSString *groupName = (NSString *)[setupInfo objectForKey:@"groupName"];
//        NSLog(@"Group Name: %@", groupName);
        
        NSString *iconURL = (NSString *)[setupInfo objectForKey:@"iconURL"];
//        NSLog(@"iconURL: %@", iconURL);
        
        // the tenant id
        NSDictionary *settings_config = [self.applicationContext.plistDictionary objectForKey:@"Config"];
        NSString *tenant_id = [settings_config objectForKey:@"tenantName"];
//        NSLog(@"Current tenant: %@", tenant_id);
        
        // adding group's owner
        [membersIDs addObject:self.applicationContext.loggedUser.username];
        [self createGroupWithMembers:membersIDs groupName:groupName iconURL:iconURL onTenant:tenant_id];
    }
}

-(void)createGroupWithMembers:(NSMutableArray *)membersIDs groupName:(NSString *)groupName iconURL:(NSString *)iconURL onTenant:(NSString *)tenant_id {
    
    for (NSString *user in membersIDs) {
        NSLog(@">> USERs in group: %@", user);
    }
    
    ChatGroup *group = [[ChatGroup alloc] init];
    group.name = groupName;
    group.user = self.me;
    group.members = membersIDs;
    group.owner = self.applicationContext.loggedUser.username;
    group.iconURL = iconURL;
    group.createdOn = [[NSDate alloc] init];
    
    ChatManager *chat = [ChatManager getSharedInstance];
    [chat createFirebaseGroup:group withCompletionBlock:^(NSString *_groupId, NSError *error) {
        if (error) {
            // create new conversation for this group on local DB
            // a local DB conversation entry is created to manage, locally, the group creation workflow.
            // ex. success/failure on creation - add/removing members - change group title etc.
            NSString *group_conv_id = [ChatUtil conversationIdForGroup:_groupId];
            NSLog(@"group_conv_id created for me (%@): %@",self.me, group_conv_id);
            NSString *conversation_message_for_admin = [[NSString alloc] initWithFormat:@"Errore nella crazione del gruppo \"%@\". Tocca per riprovare.", group.name];
            ChatConversation *groupConversation = [[ChatConversation alloc] init];
            groupConversation.conversationId = group_conv_id;
            groupConversation.user = self.me;
            groupConversation.key = group_conv_id;
            groupConversation.groupId = nil;
            groupConversation.groupName = group.name; // compare nella cella al posto di "conversWith"
            groupConversation.last_message_text = conversation_message_for_admin;
            //    groupConversation.sender = self.me;
            NSDate *now = [[NSDate alloc] init];
            groupConversation.date = now;
            groupConversation.status = CONV_STATUS_FAILED;
            BOOL result = [[ChatDB getSharedInstance] insertOrUpdateConversation:groupConversation];
            NSLog(@">>>>> -Group Failed- Conversation insertOrUpdate operation is %d", result);
            [self.conversationsHandler restoreConversationsFromDB];
            [self.tableView reloadData];
        } else {
            // now we have the group id
            NSLog(@"Group created with ID: %@", _groupId);
            NSLog(@"Group created with ID: %@", group.groupId);
            
            [[ChatDB getSharedInstance] insertOrUpdateGroup:group];
            
            // create new conversation for this group on local DB
            // a local DB conversation entry is created to manage, locally, the group creation workflow.
            // ex. success/failure on creation - add/removing members - change group title etc.
            NSString *group_conv_id = [ChatUtil conversationIdForGroup:_groupId];
            NSLog(@"group_conv_id created (%@): %@",self.me, group_conv_id);
            NSString *conversation_message_for_admin = [[NSString alloc] initWithFormat:@"Hai creato il gruppo \"%@\"", group.name];
            NSString *conversation_message_for_member = [[NSString alloc] initWithFormat:@"Sei stato aggiunto al gruppo \"%@\"", group.name];
            ChatConversation *groupConversation = [[ChatConversation alloc] init];
            groupConversation.conversationId = group_conv_id;
            groupConversation.user = self.me;
            groupConversation.key = group_conv_id;
            groupConversation.groupId = _groupId;
            groupConversation.groupName = group.name; // compare nella cella al posto di "conversWith"
            groupConversation.last_message_text = conversation_message_for_admin;
            //    groupConversation.sender = self.me;
            NSDate *now = [[NSDate alloc] init];
            groupConversation.date = now;
            groupConversation.status = CONV_STATUS_JUST_CREATED;
            
            BOOL result = [[ChatDB getSharedInstance] insertOrUpdateConversation:groupConversation];
            NSLog(@">>>>> Conversation insertOrUpdate is %d", result);
            [self.conversationsHandler restoreConversationsFromDB];
            [self.tableView reloadData];
            
            // create a remote Firebase conversation for every member
            // === START TRANSACTION (FOR EVERY CONVERSATION ADDED) ===
            for (NSString *member_id in membersIDs) {
//                NSString *group_conv_id_for_member = [ChatUtil conversationIdForGroup:_groupId];
                ChatConversation *memberConversation = [[ChatConversation alloc] init];
//                Firebase *conversationRefOnUser = [ChatUtil conversationRefForUser:member_id conversationId:group_conv_id_for_member];
                Firebase *conversationRefOnUser = [ChatUtil conversationRefForUser:member_id conversationId:group_conv_id];
                NSLog(@"Conversation ref for user: %@", conversationRefOnUser);
                memberConversation.ref = conversationRefOnUser;
                memberConversation.last_message_text = conversation_message_for_member;
                memberConversation.is_new = YES;
                memberConversation.date = now;
                memberConversation.sender = self.me;
                memberConversation.recipient = nil;
                memberConversation.conversWith = nil;
                memberConversation.groupName = groupName;
                memberConversation.groupId = _groupId;
                memberConversation.status = CONV_STATUS_JUST_CREATED;
                [chat createOrUpdateConversation:memberConversation];
                NSLog(@"Added conversation on Firebase for member: %@ with message: %@", member_id, memberConversation.last_message_text);
            }
            // ADDING CONVERSATION FOR ADMIN MEMBER
            ChatConversation *memberConversation = [[ChatConversation alloc] init];
            Firebase *conversationRefOnUser = [ChatUtil conversationRefForUser:self.me conversationId:group_conv_id];
            NSLog(@"Conversation ref for user: %@", conversationRefOnUser);
            memberConversation.ref = conversationRefOnUser;
            memberConversation.last_message_text = conversation_message_for_admin;
            memberConversation.is_new = YES;
            memberConversation.date = now;
            memberConversation.sender = self.me;
            memberConversation.recipient = nil;
            memberConversation.conversWith = nil;
            memberConversation.groupName = groupName;
            memberConversation.groupId = _groupId;
            memberConversation.status = CONV_STATUS_JUST_CREATED;
            [chat createOrUpdateConversation:memberConversation];
            NSLog(@"added group conversation on Firebase for admin: %@", self.me);
            
            // sending notifications
            [self sendNotificationsToGroup:group];
            
            // === END TRANSACTION ===
        }
    }];
}

-(void)sendNotificationsToGroup:(ChatGroup *)group {
    NSLog(@"Sending 'invited' notification to every member.");
    NSLog(@"members: %d", (int)group.members.count);
    for (NSString *member_id in group.members) {
        NSLog(@"member: %@", member_id);
    }
    // Send notification to every member
    for (NSString *member_id in group.members) {
        NSLog(@"Sending notification to user: %@", member_id);
        
        // SMART21
//        SHPPushNotification *notification = [[SHPPushNotification alloc] init];
//        notification.notificationType = NOTIFICATION_TYPE_MEMBER_ADDED_TO_GROUP;
//        notification.toUser = member_id;
//        notification.message = [[NSString alloc] initWithFormat:@"You have been added to group %@", [group.name capitalizedString]];
//        notification.properties = @{ @"t": NOTIFICATION_TYPE_MEMBER_ADDED_TO_GROUP, @"group_id": group.groupId};
//        SHPPushNotificationService *push_service = [[SHPPushNotificationService alloc] init];
//        [push_service sendNotification:notification completionHandler:^(SHPPushNotification *notification, NSError *error) {
//            if (!error) {
//                NSLog(@"Notification sent with message: \"%@\"", notification.message);
//            } else {
//                NSLog(@"Error while sending notification %@. Error: %@", notification.message, error);
//            }
//        } withUser:self.applicationContext.loggedUser];
        // SMART21
        
        // PARSE NOTIFICATION
        ParseChatNotification *notification = [[ParseChatNotification alloc] init];
        NSString *sender = @"";
        notification.senderUser = sender;
        notification.toUser = member_id;// message.recipient;
        notification.alert = [[NSString alloc] initWithFormat:@"You have been added to group %@", [group.name capitalizedString]];
        notification.conversationId = group.groupId;
        notification.badge = @"0";
        ChatParsePushService *push_service = [[ChatParsePushService alloc] init];
        [push_service sendNotification:notification];
        // END PARSE NOTIFICATION
        
        NSLog(@"Notification sent to user %@", member_id);
    }
    NSLog(@"All notifications sent for group %@.", group.name);
    
}

- (void)setupViewController:(UIViewController *)controller didCancelSetupWithInfo:(NSDictionary *)setupInfo {
    if([controller isKindOfClass:[SHPSelectUserVC class]])
    {
        NSLog(@"User selection Canceled.");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if([controller isKindOfClass:[SHPChatCreateGroupVC class]])
    {
        NSLog(@"Group creation canceled.");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)actionNewMessage:(id)sender {
    NSLog(@"New Messsage");
    [self performSegueWithIdentifier:@"SelectUser" sender:self];
}

@end
