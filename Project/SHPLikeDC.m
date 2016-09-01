//
//  SHPLikeDC.m
//  Shopper
//
//  Created by andrea sponziello on 25/08/12.
//
//

#import "SHPLikeDC.h"
#import "SHPServiceUtil.h"
#import "SHPProduct.h"
#import "SHPStringUtil.h"
#import "SHPUser.h"
#import "SHPConstants.h"

@implementation SHPLikeDC

@synthesize receivedData;
@synthesize likeDelegate;
@synthesize serviceUrl;
@synthesize serviceName;
@synthesize product;
@synthesize statusCode;

-(void)sendCommand:(NSString *)command toProduct:(SHPProduct *)__product withUser:(SHPUser *)__user {
    self.serviceName = command;
    
    self.product = __product;
    
    // Create the request.
    if ([command isEqualToString:SHPCONST_LIKE_COMMAND]) {
        self.serviceUrl = [SHPServiceUtil serviceUrl:@"service.like"];
    } else {
        self.serviceUrl = [SHPServiceUtil serviceUrl:@"service.unlike"];
    }
    
    NSLog(@"self.serviceUrl: %@", self.serviceUrl);
    
    NSString *_url = self.serviceUrl;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    
    if (__user) {
        NSLog(@"Operation with User %@", __user.username);
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [request setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
//        NSDictionary* headers = [request allHTTPHeaderFields];
//        for (NSString *key in headers) {
//            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
//        }
    } else {
        NSLog(@"Operation without User");
    }
    
    NSString *postString = [[NSString alloc] initWithFormat:@"id=%@&class=%@", [SHPStringUtil urlParamEncode:self.product.oid], [SHPStringUtil urlParamEncode:@"Product"]];
    NSLog(@"POST Query: %@", postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.currentConnection = conn;
    if (conn) {
        self.receivedData = [[NSMutableData alloc] init];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//        NSLog(@"Connection successfull!");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

-(void)like:(SHPProduct *)p  withUser:(SHPUser *)user{
    [self sendCommand:SHPCONST_LIKE_COMMAND toProduct:p withUser:user];
}

-(void)unlike:(SHPProduct *)p  withUser:(SHPUser *)user{
    [self sendCommand:SHPCONST_UNLIKE_COMMAND toProduct:p withUser:user];
}

- (void)cancelConnection {
    [self.currentConnection cancel];
    self.currentConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


// CONNECTION DELEGATE




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSLog(@"Response ready to be received.");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
//    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
//    for (NSString *key in headers) {
//        NSLog(@"field: %@ value: %@", key, [headers objectForKey:key]);
//    }
    int code = [(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.likeDelegate) {
        [self.likeDelegate likeDCErrorForProduct:self.product withCode:@"900"];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    
    //NSString* text;
	//text = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding]; //NSUTF8StringEncoding];
    
    //NSLog(@"Response: %@", responseString);
    
    if (self.statusCode >= 400 && self.statusCode <500) {
        NSLog(@"HTTP Error %d", self.statusCode);
        NSString *code_s = [[NSString alloc] initWithFormat:@"%d", self.statusCode];
        if (self.likeDelegate) {
            [self.likeDelegate likeDCErrorForProduct:self.product withCode:code_s];
        }
        return;
    }
    if (self.likeDelegate) {
        if([self.serviceName isEqualToString:SHPCONST_LIKE_COMMAND]) {
            if([self.likeDelegate respondsToSelector:@selector(likeDCLiked:)]) {
                [self.likeDelegate likeDCLiked:self.product];
            } else {
                NSLog(@"Error: not responding to selector likeDCLiked:");
            }
        } else if([self.serviceName isEqualToString:SHPCONST_UNLIKE_COMMAND]) {
            if([self.likeDelegate respondsToSelector:@selector(likeDCUnliked:)]) {
                [self.likeDelegate likeDCUnliked:product];
            } else {
                NSLog(@"Error: not responding to selector unliked:");
            }
        }
    }
}

@end
