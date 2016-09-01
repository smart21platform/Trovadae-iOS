//
//  SHPUser.m
//  Shopper
//
//  Created by andrea sponziello on 25/08/12.
//
//

#import "SHPUser.h"
#import "SHPServiceUtil.h"
#import "SHPConstants.h"

@implementation SHPUser

// archived
@synthesize username;
@synthesize fullName;
@synthesize canUploadProducts;
@synthesize httpBase64Auth;
@synthesize facebookAccessToken;

// transient
@synthesize email;
@synthesize photoUrl;

static NSString *USERNAME_KEY = @"username";
static NSString *FULLNAME_KEY = @"fullName";
static NSString *HTTPBASE64AUTH_KEY = @"httpBase64Auth";
static NSString *FACEBOOK_ACCESS_TOKEN_KEY = @"facebookAccessToken";
static NSString *PHOTO_IMAGE_KEY = @"photoImage";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.username = [decoder decodeObjectForKey:USERNAME_KEY];
        self.fullName = [decoder decodeObjectForKey:FULLNAME_KEY];
        self.httpBase64Auth = [decoder decodeObjectForKey:HTTPBASE64AUTH_KEY];
        self.facebookAccessToken = [decoder decodeObjectForKey:FACEBOOK_ACCESS_TOKEN_KEY];
        self.photoImage = [decoder decodeObjectForKey:PHOTO_IMAGE_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.username forKey:USERNAME_KEY];
    [encoder encodeObject:self.fullName forKey:FULLNAME_KEY];
    [encoder encodeObject:self.httpBase64Auth forKey:HTTPBASE64AUTH_KEY];
    [encoder encodeObject:self.facebookAccessToken forKey:FACEBOOK_ACCESS_TOKEN_KEY];
    [encoder encodeObject:self.photoImage forKey:PHOTO_IMAGE_KEY];
}

+(NSString *)photoUrlByUsername:(NSString *)username {
    NSInteger w = SHPCONST_USER_ICON_WIDTH;
    NSInteger h = SHPCONST_USER_ICON_HEIGHT;
    // retina resolution img?
    //    if ([UIScreen mainScreen].scale == 2.0) {
    //        w = w * 2;
    //        h = h * 2;
    //    }
    NSString *peopleService = [SHPServiceUtil serviceUrl:@"service.people"];
    NSString *username_enc = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/photo?w=%d&h=%d", peopleService, username_enc, (int)w, (int)h];
    
    return url;
}

-(NSString *)photoUrl {
    return [SHPUser photoUrlByUsername:self.username];
}

@end
