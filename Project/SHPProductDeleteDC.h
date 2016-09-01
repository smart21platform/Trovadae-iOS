//
//  SHPProductDeleteDC.h
//  Dressique
//
//  Created by andrea sponziello on 17/05/13.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;
@class SHPUser;

@protocol SHPProductDeleteDCDelegate
- (void)productDeleted:(NSString *)errorMessage;
- (void)networkError;
@end

@interface SHPProductDeleteDC : NSObject

@property(strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, assign) id <SHPProductDeleteDCDelegate> delegate;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) NSInteger statusCode;

-(void)deleteProduct:(NSString *)oid withUser:(SHPUser *)user;

@end
