//
//  SHPGoogleReferenceRequest.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 10/03/14.
//
//

#import <Foundation/Foundation.h>

typedef void (^SHPGoogleReferenceHandler)(NSDictionary *object, NSError *error);

@interface SHPGoogleReferenceRequest : NSObject

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSString *api_key;
@property (nonatomic, copy) SHPGoogleReferenceHandler handler;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *connection;

-(void)download:(NSString *)reference completionHandler:(SHPGoogleReferenceHandler)handler;
/*
 [downloader downloadImage: @"http://..." completionHandler: ^(NSString *imageURL, NSError *error) {
 if (!error) {
 NSLog(@"Image retriving successfull.");
 }
 }
 */

- (void)cancelDownload;

@end
