//
//  SHPFacebookPage.h
//  Ciaotrip
//
//  Created by andrea sponziello on 07/02/14.
//
//

#import <Foundation/Foundation.h>

@interface SHPFacebookPage : NSObject
//
@property(strong, nonatomic) NSString *accessToken;
@property(strong, nonatomic) NSString *category;
@property(strong, nonatomic) NSString *page_id;
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *perms;

@end
