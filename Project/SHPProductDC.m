//
//  SHPProductsDC.m
//  BirdWatching
//
//  Created by andrea sponziello on 26/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPProductDC.h"
#import "SHPProduct.h"
#import "SHPProductDCDelegate.h"
#import "SHPServiceUtil.h"
#import <CoreLocation/CoreLocation.h>
#import "SHPUser.h"
#import "SHPStringUtil.h"

@implementation SHPProductDC

@synthesize receivedData;
@synthesize delegate;
@synthesize theConnection;
@synthesize statusCode;

// location and user are optional
- (void)searchById:(NSString *)oid location:(CLLocation *)location withUser:(SHPUser *)__user {
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.products"];
    
    NSString *locationQuery = @"";
    if(location) {
        double lat = location.coordinate.latitude;
        double lon = location.coordinate.longitude;
        locationQuery = [[NSString alloc] initWithFormat:@"?lat=%f&lon=%f", lat, lon];
    }
    
    NSString *__url = [NSString stringWithFormat:@"%@/%@%@", serviceUrl, oid, locationQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"-----> url: %@", __url_enc);
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

- (void)search:(CLLocation *)location categoryId:(NSString *)categoryId page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
    //    NSLog(@"Searching products...");
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.products"];
    
    NSString *categoryQuery = @"";
    if(categoryId) {
        //NSString *catEscaped = [categoryId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //categoryQuery = [[NSString alloc] initWithFormat:@"&category=%@", catEscaped];
        
        categoryQuery = [[NSString alloc] initWithFormat:@"&category=%@", categoryId];
    }
    
    NSString *locationQuery = @"";
    if(location) {
        double lat = location.coordinate.latitude;
        double lon = location.coordinate.longitude;
        locationQuery = [[NSString alloc] initWithFormat:@"&lat=%f&lon=%f", lat, lon];
    }
    
    NSString *pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@%@", serviceUrl, locationQuery, categoryQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
        //        NSDictionary* headers = [theRequest allHTTPHeaderFields];
        //        for (NSString *key in headers) {
        //            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
        //        }
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

-(void)timelineForUser:(SHPUser *)__user location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize {
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.timeline"];
    
    NSString *locationQuery = @"";
    if(location) {
        double lat = location.coordinate.latitude;
        double lon = location.coordinate.longitude;
        locationQuery = [[NSString alloc] initWithFormat:@"lat=%f&lon=%f", lat, lon];
    }
    
    NSString *pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@", serviceUrl, locationQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"timelineForUser url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
        //        NSDictionary* headers = [theRequest allHTTPHeaderFields];
        //        for (NSString *key in headers) {
        //            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
        //        }
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


-(void)searchByText:(NSString *)text location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
    NSLog(@"USER::::: %@ %@", __user.username, __user.httpBase64Auth);
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.search.products"];
    
    NSString *textQuery = @"";
    if(text) {
        //NSString *textEscaped = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        textQuery = [[NSString alloc] initWithFormat:@"&q=%@", text];//textEscaped
    }
    
    NSString *locationQuery = @"";
    if(location) {
        double lat = location.coordinate.latitude;
        double lon = location.coordinate.longitude;
        locationQuery = [[NSString alloc] initWithFormat:@"&lat=%f&lon=%f", lat, lon];
    }
    
    NSString *pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@%@", serviceUrl, textQuery, locationQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
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

- (void)searchByShop:(NSString *)shopId page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
    NSLog(@"Searching products By shop ID...");
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.products"];
    
    NSString *shopQuery = @"";
    if(shopId) {
        //        NSString *shopIdEscaped = [shopId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //        shopQuery = [[NSString alloc] initWithFormat:@"&shop=%@", shopIdEscaped];
        shopQuery = [[NSString alloc] initWithFormat:@"&shop=%@", shopId];
    }
    
    NSString *pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@", serviceUrl, shopQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
        //        NSDictionary* headers = [theRequest allHTTPHeaderFields];
        //        for (NSString *key in headers) {
        //            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
        //        }
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

-(void)productsCreatedBy:(SHPUser *)user page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
//    NSLog(@"Searching products creaded by...on delegate %@", self.delegate);
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.products"];
    
    //NSString *userQuery = [[NSString alloc] initWithFormat:@"&createdby=%@", [user.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *userQuery = [[NSString alloc] initWithFormat:@"&createdby=%@", user.username];
    NSString *pageQuery = @"";
    if(page>0 && pageSize>0){
        pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    }
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@", serviceUrl, userQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    if (__user) {
        NSLog(@"Basic %@", __user.httpBase64Auth);
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
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

-(void)productsLikedTo:(SHPUser *)user page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
    //    NSLog(@"SELF %@", self);
    NSLog(@"Searching products liked by...on delegate %@", self.delegate);
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.products"];
    
    //NSString *userQuery = [[NSString alloc] initWithFormat:@"&likedby=%@", [user.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *userQuery = [[NSString alloc] initWithFormat:@"&likedby=%@", user.username];
    NSString *pageQuery = @"";
    if(page>0 && pageSize>0){
        pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    }
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@", serviceUrl, userQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSLog(@"Basic %@", __user.httpBase64Auth);
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        NSLog(@"theRequest %@", theRequest);
        
                NSDictionary* headers = [theRequest allHTTPHeaderFields];
                for (NSString *key in headers) {
                    NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
                }
    } else {
        NSLog(@"NO USER");
    }
    if(self.theConnection != nil) {
        [self.theConnection cancel];
    }
    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
     NSLog(@"self.theConnection %@", self.theConnection);
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
        NSLog(@"receivedData %@", self.receivedData);
    } else {
        // Inform the user that the connection failed.
        [self connectionFailed];
    }
}

- (void)productDelete:(NSString *)oid withUser:(SHPUser *)user {
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.products"];
    NSString *__url = [NSString stringWithFormat:@"%@/%@/delete", serviceUrl, oid];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];

    if (user) {
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
        [self connectionFailed];
    }
}

- (void)cancelDownload
{
    NSLog(@"(SHPProductDC) Canceling current connection: %@", self.theConnection);
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
    self.delegate = nil;
}

-(void)connectionFailed {
    NSLog(@"(SHPProductDC) Connection Error!");
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(networkError)]) {
            [self.delegate performSelector:@selector(networkError)];
        } else {
            NSLog(@"SHPProductDC: self.delegate -->> %@ <<-- does not respond to selector 'networkError'!", self.delegate);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //    NSLog(@"Response ready to be received.");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
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
  didFailWithError:(NSError *)error
{
    NSLog(@"[%@] Connection failed! Error - %@ %@",
          NSStringFromClass([self class]), [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.theConnection = nil;
     NSLog(@"Error %d. Not processing response.", (int)self.statusCode);
    if (self.statusCode >= 400) {
        [self connectionFailed];
        return;
    }
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];

    if (responseString.length > 0) {
        NSArray *products = [SHPProductDC jsonToProducts:self.receivedData];

        if (!products) {
            [self connectionFailed];
            return;
        }
        
        if (self.delegate) {
            [self.delegate loaded:products];
//            if ([self.delegate respondsToSelector:@selector(loaded:)]) {
//                // in realta dovrebbe sempre rispondere in quanto formalmente non si potrebbe assegnare al delegate un oggetto di tipo differente da uno che implementa il protocollo <SHPProductDCDelegate>!
//                NSLog(@"PRODUCTS LOADED COUNT = %d", (int)products.count);
//                [self.delegate loaded:products];
//            } else {
//                NSLog(@"GRAVE ERROR on SHPProductDC! self.delegate %@ does not respond to selector loaded:", self.delegate);
//                NSLog(@"Calling networkError for user recovering this GRAVE ERROR!");
//                [self connectionFailed];
//            }
        }
    }
    else {
        NSLog(@"SHPProductDC! >>>> responseString.length = 0!");
        [self connectionFailed];
    }
}

+ (NSArray *)jsonToProducts:(NSData *)jsonData {
    NSMutableArray *products = [[NSMutableArray alloc] init ];
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    
    if (error) {
        NSLog(@"JSON ERROR.... %@", error);
        NSLog(@"Invalid Json! Returning nil");
        return nil;
    }
    
//    NSLog(@"TO JSON..%@",objects);
    
    //NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    // NSDictionary *creatureDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    
    
    NSArray *items = [objects valueForKey:@"items"];
    for(NSDictionary *item in items) {
        //        NSString *type = [item valueForKey:@"type"];
        NSString *name = [item valueForKey:@"name"];
        NSString *description = [item valueForKey:@"description"];
        NSString *brand = [item valueForKey:@"brand"];
        NSString *title = [item valueForKey:@"title"];
        NSString *category = [item valueForKey:@"category"];
        NSString *categoryLabel = [item valueForKey:@"categoryLabel"];
        NSString *shop = [item valueForKey:@"shop"];
        NSString *shopName = [item valueForKey:@"shopName"];
        NSString *currency = [item valueForKey:@"currency"];
        NSString *imageURL = [item valueForKey:@"imageURL"];
        NSString *distance = [item valueForKey:@"distance"];
        NSString *price = [item valueForKey:@"price"];
        NSString *startPrice = [item valueForKey:@"startPrice"];
        double shopLat = [[item valueForKey:@"shopLat"] doubleValue];
        double shopLon = [[item valueForKey:@"shopLon"] doubleValue];
        if([item valueForKey:@"lat"] && [item valueForKey:@"lat"]){
            shopLat = [[item valueForKey:@"lat"] doubleValue];
            shopLon = [[item valueForKey:@"lon"] doubleValue];
        }
        NSString *city = [item valueForKey:@"shopCity"];
        NSInteger likesCount = [[item valueForKey:@"likesCount"] integerValue];
        BOOL userLiked = [[item valueForKey:@"userLiked"] isEqualToString:@"YES"] ? YES : NO;
        NSDate *createdOn = [SHPStringUtil parseDateRFC822:[item valueForKey:@"createdOn"]];
        NSString *createdBy = [item valueForKey:@"createdBy"];
        NSArray *width_height = [[item valueForKey:@"imageSize"] componentsSeparatedByString:@","];
        float imageWidth = [[width_height objectAtIndex:0] floatValue];
        float imageHeight = [[width_height objectAtIndex:1] floatValue];
        NSString *oid = [item valueForKey:@"id"];
        BOOL sponsored = NO;
        NSString *sponsored_string = [item valueForKey:@"sponsored"];
        if ([sponsored_string isEqualToString:@"true"]) {
            sponsored = YES;
        }
        NSDate *startDate = [SHPStringUtil parseDateRFC822:[item valueForKey:@"startDate"]];
        NSDate *endDate = [SHPStringUtil parseDateRFC822:[item valueForKey:@"endDate"]];
        NSString *categoryType = [item valueForKey:@"categoryOtype"];//[SHPProductDC getCategoryType:category dictionary:creatureDictionary];
        NSDictionary *properties = (NSDictionary *)[item valueForKey:@"properties"];
        
        //        NSString *phoneNumber = nil;
        //        NSDictionary *properties = (NSDictionary *)[item valueForKey:@"properties"];
        //        NSDictionary *phoneDictionary = (NSDictionary *)[properties valueForKey:@"phone"];
        //        NSArray *values = (NSArray *)[phoneDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            phoneNumber = [values objectAtIndex:0];
        //        }
        //        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        //
        //        NSString *available = nil;
        //        NSDictionary *availableDictionary = (NSDictionary *)[properties valueForKey:@"available"];
        //        values = (NSArray *)[availableDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            available = [values objectAtIndex:0];
        //        }
        //
        //        NSString *personalCod = nil;
        //        NSDictionary *codeDictionary = (NSDictionary *)[properties valueForKey:@"codEurofood"];
        //        values = (NSArray *)[codeDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            personalCod = [values objectAtIndex:0];
        //        }
        //
        //        NSString *orderable = nil;
        //        NSDictionary *orderableDictionary = (NSDictionary *)[properties valueForKey:@"orderable"];
        //        values = (NSArray *)[orderableDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            orderable = [values objectAtIndex:0];
        //        }
        //
        //        NSString *prezzosubunitario = nil;
        //        NSDictionary *prezzosubunitarioDictionary = (NSDictionary *)[properties valueForKey:@"prezzosubunitario"];
        //        values = (NSArray *)[prezzosubunitarioDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            prezzosubunitario = [values objectAtIndex:0];
        //        }
        //
        //        NSString *prezzosubunitariolistino = nil;
        //        NSDictionary *prezzosubunitariolistinoDictionary = (NSDictionary *)[properties valueForKey:@"prezzosubunitariolistino"];
        //        values = (NSArray *)[prezzosubunitariolistinoDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            prezzosubunitariolistino = [values objectAtIndex:0];
        //        }
        //
        //        NSString *prezzorivenditore = nil;
        //        NSDictionary *prezzorivenditorelistinoDictionary = (NSDictionary *)[properties valueForKey:@"prezzorivenditore"];
        //        values = (NSArray *)[prezzorivenditorelistinoDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            prezzorivenditore = [values objectAtIndex:0];
        //        }
        //
        //        NSString *codiceoriginale = nil;
        //        NSDictionary *codiceOriginaleDictionary = (NSDictionary *)[properties valueForKey:@"codice_originale"];
        //        values = (NSArray *)[codiceOriginaleDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            codiceoriginale = [values objectAtIndex:0];
        //        }
        //
        //        NSString *quickreference = nil;
        //        NSDictionary *quickReferenceDictionary = (NSDictionary *)[properties valueForKey:@"quick_reference"];
        //        values = (NSArray *)[quickReferenceDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            quickreference = [values objectAtIndex:0];
        //        }
        //
        //        NSString *urlpath = nil;
        //        NSDictionary *urlpathDictionary = (NSDictionary *)[properties valueForKey:@"url_path"];
        //        values = (NSArray *)[urlpathDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            urlpath = [values objectAtIndex:0];
        //        }
        //
        //
        //        NSString *unitamisura = nil;
        //        NSDictionary *unitamisuraDictionary = (NSDictionary *)[properties valueForKey:@"unitamisura"];
        //        values = (NSArray *)[unitamisuraDictionary valueForKey:@"values"];
        //        if (values.count > 0) {
        //            unitamisura = [values objectAtIndex:0];
        //        }
        
        SHPProduct *p = [[SHPProduct alloc] init];
        p.oid = oid;
        p.name = name;
        p.longDescription = description;
        p.distance = distance;
        p.shopLat = shopLat;
        p.shopLon = shopLon;
        p.price = price;
        p.startprice = startPrice;
        p.category = category;
        p.title = title;
        p.categoryLabel = categoryLabel;
        p.categoryType = categoryType;
        p.brand = brand;
        p.shop = shop;
        p.shopName = shopName;
        p.currency = currency;
        p.imageURL = imageURL;
        p.userLiked = userLiked;
        p.likesCount = likesCount;
        p.createdOn = createdOn;
        p.createdBy = createdBy;
        p.imageWidth = imageWidth;
        p.imageHeight = imageHeight;
        p.startDate = startDate;
        p.endDate = endDate;
        p.city = city;
        p.sponsored = sponsored;
        p.properties = properties;
        
        //        p.phoneNumber = phoneNumber;
        //        p.available = available;
        //        p.personalCod = personalCod;
        //        p.orderable = orderable;
        //        p.prezzorivenditore = prezzorivenditore;
        //        p.prezzosubunitario = prezzosubunitario;
        //        p.prezzosubunitariolistino = prezzosubunitariolistino;
        //        p.unitamisura = unitamisura;
        //        p.codiceOriginale = codiceoriginale;
        //        p.quickReference = quickreference;
        //        p.urlPath = urlpath;
        [products addObject:p];
    }
    return products;
}


//+(NSString *)getCategoryTypePlist:(NSString *)category dictionary:(NSDictionary *)dictionary{
//    NSArray *arrayCategories = [dictionary objectForKey:@"Categories"];
//    NSLog(@"CATEGORIES: %@",arrayCategories);
//    for(NSDictionary *item in arrayCategories) {
//        if([category isEqualToString:[item valueForKey:@"oid"]]){
//            return [item valueForKey:@"otype"];
//        }
//    }
//    return NULL;
//}


+(NSString *)getCategoryType:(NSString *)category arrayCategories:(NSArray *)arrayCategories{
    NSLog(@"CATEGORIES: %@ ",arrayCategories);
    for(NSDictionary *item in arrayCategories) {
        if([category isEqualToString:[item valueForKey:@"oid"]]){
            NSLog(@"CATEGORIES: %@ - %@",category, [item valueForKey:@"otype"]);
            return [item valueForKey:@"otype"];
        }
    }
    return NULL;
}

@end

