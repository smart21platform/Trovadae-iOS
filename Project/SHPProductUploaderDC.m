//
//  SHPProductUploaderDC.m
//  Dressique
//
//  Created by andrea sponziello on 01/02/13.
//
//

#import "SHPProductUploaderDC.h"
#import "SHPUser.h"
#import "SHPCategory.h"
#import "SHPShop.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPImageUtil.h"
#import "SHPConstants.h"
#import "SHPApplicationContext.h"
#import "SHPConnectionsController.h"
#import "SHPFacebookConnectionsHandler.h"
#import "SHPProductDC.h"
#import "SHPCaching.h"
#import "SHPProduct.h"

@implementation SHPProductUploaderDC

@synthesize applicationContext;
@synthesize callerViewController;
@synthesize progressView;

@synthesize receivedData;

@synthesize uploadId;
@synthesize onFinishPublishToFacebook;

enum {
    STATE_UPLOADING = 10,
    STATE_FAILED = 20,
    STATE_TERMINATED = 30
};

-(void)setMetadata:(UIImage *)__productImage
        brand:(NSString *)__productBrand
        categoryOid:(NSString *)__productCategoryOid
        shopOid:(NSString *)__productShopOid
        shopSource:(NSString *)__productShopSource
               lat:(NSString *)__lat
               lon:(NSString *)__lon
        shopGooglePlacesReference:(NSString *)__productShopGooglePlacesReference
             title:(NSString *)__productTitle
        description:(NSString *)__productDescription
        price:(NSString *)__productPrice
        startprice:(NSString *)__productStartPrice
        telephone:(NSString *)__telephone
        startDate:(NSString *)__productStartDate
        endDate:(NSString *)__productEndDate
        properties:(NSString *)__productProperties{
    self.productTitle = __productTitle;
    self.productDescription = __productDescription;
    self.productShopOid = __productShopOid;
    self.productShopSource = __productShopSource;
    self.productLat = __lat;
    self.productLon = __lon;
    self.productShopGooglePlacesReference = __productShopGooglePlacesReference;
    self.productCategoryOid = __productCategoryOid;
    self.productPrice = __productPrice;
    self.productStartPrice = __productStartPrice;
    self.productTelephone = __telephone;
    self.productImage = __productImage;
    self.productBrand = __productBrand;
    self.productStartDate = __productStartDate;
    self.productEndDate = __productEndDate;
    self.productProperties = __productProperties;
    
    NSLog(@"CATEGORY OID %@", self.productCategoryOid);
    
    self.uploadId = [[NSUUID UUID] UUIDString];
    NSLog(@"Upload ID: %@", self.uploadId);
    [self saveMe];
}

-(void)send {
    NSString *actionUrl = [[SHPServiceUtil serviceUrl:@"service.products"] stringByAppendingString:@"/add"];
    //    NSLog(@"Add action url: %@", actionUrl);
    
    NSString * boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    //    NSLog(@"randomString: -%@-", randomString);
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.productImage];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
    //    NSLog(@"SENDING IMAGE DATA LENGTH: %d", [imageData length]);
    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    
    NSString *brandString = [self stringParameter:@"brand" withValue:self.productBrand];
    NSString *categoryString = nil;
    if (self.productCategoryOid) {
        categoryString = [self stringParameter:@"category" withValue:self.productCategoryOid];
    }
    NSString *startDateString = nil;
    if (self.productStartDate) {
        startDateString = [self stringParameter:@"startDate" withValue:self.productStartDate];
    }
    NSString *endDateString = nil;
    if (self.productEndDate) {
        endDateString = [self stringParameter:@"endDate" withValue:self.productEndDate];
    }
    NSString *titleString = @"";
    if (self.productTitle) {
        titleString = [self stringParameter:@"title" withValue:self.productTitle];
    }
    NSString *descriptionString = @"";
    if (self.productDescription) {
        descriptionString = [self stringParameter:@"description" withValue:self.productDescription];
    }

    NSString *priceString = [self stringParameter:@"price" withValue:self.productPrice];
    NSString *startPriceString = [self stringParameter:@"startPrice" withValue:self.productStartPrice];
    NSString *telephoneString = [self stringParameter:@"phone" withValue:self.productTelephone];
    
    NSLog(@"PriceString: %@", priceString);
    NSLog(@"StartPriceString: %@", startPriceString);
    NSLog(@"telephoneString: %@", telephoneString);
    
    NSString *shopString = [self stringParameter:@"shop" withValue:self.productShopOid];
    NSString *shopSourceString = [self stringParameter:@"source" withValue:self.productShopSource];
    NSString *shopReferenceString = [self stringParameter:@"reference" withValue:self.productShopGooglePlacesReference];
    NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString *boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[brandString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[priceString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[startPriceString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[telephoneString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (categoryString) {
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[categoryString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (startDateString) {
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[startDateString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (endDateString) {
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[endDateString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[titleString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[descriptionString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[shopString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[shopSourceString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[shopReferenceString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"product-photo.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    //    [theRequest addValue:@"www.theshopper.com" forHTTPHeaderField:@"Host"];
    NSString * dataLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    
    // debug only...
    //    NSData *partData = [postData subdataWithRange:NSMakeRange(0, 1200)];
    //    NSString *partialAsString = [[NSString alloc] initWithData:partData encoding:NSASCIIStringEncoding];
    //    NSLog(@"partialAsString len: %d", partialAsString.length);
    //    NSLog(@"partialAsString:\n%@", partialAsString);
    
    if (self.applicationContext.loggedUser) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", self.applicationContext.loggedUser.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
        //        NSDictionary* headers = [theRequest allHTTPHeaderFields];
        //        for (NSString *key in headers) {
        //            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
        //        }
    } else {
        //        NSLog(@"NO USER");
    }
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    self.currentState = STATE_UPLOADING;
    self.progress = 0.0;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (theConnection) {
        receivedData = [NSMutableData data];
    } else {
        NSLog(@"Could not connect to the network");
    }
}

-(void)sendReport {
    NSString *actionUrl = [[SHPServiceUtil serviceUrl:@"service.contents"] stringByAppendingString:@"/add"];
    NSLog(@"Add action url contents: %@", actionUrl);
    NSString *boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    NSString * boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString * boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.productImage];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    
    
    
   
   
    
    if(self.productShopOid){
        NSString *shopString = [self stringParameter:@"shop" withValue:self.productShopOid];
        NSString *shopSourceString = [self stringParameter:@"source" withValue:self.productShopSource];
        NSString *shopReferenceString = [self stringParameter:@"reference" withValue:self.productShopGooglePlacesReference];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[shopString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[shopSourceString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[shopReferenceString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if(self.productLat && self.productLon){
        NSString *latString = [self stringParameter:@"lat" withValue:self.productLat];
        NSString *longString = [self stringParameter:@"lon" withValue:self.productLon];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[latString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[longString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if(self.productPrice){
        NSString *telephoneString = [self stringParameter:@"price" withValue:self.productPrice];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[telephoneString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if(self.productStartPrice){
        NSString *telephoneString = [self stringParameter:@"startprice" withValue:self.productStartPrice];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[telephoneString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if(self.productTelephone){
         NSString *telephoneString = [self stringParameter:@"phone" withValue:self.productTelephone];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[telephoneString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (self.productCategoryOid) {
         NSString *categoryString = [self stringParameter:@"category" withValue:self.productCategoryOid];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[categoryString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (self.productProperties) {
         NSString *propertiesString = [self stringParameter:@"properties" withValue:self.productProperties];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[propertiesString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (self.productTitle) {
        NSString *titleString = [self stringParameter:@"title" withValue:self.productTitle];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[titleString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (self.productDescription) {
         NSString *descriptionString = [self stringParameter:@"description" withValue:self.productDescription];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[descriptionString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //NSLog(@"postData:::: %@ \n %@", propertiesString,self.productProperties);
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"product-photo.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    //    [theRequest addValue:@"www.theshopper.com" forHTTPHeaderField:@"Host"];
    NSString * dataLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    if (self.applicationContext.loggedUser) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", self.applicationContext.loggedUser.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
       NSLog(@"NO USER");
    }
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    self.currentState = STATE_UPLOADING;
    self.progress = 0.0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (theConnection) {
        receivedData = [NSMutableData data];
    } else {
        NSLog(@"Could not connect to the network");
    }
}


-(void)sendUpdate:(NSString *)idProduct{
    NSString *actionUrl = [[SHPServiceUtil serviceUrl:@"service.contents"] stringByAppendingString:@"/update"];
    //NSString *actionUrl = [[SHPServiceUtil serviceUrl:@"service.products"] stringByAppendingString:@"/update"];
    NSLog(@"Add action url contents: %@", actionUrl);
    NSString *boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString *boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    NSMutableData *postData = [[NSMutableData alloc] init];
    
    NSString *idProductString = [self stringParameter:@"id" withValue:idProduct];
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[idProductString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *imageData = nil;
    if(self.productImage){
        UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.productImage];
        imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
        postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    }
    
    NSString *categoryString = nil;
    if (self.productCategoryOid) {
        categoryString = [self stringParameter:@"category" withValue:self.productCategoryOid];
    }
    
    NSString *titleString = @"";
    if (self.productTitle) {
        titleString = [self stringParameter:@"title" withValue:self.productTitle];
    }
    
    NSString *descriptionString = [self stringParameter:@"description" withValue:self.productDescription];
    NSString *propertiesString = [self stringParameter:@"properties" withValue:self.productProperties];
    NSString *telephoneString = [self stringParameter:@"phone" withValue:self.productTelephone];
    
    if(self.productShopOid){
        NSString *shopString = [self stringParameter:@"shop" withValue:self.productShopOid];
        NSString *shopSourceString = [self stringParameter:@"source" withValue:self.productShopSource];
        NSString *shopReferenceString = [self stringParameter:@"reference" withValue:self.productShopGooglePlacesReference];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[shopString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[shopSourceString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[shopReferenceString dataUsingEncoding:NSUTF8StringEncoding]];
    }else if(self.productLat && self.productLon){
        NSString *latString = [self stringParameter:@"lat" withValue:self.productLat];
        NSString *longString = [self stringParameter:@"lon" withValue:self.productLon];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[latString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[longString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[telephoneString dataUsingEncoding:NSUTF8StringEncoding]];
    if (categoryString) {
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[categoryString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (self.productProperties) {
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[propertiesString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[titleString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[descriptionString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //NSLog(@"postData:::: %@ \n %@", propertiesString,self.productProperties);
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"product-photo.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    //    [theRequest addValue:@"www.theshopper.com" forHTTPHeaderField:@"Host"];
    NSString * dataLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    if (self.applicationContext.loggedUser) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", self.applicationContext.loggedUser.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
        NSLog(@"NO USER");
    }
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    self.currentState = STATE_UPLOADING;
    self.progress = 0.0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (theConnection) {
        receivedData = [NSMutableData data];
    } else {
        NSLog(@"Could not connect to the network");
    }
}


//-(void)verifyUploadPermissionForUser:(SHPUser *)__user {
//    NSString *__url = [[SHPServiceUtil serviceUrl:@"service.products"] stringByAppendingString:@"/add"];
//    
//    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"url: %@", __url_enc);
//    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
//                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                          timeoutInterval:60.0];
//    
//    if (__user) {
//        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
//        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
//    }
//    
//    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    if (theConnection) {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//        self.receivedData = [[NSMutableData alloc] init];
//    } else {
//        // Inform the user that the connection failed.
////        [self connectionFailed];
//    }
//}

-(NSString *)stringParameter:(NSString *)name withValue:(NSString *)value {
    NSString *part = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", name, value];
    return part;
}

-(void)connectionFailed:(NSError *)error {
    
    NSLog(@"(SHPProductUploader) Connection Error!");
    self.receivedData = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(self.delegate)[self.delegate productUploaded:[NSString stringWithFormat:@"%@",error]];
    
    if (self.callerViewController && [self.callerViewController respondsToSelector:@selector(itemUploadedWithError:)]) {
        [self.callerViewController performSelector:@selector(itemUploadedWithError:) withObject:error];
    }
    
//    if (self.connectionsControllerDelegate) {
//        [self.connectionsControllerDelegate didFinishConnection:self withError:error];
//    }
    
    self.currentState = STATE_FAILED;
}




// CONNECTION DELEGATE



- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
//    NSLog(@"written %d of %d", totalBytesWritten, totalBytesExpectedToWrite);
    self.progress = (float) totalBytesWritten / (float) totalBytesExpectedToWrite;
    if (self.progressView) {
        self.progressView.progress = self.progress;
    }
}

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
    NSString *error = nil;
    self.currentState = STATE_TERMINATED;
    //NSString* text;
	//text = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
    //        [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    
    NSLog(@">>>>> response: %@", responseString);
    // TODO get the product with the ID
    
    NSString *p_oid = [self jsonToId:self.receivedData];
    NSLog(@"IDDDDDDDDD: %@", p_oid);
//    NSArray *products = [SHPProductDC jsonToProducts:self.receivedData];
//    SHPProduct *createdProduct = nil;
//    if (products && products.count > 0) {
//        createdProduct = (SHPProduct *) [products objectAtIndex:0];
//    }
//    if (self.onFinishPublishToFacebook && createdProduct) {
    if (self.onFinishPublishToFacebook) {
        NSLog(@"self.onFinishPublishToFacebook is true. PUBLISHING ON FACEBOOK.");
        SHPProduct *p = [[SHPProduct alloc] init];
        p.oid = p_oid;
        NSString *fbDescription = [[NSString alloc] initWithFormat:@"%@\n\n%@", self.productDescription, [p httpTinyURL]];
        [SHPFacebookConnectionsHandler publishProductWithDescription:fbDescription image:self.productImage onPage:self.applicationContext.postToFacebookPage];
//        [self.applicationContext.facebookConnections publishProductWithDescription:fbDescription image:self.productImage];
    }
    
    if(!p_oid)error=responseString;
    if(self.delegate)[self.delegate productUploaded:error];
    
    if (self.callerViewController && [self.callerViewController respondsToSelector:@selector(itemUploadedWithError:)]) {
        [self.callerViewController performSelector:@selector(itemUploadedWithError:) withObject:nil];
    }
    
    if (self.connectionsControllerDelegate) {
        [self.connectionsControllerDelegate didFinishConnection:self withError:nil];
    }
    
    [SHPProductUploaderDC deleteMeFromPersistentConnections:self.uploadId];
}

-(NSString *)jsonToId:(NSData *)jsonData {
    NSString *id = nil;
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    
    NSLog(@"ERROR.... %@", error);
    
    if (error) {
        NSLog(@"Invalid Json! Returning nil");
        return nil;
    }
    
    id = [objects valueForKey:@"id"];
    NSLog(@"id %@", id);
    
    return id;
}

-(void)saveMe {
//    // VERY TEMP
//    [SHPCaching deleteFile:@"79CF478D-FDB9-4E03-B400-71F5B5118E67"];
    NSLog(@"Saving upload id: %@", self.uploadId);
    // Build a dictionary with metadata
    NSMutableDictionary *uploaderDictionary = [[NSMutableDictionary alloc] init];
    if(self.productImage)[uploaderDictionary setObject:self.productImage forKey:@"image"];
    if(self.uploadId)[uploaderDictionary setObject:self.uploadId forKey:@"uploadId"];
    if(self.productTitle)[uploaderDictionary setObject:self.productTitle forKey:@"title"];
    if(self.productDescription)[uploaderDictionary setObject:self.productDescription forKey:@"description"];
    if(self.productBrand)[uploaderDictionary setObject:self.productBrand forKey:@"brand"];
    if(self.productCategoryOid)[uploaderDictionary setObject:self.productCategoryOid forKey:@"categoryOid"];

    if(self.productPrice)[uploaderDictionary setObject:self.productPrice forKey:@"price"];
    if(self.productStartPrice)[uploaderDictionary setObject:self.productStartPrice forKey:@"startprice"];
    if(self.productTelephone)[uploaderDictionary setObject:self.productTelephone forKey:@"phone"];
    if(self.productShopOid)[uploaderDictionary setObject:self.productShopOid forKey:@"shopOid"];
    if(self.productShopSource)[uploaderDictionary setObject:self.productShopSource forKey:@"shopSource"];
    if(self.productShopGooglePlacesReference)[uploaderDictionary setObject:self.productShopGooglePlacesReference forKey:@"shopGooglePlacesReference"];
    if(self.productProperties)[uploaderDictionary setObject:self.productProperties forKey:@"properties"];
    NSString *onFinishPublishToFacebook_string = self.onFinishPublishToFacebook ? @"yes" : @"no";
    [uploaderDictionary setObject:onFinishPublishToFacebook_string forKey:@"onFinishPublishToFacebook_string"];
    // Save dictionary on disk
    NSString *fileName = [SHPProductUploaderDC fileNameById:self.uploadId];
    NSLog(@"Upload filename: %@", fileName);
    [SHPCaching saveDictionary:uploaderDictionary inFile:fileName];
    NSLog(@"Upload saved.");
    
    NSLog(@"Verifying save...");
    NSMutableDictionary *savedUploader = [SHPCaching restoreDictionaryFromFile:fileName];
    UIImage *image = (UIImage *) [savedUploader objectForKey:@"image"];
    NSLog(@"Image: %@", image);
    NSLog(@"image.width %f", image.size.width);
    NSLog(@"price: %@", [savedUploader objectForKey:@"price"]);
    NSLog(@"phone: %@", [savedUploader objectForKey:@"phone"]);
    NSLog(@"uploadId: %@", [savedUploader objectForKey:@"uploadId"]);
    NSLog(@"shopOid: %@", [savedUploader objectForKey:@"shopOid"]);
    NSLog(@"shopSource: %@", [savedUploader objectForKey:@"shopSource"]);
    NSLog(@"shopGooglePlacesReference: %@", [savedUploader objectForKey:@"shopGooglePlacesReference"]);
    NSLog(@"title: %@", [savedUploader objectForKey:@"title"]);
    NSLog(@"description: %@", [savedUploader objectForKey:@"description"]);
    NSLog(@"uploadId: %@", [savedUploader objectForKey:@"uploadId"]);
    NSLog(@"brand: %@", [savedUploader objectForKey:@"brand"]);
    NSLog(@"categoryOid: %@", [savedUploader objectForKey:@"categoryOid"]);
    //NSLog(@"categoryName: %@", [savedUploader objectForKey:@"categoryName"]); // remove
    NSLog(@"onFinishPublishToFacebook_string: %@", [savedUploader objectForKey:@"onFinishPublishToFacebook_string"]);
    NSLog(@"properties: %@", [savedUploader objectForKey:@"properties"]);
    // Save id in connections
    [self addUploadToPersistentConnections];
    NSLog(@"Verifying connections on disk after add:");
    [SHPProductUploaderDC printUploadsOnDisk];
}

+(void)deleteMeFromPersistentConnections:(NSString *)id {
    NSLog(@"Deleting upload %@", id);
    NSLog(@"=====Uploads on disk before delete:");
    [SHPProductUploaderDC printUploadsOnDisk];
    // Delete dictionary from disk
    NSString *fileName = [SHPProductUploaderDC fileNameById:id];
    [SHPCaching deleteFile:fileName];
    // Delete id from connections
    [SHPProductUploaderDC removeUploadFromPersistentConnections:id]; // removes also from the connections array on disk
    
    NSLog(@"***** Verifying connections on disk after delete:");
    [SHPProductUploaderDC printUploadsOnDisk];
}

+(NSString *)fileNameById:(NSString *)_uploadId {
    NSString *fileName = [[NSString alloc] initWithFormat:@"running-upload-%@", _uploadId];
    return fileName;
}

-(void)addUploadToPersistentConnections {
    // restore saved ids
    NSMutableDictionary *currentConnectionsOnDisk = [SHPCaching restoreDictionaryFromFile:@"current-connections"];
    if (!currentConnectionsOnDisk) {
        currentConnectionsOnDisk = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *connectionsIds = (NSMutableArray *)[currentConnectionsOnDisk objectForKey:@"array"];
    if (!connectionsIds) {
        connectionsIds = [[NSMutableArray alloc] init];
        [currentConnectionsOnDisk setObject:connectionsIds forKey:@"array"];
    }
    [connectionsIds addObject:self.uploadId];
    [SHPCaching saveDictionary:currentConnectionsOnDisk inFile:@"current-connections"];
}

+(void)removeUploadFromPersistentConnections:(NSString *)id {
    // restore saved ids
    NSMutableDictionary *currentConnectionsOnDisk = [SHPCaching restoreDictionaryFromFile:@"current-connections"];
    NSMutableArray *connectionsIds = (NSMutableArray *)[currentConnectionsOnDisk objectForKey:@"array"];
    [connectionsIds removeObject:id];
    [SHPCaching saveDictionary:currentConnectionsOnDisk inFile:@"current-connections"];
}

+(NSMutableArray *)uploadIdsOnDisk {
    NSMutableDictionary *currentConnectionsOnDisk = [SHPCaching restoreDictionaryFromFile:@"current-connections"];
    NSMutableArray *connectionsIds = (NSMutableArray *)[currentConnectionsOnDisk objectForKey:@"array"];
    return connectionsIds;
}

+(void)printUploadsOnDisk {
    NSMutableArray *uploadIds = [SHPProductUploaderDC uploadIdsOnDisk];
//    NSLog(@"Saved uploads count: %d", uploadIds.count);
    for (NSString *id in uploadIds) {
        NSLog(@"Upload Id: %@", id);
    }
}

+(SHPProductUploaderDC *)getPersistentUploaderById:(NSString *) id {
    NSLog(@"Creating uploaderDC from disk...");
    NSString *fileName = [SHPProductUploaderDC fileNameById:id];
    NSMutableDictionary *savedUploader = [SHPCaching restoreDictionaryFromFile:fileName];
    
    SHPProductUploaderDC *uploaderDC = [[SHPProductUploaderDC alloc] init];
    uploaderDC.currentState = STATE_FAILED;
    
    NSString *facebookStatus_s = [savedUploader objectForKey:@"onFinishPublishToFacebook_string"];
    BOOL facebookStatus = [facebookStatus_s isEqualToString:@"yes"] ? YES : NO;
    NSLog(@">>>>>> sharing on facebook is %d", facebookStatus);
    uploaderDC.onFinishPublishToFacebook = facebookStatus;
    uploaderDC.callerViewController = nil; // detached form the form view
    uploaderDC.progressView = nil; // detached from the form view
    uploaderDC.creationDate = nil; // unused
    uploaderDC.productDescription = [savedUploader objectForKey:@"description"];
    //uploaderDC.description = uploaderDC.productDescription;
    uploaderDC.productShopSource = [savedUploader objectForKey:@"shopSource"];
    uploaderDC.productShopOid = [savedUploader objectForKey:@"shopOid"];
    uploaderDC.productShopGooglePlacesReference = [savedUploader objectForKey:@"shopGooglePlacesReference"];
    uploaderDC.productImage = (UIImage *) [savedUploader objectForKey:@"image"];
    uploaderDC.productPrice = [savedUploader objectForKey:@"price"];
    uploaderDC.productTelephone = [savedUploader objectForKey:@"phone"];
    uploaderDC.productCategoryOid = [savedUploader objectForKey:@"categoryOid"];
    uploaderDC.productBrand = [savedUploader objectForKey:@"brand"];
    uploaderDC.uploadId = [savedUploader objectForKey:@"uploadId"];
    
    return uploaderDC;
}

-(void)dealloc {
    NSLog(@"DEALLOCATING SHPProductUploaderDC");
}

@end
