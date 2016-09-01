//
//  SHPNewNotificationsCountDC.m
//  Ciaotrip
//
//  Created by andrea sponziello on 24/01/14.
//
//

#import "SHPNewNotificationsCountDC.h"
#import "SHPUser.h"
#import "SHPServiceUtil.h"

@implementation SHPNewNotificationsCountDC

-(void)getCountForUser:(SHPUser *)user completionHandler:(SHPNewNotificationsCountDCCompletionHandler)handler {
    NSLog(@"getCountForUser: %@",user.httpBase64Auth);
    
    self.completionHandler = handler;
    
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.notifications.count"];
    
    NSString *username;
    if (user) {
        username = [user.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else {
        username = @"";
    }
    
    NSString *__url = [NSString stringWithFormat:@"%@", serviceUrl];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    if (user) {
        NSLog(@"URL COUNT NOTIFY %@", __url);
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
        NSLog(@"NO USER");
    }
    
    // eventually cancel the current running connection
    if(self.theConnection != nil) {
        [self.theConnection cancel];
    }
    // create the connection with the request
    // and start loading the data
    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connecion failed!");
        NSError *error = [[NSError alloc] init];
        [self connectionFailed:error];
    }
}

- (void)cancelDownload
{
    NSLog(@"(SHPSendTokenDC) Canceling current connection: %@", self.theConnection);
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
}

-(void)connectionFailed:(NSError *)error {
    NSLog(@"(SHPSendTokenDC) Connection Error!");
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
    self.completionHandler(0, error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSLog(@"(SHPSendTokenDC) dev token successfully sent");
    self.theConnection = nil;
//    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    //    NSLog(@"response: %@", responseString);
    NSInteger count = [self jsonToCount:self.receivedData];
    self.completionHandler(count, nil);
}

- (NSInteger)jsonToCount:(NSData *)jsonData {
    NSInteger count = 0;
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    
    count = [[objects valueForKey:@"newNotifications"] integerValue];
    
    return count;
}

@end
