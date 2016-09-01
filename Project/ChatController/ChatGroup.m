//
//  ChatGroup.m
//  Smart21
//
//  Created by Andrea Sponziello on 27/03/15.
//
//

#import "ChatGroup.h"
#import "Firebase/Firebase.h"
#import "SHPPushNotification.h"
#import "SHPPushNotificationService.h"
#import "SHPApplicationContext.h"

@implementation ChatGroup

+(NSMutableArray *)membersString2Array:(NSString *)membersString {
    NSArray *members = [membersString componentsSeparatedByString:@","];
    NSMutableArray *trimmed_members = [[NSMutableArray alloc] init];
    for (NSString *member in members) {
        NSString *trimmed = [member stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![trimmed isEqualToString:@""]) {
            [trimmed_members addObject:trimmed];
        }
    }
//    NSLog(@"Verify membersString2Array...");
//    for (NSString *m in trimmed_members) {
//        NSLog(@"member: '%@'", m);
//    }
    return trimmed_members;
}

+(NSString *)membersArray2String:(NSArray *)membersArray {
    if (membersArray.count == 0) {
        return @"";
    }
    
    NSString *members_string = [membersArray objectAtIndex:0];
    for (int i = 1; i < membersArray.count; i++) {
        NSString *m = [membersArray objectAtIndex:i];
        NSString *m_to_add = [[NSString alloc] initWithFormat:@",%@",m];
        members_string = [members_string stringByAppendingString:m_to_add];
    }
//    NSLog(@"Verify membersArray2String: '%@'", members_string);
    return members_string;
}

@end
