//
//  SHPFacebookConnectionsHandler.h
//  Dressique
//
//  Created by andrea sponziello on 29/04/13.
//
//

#import <Foundation/Foundation.h>

@class SHPFacebookPage;
@class FBSession;

@interface SHPFacebookConnectionsHandler : NSObject

// NOTA: questo non serve quindi sparisce
//@property(strong, nonatomic) NSMutableArray *controllers;

// NOTA: questo diventa un semplice metodo di utilità di classe con + invece di -
+(void)publishProductWithDescription:(NSString *)productDescription image:(UIImage *)image onPage:(SHPFacebookPage *)page;
+(void)sendStory: (NSString *)productDescription image:(UIImage *)image withSession:(FBSession *)session;
+(BOOL)sessionContainsPublishPermission:(FBSession *)session;

@end
