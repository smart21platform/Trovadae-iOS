//
//  SHPUser.h
//  Shopper
//
//  Created by andrea sponziello on 25/08/12.
//
//

#import <Foundation/Foundation.h>

@interface SHPUser : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *numberPhone;
@property (assign, nonatomic) BOOL canUploadProducts;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) UIImage *photoImage;
@property (strong, nonatomic) NSString *urlDocuments;
@property (strong, nonatomic) NSString *httpBase64Auth;
@property (assign, nonatomic) BOOL isRivenditore;
@property (strong, nonatomic) NSString *facebookAccessToken;
@property (strong, nonatomic) NSString *productsCreatedByCount;
@property (strong, nonatomic) NSString *productsLikesCount;
@property (strong, nonatomic) NSDictionary *properties;

+(NSString *)photoUrlByUsername:(NSString *)username;
-(NSString *)photoUrl;

@end
