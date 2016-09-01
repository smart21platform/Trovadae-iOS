//
//  SHPVerifyPermissionsDC.h
//  Dressique
//
//  Created by andrea sponziello on 06/03/13.
//
//

#import <Foundation/Foundation.h>

@interface SHPVerifyPermissionsDC : NSObject

@property (nonatomic, strong) NSMutableData *receivedData;
//@property (nonatomic, assign) id <SHPProductDCDelegate> delegate;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, assign) NSInteger statusCode;

@end
