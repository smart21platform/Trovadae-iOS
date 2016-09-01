//
//  SHPVerifyUploadPermissionsDC.m
//  AnimaeCuore
//
//  Created by Dario De Pascalis on 12/06/14.
//
//

#import "SHPVerifyUploadPermissionsDC.h"
#import "SHPServiceUtil.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"


@implementation SHPVerifyUploadPermissionsDC


-(void)verifyUploadPermission {
    NSString *__url = [[SHPServiceUtil serviceUrl:@"service.products"] stringByAppendingString:@"/add"];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    SHPUser *__user = self.applicationContext.loggedUser;
    NSLog(@"__user: %@", __user);
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
       [self callerDelegate:NO];
        return;
    }
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        [self callerDelegate:NO];
    }
}

-(void)connectionFailed:(NSError *)error {
    NSLog(@"(SHPShopDetailViewController) Connection Error!");
    self.receivedData = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self callerDelegate:NO];
    // ...
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response ready to be received.: %@", response);
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    if (code >= 400) {
        NSLog(@"Not allowed to upload ");
        [self callerDelegate:NO];
        
    } else {
        NSLog(@"Allowed to upload");
        [self callerDelegate:YES];
    }
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    NSLog(@"Received data.");
    //    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.theConnection = nil;
}

-(void)callerDelegate:(BOOL)permission{
    NSLog(@"calling [permissionCheck]");
    [self.delegate permissionCheck:permission];
}

@end
