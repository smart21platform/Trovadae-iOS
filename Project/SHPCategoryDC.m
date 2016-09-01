//
//  SHPCategoryDC.m
//  Shopper
//
//  Created by andrea sponziello on 09/08/12.
//
//

#import "SHPCategoryDC.h"
#import "SHPServiceUtil.h"
#import "SHPCategory.h"

@implementation SHPCategoryDC

@synthesize receivedData;
@synthesize delegate;
@synthesize theConnection;


- (void)getAll {
    //    NSLog(@"Downloading all categories...");
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.categories"];
    
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *__url = [NSString stringWithFormat:@"%@?locale=%@", serviceUrl, langID];
    //    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url);
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:__url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
   
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

-(void)connectionFailed {
//    NSString *stringArray = [[NSString alloc] initWithFormat:@"connectionFailed"];
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:stringArray delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
    
    NSLog(@"Error!");
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
    
    // Create and return the custom domain error.
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"network error while loading categories."};
    // Create the error.
    NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self.delegate categoriesLoaded:nil error:theError];
    //    [self.delegate networkError];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSString *stringArray = [[NSString alloc] initWithFormat:@"didReceiveResponse %@",response];
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:stringArray delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
    //    NSLog(@"Response ready to be received.");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
//    NSString *stringArray = [[NSString alloc] initWithFormat:@"didReceiveData %@",data];
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:stringArray delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
    //    NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    NSString *stringArray = [[NSString alloc] initWithFormat:@"didFailWithError %@",error];
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:stringArray delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSString *stringArray = [[NSString alloc] initWithFormat:@"connectionDidFinishLoading %@",self.delegate];
//    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:stringArray delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [userAdviceAlert show];
    //NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
    //NSLog(@"response: %@", responseString);
    NSLog(@"FINISHED LOADING CATEGORIES!");
    NSArray *categories = [SHPCategoryDC jsonToCategories:self.receivedData];
    
    if (categories) {
        [self.delegate categoriesLoaded:categories error:nil];
    }
    else {
        [self connectionFailed];
    }
    
}

+ (NSArray *)jsonToCategories:(NSData *)jsonData {
    NSMutableArray *categories = [[NSMutableArray alloc] init ];
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    NSLog(@"ERROR in parsing categories? Error = %@", error);
    if (error) {
        NSLog(@"RETURNING NIL CATEGORIES");
        return nil;
    }
    NSLog(@"RETURNING RESPONS JSON CATEGORIES: %@", objects);
    //    NSString *channel = [objects valueForKey:@"channel"];
    //    NSLog(@"Channel: %@", channel);
    //    NSString *date = [objects valueForKey:@"date"];
    //    NSLog(@"Date: %@", date);
    NSArray *items = [objects valueForKey:@"items"];
    
    for(NSDictionary *item in items) {
        
        NSString *oid = [item valueForKey:@"id"];
        NSString *name = [item valueForKey:@"name"];
        NSString *label = [item valueForKey:@"label"];
        NSString *otype = [item valueForKey:@"otype"];
        NSString *parent = [item valueForKey:@"parent"];
        NSString *allowUserContentCreation = [item valueForKey:@"allowUserContentCreation"];
        NSInteger visibility = [[item valueForKey:@"visibility"] intValue];
        
        SHPCategory *c = [[SHPCategory alloc] init];
        c.oid = oid;
        c.name = name;
        c.label = label;
        c.type = otype;
        c.parent = parent;
        c.allowUserContentCreation = allowUserContentCreation;
        c.visibility = visibility;
        [categories addObject:c];
    }
    NSLog(@"Categories count: %lu", (unsigned long)[categories count]);
    return categories;
}

@end

//- (void)getAll {
////    NSLog(@"Downloading all categories...");
//    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.categories"];
//    
//    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
//    NSString *__url = [NSString stringWithFormat:@"%@?locale=%@", serviceUrl, langID];
////    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"url: %@", __url);
//    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:__url]
//                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                          timeoutInterval:60.0];
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
//
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
////    [self.delegate networkError];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
////    NSLog(@"Response ready to be received.");
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
////    NSLog(@"Received data.");
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
//    NSLog(@"response: %@", responseString);
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
//    
////    NSString *channel = [objects valueForKey:@"channel"];
////    NSLog(@"Channel: %@", channel);
////    NSString *date = [objects valueForKey:@"date"];
////    NSLog(@"Date: %@", date);
//    NSArray *items = [objects valueForKey:@"items"];
//    
//    for(NSDictionary *item in items) {
//        NSString *name = [item valueForKey:@"label"];
//        NSString *oid = [item valueForKey:@"id"];
//        
//        SHPCategory *c = [[SHPCategory alloc] init];
//        c.oid = oid;
//        c.name = name;
//        [categories addObject:c];
//    }
//    
//    // remove root categories "women" and "men" from categories
////    for (int i = 0; i < categories.count; i++) {
////        SHPCategory *cat = (SHPCategory *)[categories objectAtIndex:i];
////        if ([cat.oid isEqualToString:@"/women"] || [cat.oid isEqualToString:@"/men"] ) {
////            [categories removeObjectAtIndex:i];
////        }
////    }
//    NSLog(@"Categories count: %d", [categories count]);
//    return categories;
//}
//
//@end
