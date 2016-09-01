//
//  SHPChatDelegate.h
//
//  Created by Andrea Sponziello on 19/12/14.
//
//

#import <Foundation/Foundation.h>

@class ChatConversationHandler;
@class ChatMessage;

@protocol SHPChatDelegate <NSObject>

@required
-(void)didFinishInitConversationHandler:(ChatConversationHandler *)handler error:(NSError *)error;
-(void)finishedReceivingMessage:(ChatMessage *)message;
-(void)reloadView;

@end
