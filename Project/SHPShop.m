//
//  ShoppShop.m
//  BirdWatching
//
//  Created by andrea sponziello on 08/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPShop.h"

@implementation SHPShop

@synthesize loaded;
@synthesize oid = _oid;
@synthesize name = _name;
@synthesize formattedAddress;
@synthesize source;
@synthesize googlePlacesReference;
@synthesize lat = _lat;
@synthesize lon = _lon;

// TODO...
@synthesize country;
@synthesize city;
@synthesize address;
@synthesize phone;
@synthesize website;
@synthesize email;

@synthesize coverImage;
@synthesize coverImageURL;
@synthesize theDescription;
@synthesize distance; // TODO
@synthesize imageURL;

-(id)init {
    self = [super init];
    if (self) {
        self.loaded = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.oid = [decoder decodeObjectForKey:@"oid"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.source = [decoder decodeObjectForKey:@"source"];
        self.googlePlacesReference = [decoder decodeObjectForKey:@"googlePlacesReference"];
        self.lat = [decoder decodeFloatForKey:@"lat"];
        self.lon = [decoder decodeFloatForKey:@"lon"];
        self.formattedAddress = [decoder decodeObjectForKey:@"formattedAddress"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.oid forKey:@"oid"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.name forKey:@"source"];
    [encoder encodeObject:self.name forKey:@"googlePlacesReference"];
    [encoder encodeFloat:self.lat forKey:@"lat"];
    [encoder encodeFloat:self.lon forKey:@"lon"];
    [encoder encodeObject:self.formattedAddress forKey:@"formattedAddress"];
}

@end
