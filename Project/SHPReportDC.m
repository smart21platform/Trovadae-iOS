//
//  SHPReportDC.m
//  Dressique
//
//  Created by andrea sponziello on 25/01/13.
//
//

#import "SHPReportDC.h"
#import "SHPServiceUtil.h"
#import "SHPUser.h"
#import "SHPStringUtil.h"
#import "SHPConnectionsController.h"

@implementation SHPReportDC

@synthesize receivedData;
@synthesize theConnection;
@synthesize delegate;

-(void)sendReportForObject:(NSString *)objectType withId:(NSString *)objectId withAbuseType:(NSInteger)abuseType withText:(NSString *)abuseText withUser:(SHPUser *)__user {
    
    NSString *serviceURL = [SHPServiceUtil serviceUrl:@"service.report"];
    NSLog(@"Report serviceUrl: %@", serviceURL);
    
    NSString *_url = serviceURL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:20.0];
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
    
    NSString *abuseTypeAsString = [NSString stringWithFormat:@"%d", abuseType];
    
    NSString *postString = [[NSString alloc] initWithFormat:@"objectId=%@&objectType=%@&abuseType=%@&text=%@", [SHPStringUtil urlParamEncode:objectId], [SHPStringUtil urlParamEncode:objectType], [SHPStringUtil urlParamEncode:abuseTypeAsString], [SHPStringUtil urlParamEncode:abuseText]];
    NSLog(@"POST Query: %@", postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.theConnection = conn;
    if (conn) {
        self.receivedData = [[NSMutableData alloc] init];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        //        NSLog(@"Connection successfull!");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

- (void)cancelConnection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.theConnection cancel];
    self.theConnection = nil;
    self.delegate = nil;
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
//    int code = [(NSHTTPURLResponse*) response statusCode];
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
    if (self.delegate) {
        [self.delegate didFinishReport:self withError:error];
    }
//    [self.likeDelegate likeDCErrorForProduct:self.product withCode:@"900"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    
    //NSString* text;
	//text = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding]; //NSUTF8StringEncoding];
    
    //NSLog(@"Response: %@", responseString);
    
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(didFinishReport:withError:)]) {
            [self.delegate didFinishReport:self withError:nil];
        } else {
            NSLog(@"(SHPReportDC) Error: self.connectionsControllerDelegate %@ not responding to selector didFinishConnection:withError:", self.delegate);
        }
    }
}

@end
