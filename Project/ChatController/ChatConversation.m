//
//  ChatConversation.m
//  Soleto
//
//  Created by Andrea Sponziello on 22/11/14.
//
//

#import "ChatConversation.h"
#import "Firebase/Firebase.h"
#import "ChatDB.h"

@implementation ChatConversation

-(NSString *)dateFormattedForListView {
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    NSString *date = [timeFormat stringFromDate:self.date];
    return date;
}

-(NSString *)textForLastMessage:(NSString *)me {
    if ([self.sender isEqualToString:me]) {
        NSString *you = @"Tu";
        return [[NSString alloc] initWithFormat:@"%@: %@", you, self.last_message_text];
    } else {
        return self.last_message_text;
    }
}

@end
