//
//  SHPActivity.m
//  Coricciati MG
//
//  Created by Dario De Pascalis on 05/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPActivity.h"

@implementation SHPActivity

- (NSString *)activityType
{
    return @"your Custom Type";
}

- (NSString *)activityTitle
{
    return @"Segnala";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"your icon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // basically in your case: return YES if activity items are urls
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //open safari with urls (activityItems)
    NSLog(@"ACTIVITY ITEM ACTION");
    [self.parent deleteProduct];
    //[self performSegueWithIdentifier:@"toReport" sender:self];
}

+(UIActivityCategory)activityCategory
{
    //return UIActivityCategoryShare;//says that your icon will belong in application group, not in the lower part;
    return UIActivityCategoryAction;
}

@end
