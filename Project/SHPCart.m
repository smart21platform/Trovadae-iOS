//
//  SHPCart.m
//  Eurofood
//
//  Created by Dario De Pascalis on 03/09/14.
//
//

#import "SHPCart.h"
#import "SHPServiceUtil.h"
#import "SHPUser.h"

@implementation SHPCart


//-(void)addProductToCart:(SHPObjectCart *)objectToCart{
//    NSURLRequest *request = [NSURLRequest requestWithURL:
//                             [NSURL URLWithString:@"url"]];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response,
//                                               NSData *data,
//                                               NSError *connectionError) {
//                               // handle response
//                           }];
//}

//http://www.iosmanual.com/tutorials/ios-network-nsurlconnection/

//- (void)2addProductToCart:(NSString *)idProduct quantityProduct:(int)quantityProduct price:(float)priceProduct withUser:(SHPUser *)__user
//{
//    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.functions"];
//    NSLog(@" --------------- > url: %@", serviceUrl);
//    NSString *addProductUrl = [[NSString alloc] initWithFormat:@"%@/addProductToChart", serviceUrl];
//    NSLog(@" --------------- > url: %@", addProductUrl);
//    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
//    NSString *__url = [NSString stringWithFormat:@"%@?productId=%@&quantity=%d&price=%f&locale=%@", addProductUrl, idProduct, quantityProduct, priceProduct, langID];
//    
//    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url]
//                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                          timeoutInterval:60.0];
//    if (__user) {
//        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
//        [urlRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
//    } else {
//        //        NSLog(@"NO USER");
//    }
//    
//    NSLog(@" --------------- > url: %@", __url);
//    //NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:__url]];
//    NSURLResponse * response = nil;
//    NSError * error = nil;
//    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
//                                          returningResponse:&response
//                                                      error:&error];
//    if (!data) {
//        NSLog(@"%s: sendSynchronousRequest error: %@", __FUNCTION__, error);
//        return;
//    } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//        if (statusCode != 200) {
//            NSLog(@"%s: sendSynchronousRequest status code != 200: response = %@", __FUNCTION__, response);
//            return;
//        }
//    }
//    
//    NSError *parseError = nil;
//    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
//    if (!dictionary) {
//        NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        return;
//    }
//    NSLog(@"dictionary: %@", dictionary);
//
//    NSString *errore = [[NSString alloc] initWithFormat:@"ESITO ADD: %@",error];
//    [self.delegate responseAddProductToCart:errore];
//}


//- (void)getAll {
//    //    NSLog(@"Downloading all categories...");
//    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.categories"];
//    
//    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
//    NSString *__url = [NSString stringWithFormat:@"%@?locale=%@", serviceUrl, langID];
//    //    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"url: %@", __url);
//    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:__url]
//                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                            timeoutInterval:60.0];
//    // eventually cancel the current running connection
//    if(self.theConnection != nil) {
//        [self.theConnection cancel];
//    }
//    // create the connection with the request
//    // and start loading the data
//    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    if (self.theConnection) {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//        self.receivedData = [[NSMutableData alloc] init];
//    } else {
//        // Inform the user that the connection failed.
//        [self connectionFailed];
//    }
//}

//-(void)connectionFailed {
//    NSLog(@"Error!");
//    [self.theConnection cancel];
//    self.theConnection = nil;
//    self.receivedData = nil;
//    
//    // Create and return the custom domain error.
//    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"network error while loading categories."};
//    // Create the error.
//    NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    
//    [self.delegate categoriesLoaded:nil error:theError];
//    //    [self.delegate networkError];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    //    NSLog(@"Response ready to be received.");
//    // This method is called when the server has determined that it
//    // has enough information to create the NSURLResponse.
//    
//    // It can be called multiple times, for example in the case of a
//    // redirect, so each time we reset the data.
//    
//    // receivedData is an instance variable declared elsewhere.
//    [self.receivedData setLength:0];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    //    NSLog(@"Received data.");
//    // Append the new data to receivedData.
//    // receivedData is an instance variable declared elsewhere.
//    [self.receivedData appendData:data];
//}
//
//- (void)connection:(NSURLConnection *)connection
//  didFailWithError:(NSError *)error
//{
//    NSLog(@"Connection failed! Error - %@ %@",
//          [error localizedDescription],
//          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
//    [self connectionFailed];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
//    //NSLog(@"response: %@", responseString);
//    NSLog(@"FINISHED LOADING CATEGORIES!");
//    NSArray *categories = [self jsonToCategories:self.receivedData];
//    if (categories) {
//        [self.delegate categoriesLoaded:categories error:nil];
//    } else {
//        [self connectionFailed];
//    }
//    
//}
//
//- (NSArray *)jsonToCategories:(NSData *)jsonData {
//    NSMutableArray *categories = [[NSMutableArray alloc] init ];
//    NSError* error;
//    NSDictionary *objects = [NSJSONSerialization
//                             JSONObjectWithData:jsonData
//                             options:kNilOptions
//                             error:&error];
//    NSLog(@"ERROR in parsing categories %@", error);
//    if (error) {
//        NSLog(@"RETURNING NIL CATEGORIES");
//        return nil;
//    }
//    NSLog(@"RETURNING RESPONS JSON CATEGORIES: %@", objects);
//    //    NSString *channel = [objects valueForKey:@"channel"];
//    //    NSLog(@"Channel: %@", channel);
//    //    NSString *date = [objects valueForKey:@"date"];
//    //    NSLog(@"Date: %@", date);
//    NSArray *items = [objects valueForKey:@"items"];
//    
//    for(NSDictionary *item in items) {
//        
//        NSString *oid = [item valueForKey:@"id"];
//        NSString *name = [item valueForKey:@"name"];
//        NSString *label = [item valueForKey:@"label"];
//        NSString *otype = [item valueForKey:@"otype"];
//        NSString *parent = [item valueForKey:@"parent"];
//        
//        SHPCategory *c = [[SHPCategory alloc] init];
//        c.oid = oid;
//        c.name = name;
//        c.label = label;
//        c.type = otype;
//        c.parent = parent;
//        [categories addObject:c];
//    }
//    
//    NSLog(@"Categories count: %d", [categories count]);
//    return categories;
//}

- (void)addProductToCart:(NSString *)idProduct quantityProduct:(int)quantityProduct price:(float)priceProduct withUser:(SHPUser *)__user
{
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.functions"];
    NSString *addProductUrl = [[NSString alloc] initWithFormat:@"%@/addProductToChart", serviceUrl];
    //NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *__url = [NSString stringWithFormat:@"%@?productId=%@&quantity=%d&price=%f", addProductUrl, idProduct, quantityProduct, priceProduct];
    
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
        //        NSLog(@"NO USER");
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

-(void)connectionFailed {
    NSLog(@"(SHPProductDC) Connection Error!");
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // NSLog(@"Response ready to be received.");
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
    [error localizedDescription],
    [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed];
    NSString *errore = [[NSString alloc] initWithFormat:@"%@",error];
    [self.delegate alertError:errore];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    NSLog(@"(SHPProductDC) ConnectionDidFinishLoading with code %d", self.statusCode);
    NSLog(@"(SHPProductDeleteDC) Product deleted");
    self.theConnection = nil;
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    [self.delegate responseAddProductToCart:responseString];
    
    
    //NSLog(@"response: %@", responseString);
    //    if (responseString.length > 0) {
    //        NSArray *products = [SHPProductDC jsonToProducts:self.receivedData];
    //        if (!products) {
    //            [self connectionFailed];
    //            return;
    //        }
    //        //        NSLog(@"PRODUCTS ARE %@ WITH COUNT %d", products, products.count);
    //        if (self.delegate) {
    //            if ([self.delegate respondsToSelector:@selector(loaded:)]) {
    //                // in realta dovrebbe sempre rispondere in quanto formalmente non si potrebbe assegnare al delegate un oggetto di tipo differente da uno che implementa il protocollo <SHPProductDCDelegate>!
    //                NSLog(@"PRODUCTS LOADED COUNT = %d", products.count);
    //                [self.delegate loaded:products];
    //            } else {
    //                NSLog(@"GRAVE ERROR on SHPProductDC! self.delegate %@ does not respond to selector loaded:", self.delegate);
    //                NSLog(@"Calling networkError for user recovering this GRAVE ERROR!");
    //                [self connectionFailed];
    //            }
    //        }
    //    }
    //    else {
    //        NSLog(@"SHPProductDC! >>>> responseString.length = 0!");
    //        [self connectionFailed];
    //    }
}


@end
