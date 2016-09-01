//
//  SHPShopDC.m
//  BirdWatching
//
//  Created by andrea sponziello on 07/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPShopDC.h"
#import "SHPShop.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPUser.h"

@implementation SHPShopDC

@synthesize receivedData = _receivedData;
@synthesize shopsLoadedDelegate = _shopsLoadedDelegate;
@synthesize theConnection;
@synthesize statusCode;
@synthesize serviceUrl;
@synthesize serviceName;

-(void)searchByText:(NSString *)text location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
    NSString *_serviceUrl = [SHPServiceUtil serviceUrl:@"service.search.shops"];
    
    NSString *textQuery = @"";
    if(text) {
        NSString *textEscaped = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        textQuery = [[NSString alloc] initWithFormat:@"&q=%@", textEscaped];
    }
    
    NSString *locationQuery = @"";
    if(location) {
        double lat = location.coordinate.latitude;
        double lon = location.coordinate.longitude;
        locationQuery = [[NSString alloc] initWithFormat:@"&lat=%f&lon=%f", lat, lon];
    }
    
    NSString *pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@%@", _serviceUrl, textQuery, locationQuery, pageQuery];
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
    NSLog(@"(SHPShopDC) Canceling current connection: %@", self.theConnection);
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
    self.shopsLoadedDelegate = nil;
}

- (void)searchByLocation:(double)lat lon:(double)lon {
    NSLog(@"Searching shops by location...");
    
    self.serviceName = @"searchByLocation";
    // Create the request.
    self.serviceUrl = [SHPServiceUtil serviceUrl:@"service.shops"];
    NSString *__url = [NSString stringWithFormat:@"%@?lat=%f&lon=%f", self.serviceUrl, lat, lon];
    NSLog(@"searching nearest shops url: %@", __url);
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    self.theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
        //[self.receivedData setLength:0];
        NSLog(@"Connecting...");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

- (void)searchByName:(NSString *)name {
    NSLog(@"Searching shops by name...");
    self.serviceName = @"searchByName";
    
    // Create the request.
    self.serviceUrl = [SHPServiceUtil serviceUrl:@"service.shops.mixed_search"]; //[[SHPServiceUtil serviceUrl:@"service.shops.mixed_search"] stringByAppendingString:@"/search"];
    NSString *__url = [NSString stringWithFormat:@"%@?name=%@", self.serviceUrl, [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:__url]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSLog(@"__url: %@", __url);
    // create the connection with the request
    // and start loading the data
    self.theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
        //[self.receivedData setLength:0];
        NSLog(@"Connecting...");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

- (void)searchByName:(NSString *)name lat:(double)lat lon:(double)lon {
    NSLog(@"Searching shops by name...");
    self.serviceName = @"searchByName";
    
    // Create the request.
    self.serviceUrl = [[SHPServiceUtil serviceUrl:@"service.shops"] stringByAppendingString:@"/search"];
    NSString *__url = [NSString stringWithFormat:@"%@?name=%@&lat=%f&lon=%f", self.serviceUrl, name, lat, lon];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSLog(@"\n****************  __url: %@", __url);
    self.theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
        //[self.receivedData setLength:0];
        NSLog(@"Connecting...");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

- (void)searchByShopId:(NSString *)shopId {
    NSLog(@"Searching shops by id...");
    self.serviceName = @"searchByShopId";
    
    // Create the request.
    self.serviceUrl = [SHPServiceUtil serviceUrl:@"service.shops"];
    NSString *__url = [NSString stringWithFormat:@"%@/%@", self.serviceUrl, shopId];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"URL: %@", __url_enc);
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    self.theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
        //[self.receivedData setLength:0];
//        NSLog(@"Connection successfull!");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

-(void)create:(SHPShop *)shop withUser:(SHPUser *)__user {
    self.serviceName = @"create";
    NSLog(@"creating shop...");
    
    // Create the request.
    self.serviceUrl = [[SHPServiceUtil serviceUrl:@"service.shops"] stringByAppendingString:@"/add"];
    NSLog(@"self.serviceUrl: %@", self.serviceUrl);
    
    NSString *_url = self.serviceUrl;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *shopLatString = [[NSString alloc] initWithFormat:@"%f", shop.lat];
    NSString *shopLonString = [[NSString alloc] initWithFormat:@"%f", shop.lon];
    
    NSString *postString = [[NSString alloc] initWithFormat:@"name=%@&lat=%@&lon=%@", [SHPStringUtil urlParamEncode:shop.name], [SHPStringUtil urlParamEncode:shopLatString], [SHPStringUtil urlParamEncode:shopLonString]];
    NSLog(@"postString: %@", postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [request setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
        NSDictionary* headers = [request allHTTPHeaderFields];
        for (NSString *key in headers) {
            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
        }
    }
    
    // create the connection with the request
    // and start loading the data
    self.theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
        //[self.receivedData setLength:0];
//        NSLog(@"Connection successfull!");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

-(void)update:(SHPShop *)shop withUser:(SHPUser *)__user {
    self.serviceName = @"update";
}

-(void)connectionFailed {
    NSLog(@"(SHPShopDC) Connection Error!");
    self.receivedData = nil;
    if (self.shopsLoadedDelegate) {
        if([self.shopsLoadedDelegate respondsToSelector:@selector(networkError)]) {
            [self.shopsLoadedDelegate networkError];
        } else {
            NSLog(@"SHPShopDC: self.delegate -->> %@ <<-- does not respond to selector 'networkError'!", self.shopsLoadedDelegate);
        }
    } else {
        NSLog(@"(SHPShopDC) self.shopsLoadedDelegate is nil!");
    }
}

// delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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
    NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"(SHPShopDC) Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed];
//    if (self.shopsLoadedDelegate) {
//        if ([self.shopsLoadedDelegate respondsToSelector:@selector(shopDCNetworkError:)]) {
//            [self.shopsLoadedDelegate shopDCNetworkError:self];
//        }
//    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
//    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    
    if (self.statusCode >= 400) {
        NSLog(@"Error %ld. Not processing response.", (long)self.statusCode);
        [self connectionFailed];
        return;
    }
    
    //NSString* text;
	//text = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]; //NSUTF8StringEncoding];
    //NSLog(@"response: %@", responseString);
    if (responseString.length > 0) {
        NSArray *shops = [self jsonToShops:self.receivedData];
        NSLog(@"self.shopsLoadedDelegate = %@", self.shopsLoadedDelegate);
        if (self.shopsLoadedDelegate) {
            if([self.serviceName isEqualToString:@"create"]) {
                if([self.shopsLoadedDelegate respondsToSelector:@selector(shopCreated:)]) {
                    [self.shopsLoadedDelegate shopCreated:[shops objectAtIndex:0]];
                } else {
                    NSLog(@"SHPShopDC GRAVE ERROR: delegate %@ not responding to selector shopCreated: the delegate is changed? (probabily the origilan object was deallocated?) ... calling connectionFailed", self.shopsLoadedDelegate);
                }
            } else {
                NSLog(@"shops loaded!");
                if([self.shopsLoadedDelegate respondsToSelector:@selector(shopsLoaded:)]) {
                    NSLog(@"calling [self.shopsLoadedDelegate shopsLoaded:shops]");
                    [self.shopsLoadedDelegate shopsLoaded:shops];
                } else {
                    NSLog(@"SHPShopDC GRAVE ERROR: delegate %@ not responding to selector shopCreated: ... calling [self connectionFailed]", self.shopsLoadedDelegate);
                    [self connectionFailed];
                }
            }
        }
    }
}


// util



- (NSArray *)jsonToShops:(NSData *)jsonData {
    NSMutableArray *shops = [[NSMutableArray alloc] init ];
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    
    //NSString *channel = [objects valueForKey:@"channel"];
    //NSLog(@"Channel: %@", channel);
//    NSString *date = [objects valueForKey:@"date"];
    NSLog(@"*** objects *** : %@", objects);
    NSArray *items = [objects valueForKey:@"items"];
    
    for(NSDictionary *item in items) {
//        NSString *type = [item valueForKey:@"type"];
        NSString *oid = [item valueForKey:@"id"];
        NSString *name = [item valueForKey:@"name"];
        NSString *source = [item valueForKey:@"source"];
        NSString *googlePlacesReference = [item valueForKey:@"reference"];
        NSString *formattedAddress = [item valueForKey:@"formatted_address"];
        double lat = [[item valueForKey:@"lat"] doubleValue];
        double lon = [[item valueForKey:@"lon"] doubleValue];
        
        NSString *country = [item valueForKey:@"country"];
        NSString *city = [item valueForKey:@"city"];
        NSString *address = [item valueForKey:@"address"];
        NSString *phone = [item valueForKey:@"phone"];
        NSString *website = [item valueForKey:@"website"];
        NSString *email = [item valueForKey:@"email"];
        NSString *cover = [item valueForKey:@"cover"];
        NSString *theDescription = [item valueForKey:@"description"];
        NSDictionary *properties = [item valueForKey:@"properties"];
        
        SHPShop *shop = [[SHPShop alloc] init];
        
        shop.oid = oid;
        shop.name = name;
        shop.source = source;
        shop.googlePlacesReference = googlePlacesReference;
        shop.formattedAddress = formattedAddress;
        shop.lat = lat;
        shop.lon = lon;
        
        shop.country = country;
        shop.city = city;
        shop.address = address;
        shop.phone = phone;
        shop.website = website;
        shop.email = email;
        shop.coverImageURL = cover;
        shop.theDescription = theDescription;
        shop.properties = properties;
        shop.loaded = YES;
        
        [shops addObject:shop];
    }
    
//    NSLog(@"Shops count: %d", [shops count]);
    // or convert int to string with NSString.stringWithFormat
//    int count = [shops count];
//    NSString *countS = [NSString stringWithFormat:@"%d", count];
//    NSLog(@"Shops countS: %@", countS);
    for (SHPShop *s in shops) {
        NSLog(@"SHOP OID %@ %@ %@ %@", s.oid, s.name, s.source, s.googlePlacesReference);
    }
    
    return shops;
}

@end
