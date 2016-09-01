//
//  ChatRootNC.m
//  Chat21
//
//  Created by Andrea Sponziello on 28/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "ChatRootNC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPConversationsVC.h"
#import "NotConnectedVC.h"
#import "CZAuthenticationVC.h"

@interface ChatRootNC ()

@end

@implementation ChatRootNC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"DIDLOADINGROOTNC");
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    self.chatConfig = [self.applicationContext.plistDictionary valueForKey:@"Chat21"];
    self.startupLogin = [[self.chatConfig valueForKey:@"startupLogin"] boolValue];
    NSLog(@"STARTUP LOGIN %d", self.startupLogin);
    [self setupNC];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"**** SetupNC.viewDidAppear...");
    if (self.startupLogin && !self.applicationContext.loggedUser) {
        NSLog(@"strtupLogin = YES");
        [self goToAuthentication];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"**** SetupNC.viewWillAppear...");
    [self setupNC];
}

-(void)goToAuthentication{
    NSLog(@"PRESENTING AUTHENTICATION VIEW.");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    CZAuthenticationVC *vc = (CZAuthenticationVC *)[sb instantiateViewControllerWithIdentifier:@"StartAuthentication"];
    NSLog(@"vc = %@", vc);
    vc.applicationContext = self.applicationContext;
    //vc.disableButtonClose = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:NO completion:NULL];
}


-(void)setupNC {
    [self loadViewIfNeeded];
    NSLog(@"setupNC. self.applicationContext.loggedUser: %@", self.applicationContext.loggedUser);
    if (self.applicationContext.loggedUser) {
        [self linkChatNC];
    }
    else if (self.startupLogin) {
        [self linkWhiteView];
    }
    else {
        [self linkConnectView];
    }
}

-(void)openConversationWithRecipient:(NSString *)username {
    [self setupNC];
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[SHPConversationsVC class]]) {
        NSLog(@"Chat linked. Opening conversation with user: %@", username);
        SHPConversationsVC *vc = self.viewControllers[0];
        [vc openConversationWithRecipient:username];
    } else {
        NSLog(@"Chat not linked. This is a problem. Am I receiving notification but logged out? Or something else?");
    }
}

-(void)openConversationWithRecipient:(NSString *)username sendText:(NSString *)text {
    [self setupNC];
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[SHPConversationsVC class]]) {
        NSLog(@"Chat linked. Opening conversation with user: %@", username);
        SHPConversationsVC *vc = self.viewControllers[0];
        vc.selectedRecipientTextToSend = text;
        [vc openConversationWithRecipient:username];
    } else {
        NSLog(@"Chat not linked. This is a problem. Am I receiving notification but logged out? Or something else?");
    }
}

-(void)linkChatNC {
    NSLog(@"Initializing linkChatNC");
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[SHPConversationsVC class]]) {
        NSLog(@"Chat already linked");
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    UINavigationController *chatNC = [sb instantiateViewControllerWithIdentifier:@"ChatNavigationController"];
    [self setViewControllers:chatNC.viewControllers];
}

-(void)linkConnectView {
    NSLog(@"Initializing linkConnectView");
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[NotConnectedVC class]]) {
        NSLog(@"ConnectView already linked");
        return;
    }
    UIStoryboard *sb = [self storyboard];
    UIViewController *connectView = [sb instantiateViewControllerWithIdentifier:@"NotConnectedVC"];
    [self setViewControllers:@[connectView]];
}

-(void)linkWhiteView { // for startupLogin
    NSLog(@"Initializing linkWhiteView");
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[UIViewController class]]) {
        NSLog(@"WhiteView already linked");
        return;
    }
    UIStoryboard *sb = [self storyboard];
    UIViewController *connectView = [sb instantiateViewControllerWithIdentifier:@"WhiteView"];
    [self setViewControllers:@[connectView]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
