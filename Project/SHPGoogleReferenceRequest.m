//
//  SHPGoogleReferenceRequest.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 10/03/14.
//
//

#import "SHPGoogleReferenceRequest.h"

@implementation SHPGoogleReferenceRequest

-(void)download:(NSString *)__reference completionHandler:(SHPGoogleReferenceHandler)__handler {
    NSLog(@"DOWNLOADING REFERENCE....");
    self.handler = __handler;
    self.reference = __reference;
    self.receivedData = [NSMutableData data];
    
    // https://maps.googleapis.com/maps/api/place/details/json?reference=CmRYAAAAciqGsTRX1mXRvuXSH2ErwW-jCINE1aLiwP64MCWDN5vkXvXoQGPKldMfmdGyqWSpm7BEYCgDm-iv7Kc2PF7QA7brMAwBbAcqMr5i1f4PwTpaovIZjysCEZTry8Ez30wpEhCNCXpynextCld2EBsDkRKsGhSLayuRyFsex6JA6NPh9dyupoTH3g&sensor=true&key=AddYourOwnKeyHere
    
    NSString *_url = [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", __reference, self.api_key];
    NSLog(@"downloading google reference %@", _url);
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:_url]];
    
    // create the connection with the request
    // and start loading the data
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (self.connection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
//        [self connectionFailed];
    }
}

- (void)cancelDownload
{
    [self.connection cancel];
    self.connection = nil;
    self.receivedData= nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
    //    NSLog(@"REDIRECTION!! %@", redirectResponse);
    NSURLRequest *newRequest = request;
    return newRequest;
}

//-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//    NSInteger statusCode_ = [httpResponse statusCode];
//    if (statusCode_ >= 200) {
//        self.expectedDataSize = [httpResponse expectedContentLength];
//    }
//}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"image download failed! %@", [NSString stringWithFormat:@"%@ - %@ - %@ - %@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]]);
	// Clear the activeDownload property to allow later attempts
    self.receivedData = nil;
    
    // Release the connection now that it's finished
    self.connection = nil;
    
    // Create the error.
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"signin error"};
    NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
    self.handler(nil, theError);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    //NSLog(@"response: %@", responseString);
    
    NSError* error;
    NSDictionary *google_object = [NSJSONSerialization
                             JSONObjectWithData:self.receivedData
                             options:kNilOptions
                             error:&error];
    NSLog(@"ERROR in parsing categories %@", error);
    
    self.handler(google_object, error);
}

@end
