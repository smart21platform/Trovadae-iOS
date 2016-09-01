//
//  CustomActivityItemProvider.m
//  Secondamano
//
//  Created by Andrea Sponziello on 22/02/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "CustomActivityItemProvider.h"

@implementation CustomActivityItemProvider

- (id)initWithText:(NSString *)text twitText:(NSString *)twitText urlText:(NSURL *)url image:(UIImage *)image emailSubject:(NSString *)emailSubject {
    
    if ((self = [super initWithPlaceholderItem:text])) {
        self.text = text ?: @"";
        self.twit = twitText ?: @"";
        self.url = url;
        self.image = image;
        self.emailSubject = emailSubject ?: @"";
    }
    return self;
}

- (id)item {
    NSString *activityType = self.activityType;
    if ([self.placeholderItem isKindOfClass:[NSString class]]) {
        NSLog(@"isKindOfClass:[NSString class]!");
        if ([activityType isEqualToString:UIActivityTypeMail]) {
            NSLog(@"MAIL!");
//            NSMutableArray *objectsToShare = [[NSMutableArray alloc] init];
            
//            [objectsToShare addObject:self.image];
//            [objectsToShare addObject:self.text];
//            [objectsToShare addObject:self.url];
            
            return [NSString stringWithFormat:@"%@\n\n%@", self.text, self.url];
            
        }
        if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
            NSLog(@"FACEBOOK, text: %@", self.text);
//            NSMutableArray *objectsToShare = [[NSMutableArray alloc] init];
            
//            [objectsToShare addObject:self.image];
//            [objectsToShare addObject:self.text];
//            [objectsToShare addObject:self.url];
            return @[@"Facebook text"]; // NON FUNZIONA!!!!! DOESN'T WORK!!!!!
            
            
//            return objectsToShare;
            
            //            return [NSString stringWithFormat:@"%@\n%@", self.text, self.url];
            
        }
        else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
            NSLog(@"TWIT");
            return [NSString stringWithFormat:@"%@\n%@", self.twit, self.url];
            
        }
        else if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
            NSLog(@"PASTEBOARD");
            return self.url;
        }
        else {
            return self.text;
        }
    }
    
    return self.placeholderItem;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    NSString *subject;
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return self.emailSubject;
    }
    return subject;
}

@end
