//
//  SHPProduct.m
//  BirdWatching
//
//  Created by andrea sponziello on 26/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPProduct.h"
#import "SHPServiceUtil.h"

@implementation SHPProduct

@synthesize oid;
@synthesize name;
@synthesize longDescription;
@synthesize brand;
@synthesize category;
@synthesize shop;
@synthesize shopName;
@synthesize shopLat;
@synthesize shopLon;
@synthesize currency;
@synthesize image;
@synthesize imageURL;
//@synthesize httpURL;
@synthesize price;
@synthesize distance;
@synthesize userLiked;
@synthesize likesCount;
@synthesize sponsored;
@synthesize createdOn;
@synthesize createdBy;
@synthesize imageWidth;
@synthesize imageHeight;

-(NSString *)httpURL {
    return [[NSString alloc] initWithFormat:@"%@/products/%@", [SHPServiceUtil serviceHost], self.oid];
}

-(NSString *)httpTinyURL {
    return [[NSString alloc] initWithFormat:@"%@/p/%@", [SHPServiceUtil serviceHost], self.oid];
}

-(NSString *)returnProperty:(NSString*)label{
    NSArray *values;
    NSString *valueProperty = nil;
    NSDictionary *dictionary = (NSDictionary *)[self.properties valueForKey:label];
    values = (NSArray *)[dictionary valueForKey:@"values"];
    if (values.count > 0) {
        valueProperty = [values objectAtIndex:0];
    }
    return valueProperty;
}

+(NSDictionary *)setProperties:(NSString*)label displayName:(NSString *)displayName oid:(NSString *)idProperty values:(NSArray *)values
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:idProperty forKey:@"_id"];
    [dict setValue:displayName forKey:@"displayName"];
    [dict setValue:values forKey:@"values"];
    
    NSDictionary *finalData = [NSDictionary dictionaryWithObject:dict forKey:label];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalData options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *stringData = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"JSON finalData: %@ \n stringData", finalData);
    return finalData;
}

@end

