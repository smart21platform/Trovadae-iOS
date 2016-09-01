//
//  SHPProductUpdateDC.m
//  San Vito dei Normanni
//
//  Created by Andrea Sponziello on 24/07/14.
//
//

#import "SHPProductUpdateDC.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"

@implementation SHPProductUpdateDC

-(void)update:
        (NSString *)productId
        title:(NSString *)title
  description:(NSString *)description
        price:(NSString *)price
   startprice:(NSString *)startPrice
    telephone:(NSString *)telephone
    startDate:(NSString *)startDate
      endDate:(NSString *)endDate {
    NSString *actionUrl = [[SHPServiceUtil serviceUrl:@"service.products"] stringByAppendingString:@"/update"];
    
    NSLog(@"actionUrl: %@", actionUrl);
    
    NSString *_url = actionUrl;
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    [theRequest setHTTPMethod:@"POST"];
    
    
    NSString *postString = [[NSString alloc] initWithFormat:@"id=%@&title=%@&description=%@&startDate=%@&endDate=%@&price=%@&startPrice=%@&phone=%@", [SHPStringUtil urlParamEncode:productId], [SHPStringUtil urlParamEncode:title], [SHPStringUtil urlParamEncode:description], [SHPStringUtil urlParamEncode:startDate], [SHPStringUtil urlParamEncode:endDate], [SHPStringUtil urlParamEncode:price], [SHPStringUtil urlParamEncode:startPrice], [SHPStringUtil urlParamEncode:telephone]];
    NSLog(@"postString: %@", postString);
    [theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (self.applicationContext.loggedUser) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", self.applicationContext.loggedUser.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
        //        NSDictionary* headers = [theRequest allHTTPHeaderFields];
        //        for (NSString *key in headers) {
        //            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
        //        }
    } else {
        NSLog(@"ERROR: NO USER");
    }
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (theConnection) {
        self.receivedData = [NSMutableData data];
    } else {
        NSLog(@"Could not connect to the network");
    }
}

-(void)connectionFailed:(NSError *)error {
    
    NSLog(@"(SHPProductUploader) Connection Error!");
    self.receivedData = nil;
    if (self.delegateViewController && [self.delegateViewController respondsToSelector:@selector(itemUpdatedWithError:)]) {
        [self.delegateViewController performSelector:@selector(itemUpdatedWithError:) withObject:error];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// CONNECTION DELEGATE

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response ready to be received.");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
    
    NSLog(@">>>>> response: %@", responseString);
    
    if (self.delegateViewController && [self.delegateViewController respondsToSelector:@selector(itemUpdatedWithError:)]) {
        [self.delegateViewController performSelector:@selector(itemUpdatedWithError:) withObject:nil];
    }
    
}

@end
