//
//  SHPReportDC.h
//  Dressique
//
//  Created by andrea sponziello on 25/01/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPDataController.h"

@class SHPUser;
@class SHPReportDC;

@protocol SHPReportDCDelegate <NSObject>

@required
-(void)didFinishReport:(SHPReportDC *)dc withError:error;

@end

@interface SHPReportDC : NSObject // : SHPDataController

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, assign) id<SHPReportDCDelegate> delegate;

-(void)sendReportForObject:(NSString *)objectType withId:(NSString *)objectId withAbuseType:(NSInteger)abuseType withText:(NSString *)abuseText withUser:(SHPUser *)__user;

- (void)cancelConnection;

@end
