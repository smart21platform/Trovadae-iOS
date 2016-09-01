//
//  ShoppShop.h
//  BirdWatching
//
//  Created by andrea sponziello on 08/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHPShop : NSObject <NSCoding>

@property (nonatomic, assign) BOOL loaded; // the object comes from the remote service
@property (nonatomic, strong) NSString *oid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *formattedAddress;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *googlePlacesReference;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *coverImageURL;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) NSString *theDescription;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSDictionary *properties;


@end
