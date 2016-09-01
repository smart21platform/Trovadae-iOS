//
//  ChatUtil.m
//  Soleto
//
//  Created by Andrea Sponziello on 02/12/14.
//
//

#import "ChatUtil.h"
#import <Firebase/Firebase.h>
#import "ChatConversation.h"
#import "ChatManager.h"
#import "NotificationAlertVC.h"

static NotificationAlertVC *notificationAlertInstance = nil;

@implementation ChatUtil

+(NotificationAlertVC*)getNotificationAlertInstance {
    if (!notificationAlertInstance) {
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
        NotificationAlertVC *notifVC = [mystoryboard instantiateViewControllerWithIdentifier:@"NotificationAlert"];
        UIView *view = notifVC.view;
        float alertHeight = 80;
        view.frame = CGRectMake(0, -alertHeight, view.frame.size.width, alertHeight);
        NSLog(@"w %f h %f", view.frame.size.width, view.frame.size.height);
        [[[UIApplication sharedApplication] keyWindow] addSubview:view];
        notificationAlertInstance = notifVC;
    }
    return notificationAlertInstance;
}

+(void)showNotificationWithMessage:(NSString *)message image:(UIImage *)image sender:(NSString *)sender {
    NotificationAlertVC *alert = [ChatUtil getNotificationAlertInstance];
    alert.messageLabel.text = message;
    alert.senderLabel.text = sender;
    alert.userImage.image = image;
    alert.sender = sender;
//    UIView *view = alert.view;
//    is_animating = NO;
    [alert animateShow];
}

+(NSString *)conversationIdWithSender:(NSString *)sender receiver:(NSString *)receiver tenant:(NSString *)tenant {
    NSLog(@"sender %@ receiver %@", sender, receiver);
    NSString *sanitized_sender = [ChatUtil sanitizedNode:sender];
    NSString *sanitized_receiver = [ChatUtil sanitizedNode:receiver];
    NSMutableArray *users = [[NSMutableArray alloc] init];
    [users addObject:sanitized_sender];
    [users addObject:sanitized_receiver];
    NSLog(@"users 0 %@", [users objectAtIndex:0]);
    NSLog(@"users 1 %@", [users objectAtIndex:1]);
    NSArray *sortedUsers = [users sortedArrayUsingSelector:
                            @selector(localizedCaseInsensitiveCompare:)];
    //    // verify users order
    //    for (NSString *username in sortedUsers) {
    //        NSLog(@"username: %@", username);
    //    }
    NSString *conversation_id = [tenant stringByAppendingFormat:@"-%@-%@", sortedUsers[0], sortedUsers[1]];
    return  conversation_id;
}

+(NSString *)conversationIdForGroup:(NSString *)groupId {
    // conversationID = "{groupID}_GROUP"
    NSString *conversation_id = [groupId stringByAppendingFormat:@"_GROUP"];
    return  conversation_id;
}

+(NSString *)usernameOnTenant:(NSString *)tenant username:(NSString *)username {
    NSString *sanitized_username = [ChatUtil sanitizedNode:username];
    NSString *sanitized_tenant = [ChatUtil sanitizedNode:tenant];
    return [[NSString alloc] initWithFormat:@"%@-%@", sanitized_tenant, sanitized_username];
}

+(Firebase *)conversationRefForUser:(NSString *)username conversationId:(NSString *)conversationId {
    
//    NSDictionary *settings_config = [settings objectForKey:@"Config"];
    NSString *tenant = [ChatManager getSharedInstance].tenant; //[settings_config objectForKey:@"tenantName"];
    
    NSString *firebase_chat_ref = [ChatManager getSharedInstance].firebaseRef; //(NSString *)[settings objectForKey:@"Firebase-chat-ref"];
    NSLog(@"firebase_chat_ref: %@", firebase_chat_ref);
    
    NSString *sanitized_username = [ChatUtil sanitizedNode:username];
    
    NSString *tenant_user = [ChatUtil usernameOnTenant:tenant username:sanitized_username];
    
    NSString *conversationRefOnUser = [firebase_chat_ref stringByAppendingFormat:@"/tenantUsers/%@/conversations/%@", tenant_user, conversationId];
    
    Firebase *conversation_ref_on_user = [[Firebase alloc] initWithUrl:conversationRefOnUser];
    return conversation_ref_on_user;
}

//+(Firebase *)conversationMessagesRef:(NSString *)conversationId settings:(NSDictionary *)settings {
+(Firebase *)conversationMessagesRef:(NSString *)conversationId {
    NSString *firebaseChatRef = [ChatManager getSharedInstance].firebaseRef;
    NSString *firebase_conversation_messages_ref = [firebaseChatRef stringByAppendingFormat:@"/messages/%@",conversationId];
    
    NSLog(@"##### firebase_conversation_messages_ref: %@", firebase_conversation_messages_ref);
    
    Firebase *messagesRef = [[Firebase alloc] initWithUrl: firebase_conversation_messages_ref];
    return messagesRef;
}

+(NSString *)sanitizedNode:(NSString *)node_name {
    // Firebase not accepted characters for node names must be a non-empty string and not contain:
    // . # $ [ ]
    NSString* _node_name;
    _node_name = [node_name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"#" withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"$" withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"[" withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"]" withString:@"_"];
    
    return _node_name;
}

+(NSString *)buildConversationsReferenceWithTenant:(NSString *)tenant username:(NSString *)user_id baseFirebaseRef:(NSString *)baseFirebaseRef {
    NSString *tenant_user_sender = [ChatUtil usernameOnTenant:tenant username:user_id];
    NSLog(@"tenant-user-sender-id: %@", tenant_user_sender);
    
    NSString *firebase_conversations_ref = [baseFirebaseRef stringByAppendingFormat:@"/tenantUsers/%@/conversations", tenant_user_sender];
    return firebase_conversations_ref;
}

+(NSString *)buildPresenceReferenceWithTenant:(NSString *)tenant username:(NSString *)user_id baseFirebaseRef:(NSString *)baseFirebaseRef {
    //Firebase *presenceRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/users/joe/connections"];
    NSString *tenant_user_sender = [ChatUtil usernameOnTenant:tenant username:user_id];
    NSLog(@"tenant-user-sender-id: %@", tenant_user_sender);
    
    NSString *firebase_ref = [baseFirebaseRef stringByAppendingFormat:@"/tenantUsers/%@/connections", tenant_user_sender];
    return firebase_ref;
}

+(Firebase *)groupsRefWithBase:(NSString *)firebaseRef {
    Firebase *baseRef = [[Firebase alloc] initWithUrl:firebaseRef];
    Firebase *firebase_groups_ref = [baseRef childByAppendingPath:@"groups"];
    return firebase_groups_ref;
}

//+(void)createNotificationView:(ChatNotificationView *)viewNotif
//{
//    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
//    NotificationAlertVC *notifVC = [mystoryboard instantiateViewControllerWithIdentifier:@"NotificationAlert"];
//    notifVC.messageLabel.text = @"Ciao";
//    UIView *view = notifVC.view;
//    NSLog(@"notifVC %@", notifVC);
////    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
//    view.frame = CGRectMake(0, -80, view.frame.size.width, 80);
//    NSLog(@"w %f h %f", view.frame.size.width, view.frame.size.height);
//    [[[UIApplication sharedApplication] keyWindow] addSubview:view];
//    
//    
//    [UIView animateWithDuration:0.5
//                          delay:0.5
//                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
//                     animations:^{
//                         view.frame = CGRectMake(0, 0, view.frame.size.width, 80);
//                     }
//                     completion:^(BOOL finished){
//                         [UIView animateWithDuration:0.5
//                                               delay:2.5
//                                             options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
//                                          animations:^{
//                                              view.frame = CGRectMake(0, -80, view.frame.size.width, 80);
//                                          }
//                                          completion:nil];
//                     }];
//
////    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
////    float width = win.frame.size.width;
////    viewNotif = [[ChatNotificationView alloc] init];
////    viewNotif.frame = CGRectMake(0, 0, width, 60);
////    viewNotif.backgroundColor = [UIColor greenColor];
////    viewNotif.alpha = 0;
////    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, (width - 10), 50)];
////    [messageLabel setTextColor:[UIColor whiteColor]];
////    [messageLabel setBackgroundColor:[UIColor clearColor]];
////    [messageLabel setFont:[UIFont fontWithName: @"Helvetica Neue" size: 12.0f]];
//////    messageLabel.text = errorMessage;
////    messageLabel.textAlignment = NSTextAlignmentCenter;
////    [viewNotif addSubview:messageLabel];
////    [[[UIApplication sharedApplication] keyWindow] addSubview:viewNotif];
//}
//

@end
