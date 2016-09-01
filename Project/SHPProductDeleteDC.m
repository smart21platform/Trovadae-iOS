//
//  SHPProductDeleteDC.m
//  Dressique
//
//  Created by andrea sponziello on 17/05/13.
//
//

#import "SHPProductDeleteDC.h"
#import "SHPServiceUtil.h"
#import "SHPUser.h"

@implementation SHPProductDeleteDC

- (void)deleteProduct:(NSString *)oid withUser:(SHPUser *)__user
{
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.products"];
    NSString *__url = [NSString stringWithFormat:@"%@/%@/delete", serviceUrl, oid];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
        NSLog(@"NO USER");
    }
    

    if(self.theConnection != nil) {
        [self.theConnection cancel];
    }
    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        [self connectionFailed];
    }
}

- (void)cancelDownload
{
    NSLog(@"(SHPProductDC) Canceling current connection: %@", self.theConnection);
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
}

-(void)connectionFailed
{
    NSLog(@"(SHPProductDC) Connection Error!");
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
    if (self.delegate) {
        [self.delegate networkError];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response ready to be received.");
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Received data.");
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"(SHPProductDC) ConnectionDidFinishLoading with code %d", (int)self.statusCode);
    self.theConnection = nil;
    if (self.statusCode >= 400) {
        [self connectionFailed];
        return;
    }
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    if (self.delegate) {
        [self.delegate productDeleted:responseString];
    }
}

@end
